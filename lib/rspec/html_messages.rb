# frozen_string_literal: true

require "zeitwerk"
require "json"
require "active_support/backtrace_cleaner"

Zeitwerk::Loader.new.then do |loader|
  loader.tag = "rspec-html_messages"
  loader.push_dir "#{__dir__}/.."
  loader.setup
end

module Rspec
  # Main renderer class for converting enriched JSON examples to HTML
  class HtmlMessages
    include HtmlMessages::ValueFormatter
    include HtmlMessages::DiffFormatter
    include HtmlMessages::TemplateRenderer

    attr_reader :example, :options

    def initialize(example)
      @example = example
    end

    def render(options = {})
      @options = default_options.merge(options)

      # Render styles if this is the first time or in debug mode
      styles = render_partial("styles") if should_include_styles?

      # Render the main example template
      content = render_template("example")

      # Combine styles and content
      [styles, content].compact.join("\n")
    end

    def self.loader(registry = Zeitwerk::Registry)
      @loader ||= registry.loaders.each.find { |loader| loader.tag == "rspec-html_messages" }
    end

    private

    def default_options
      {
        debug: false,
        force_diffable: [
          "RSpec::Matchers::BuiltIn::ContainExactly"  # Used by both contain_exactly and match_array
        ],
        force_not_diffable: [
          "RSpec::Matchers::BuiltIn::Include"  # Include matcher shows what's missing, not a line-by-line diff
        ],
        rspec_diff_in_message: false,
        backtrace_max_lines: 10,
        backtrace_silence_gems: true
      }
    end

    def should_include_styles?
      # Always include styles for now, can be optimized later
      true
    end

    # Helper methods for templates
    def status
      example["status"]
    end

    def status_class
      (status == "passed") ? "passed" : "failed"
    end

    def description
      example["description"]
    end

    def file_path
      example["file_path"]
    end

    def line_number
      example["line_number"]
    end

    def details
      @details ||= example["details"] || {}
    end

    def matcher_name
      details["matcher_name"] || "Unknown"
    end

    def matcher_type
      case matcher_name
      when /DSL::Matcher/
        "Custom DSL Matcher"
      when /BuiltIn/
        "Built-in Matcher"
      else
        "Matcher"
      end
    end

    def failure_message
      return nil unless status == "failed"

      message = example.dig("exception", "message")
      return nil unless message

      # Strip RSpec's diff section if requested
      if !options[:rspec_diff_in_message]
        # RSpec appends diffs with "\nDiff:" or "\nDiff for (...):"
        # The diff always contains @@ markers (unified diff format) or the empty diff message
        # This regex requires either @@ or "The diff is empty" to appear after Diff:
        # to avoid false positives where "Diff:" might appear in user data
        message = message.sub(
          /\n\s*Diff(?:\s+for\s+\([^)]+\))?:.*?(?:@@|The diff is empty).*\z/m,
          ""
        )
      end

      message
    end

    def exception_class
      example.dig("exception", "class")
    end

    def exception_backtrace
      example.dig("exception", "backtrace") || []
    end

    def has_exception?
      example.key?("exception")
    end

    def error_before_assertion?
      # Check if this is an error (not a matcher failure)
      has_exception? && !has_actual? && !details.key?("expected")
    end

    def backtrace_cleaner
      @backtrace_cleaner ||= begin
        bc = ActiveSupport::BacktraceCleaner.new
        
        # Add filters to clean up paths
        bc.add_filter { |line| line.gsub(project_root + "/", "") }
        
        # Optionally silence gem frames
        if options[:backtrace_silence_gems]
          bc.add_silencer { |line| line.include?("/gems/") && !line.include?(project_root) }
          bc.add_silencer { |line| line.include?("/bundle/") }
          bc.add_silencer { |line| line.match?(%r{/ruby/\d+\.\d+\.\d+/}) }
        end
        
        # Always silence RSpec internals unless it's the only thing we have
        bc.add_silencer { |line| line.include?("/lib/rspec/core/") }
        bc.add_silencer { |line| line.include?("/lib/rspec/expectations/") }
        bc.add_silencer { |line| line.include?("/lib/rspec/mocks/") }
        
        bc
      end
    end

    def project_root
      @project_root ||= File.expand_path("../..", File.dirname(file_path))
    end

    def has_actual?
      details.key?("actual")
    end

    def actual_value
      @actual_value ||= deserialize_value(details["actual"]) if has_actual?
    end

    def expected_value
      @expected_value ||= deserialize_value(details["expected"]) if details.key?("expected")
    end

    def prettified_actual
      @prettified_actual ||= prettify_for_diff(actual_value)
    end

    def prettified_expected
      @prettified_expected ||= prettify_for_diff(expected_value)
    end

    def negated?
      details["negated"] || false
    end

    def show_diff?
      return false if status == "passed"
      return false unless expected_value && actual_value
      return false if negated?

      # Check if values are identical (likely a negated matcher)
      return false if prettified_actual == prettified_expected

      effective_diffable?
    end

    def diff_html
      @diff_html ||= create_diff(prettified_actual, prettified_expected) if show_diff?
    end

    # For the debug header template
    def effective_diffable
      effective_diffable?
    end

    # Helper to format backtrace for display
    def formatted_backtrace(max_lines = nil)
      return [] if exception_backtrace.empty?
      
      max_lines ||= options[:backtrace_max_lines]
      
      # Use ActiveSupport::BacktraceCleaner to clean the backtrace
      cleaned = backtrace_cleaner.clean(exception_backtrace)
      
      # If all lines were filtered out, show some of the original
      if cleaned.empty?
        # Remove only the most aggressive silencers and try again
        bc_lenient = ActiveSupport::BacktraceCleaner.new
        bc_lenient.add_filter { |line| line.gsub(project_root + "/", "") }
        cleaned = bc_lenient.clean(exception_backtrace).first(5)
      end
      
      # Limit the number of lines shown
      cleaned.first(max_lines)
    end
    
    # Helper to format a single backtrace line for display
    def format_backtrace_line(line)
      # Check if this is a project file (already cleaned by backtrace_cleaner)
      if !line.start_with?("/") && !line.match?(/^[A-Z]:\\/)
        # This is a project file (path was made relative)
        "→ #{line}"
      else
        # This is an external file
        "  #{line}"
      end
    end
  end
end
