# frozen_string_literal: true

require 'zeitwerk'
require 'json'
require 'active_support/backtrace_cleaner'

Zeitwerk::Loader.new.then do |loader|
  loader.tag = 'rspec-html_messages'
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

    def render(
      # Section visibility
      show_diff_section: true,
      show_failure_message: true,
      show_exception_details: true,

      # Diff behavior
      force_diffable: ['RSpec::Matchers::BuiltIn::ContainExactly'],
      force_not_diffable: ['RSpec::Matchers::BuiltIn::Include'],

      # Failure message options
      rspec_diff_in_message: false,

      # Exception/backtrace options
      backtrace_max_lines: 10,
      backtrace_silence_gems: true
    )
      @options = {
        show_diff_section: show_diff_section,
        show_failure_message: show_failure_message,
        show_exception_details: show_exception_details,
        force_diffable: force_diffable,
        force_not_diffable: force_not_diffable,
        rspec_diff_in_message: rspec_diff_in_message,
        backtrace_max_lines: backtrace_max_lines,
        backtrace_silence_gems: backtrace_silence_gems
      }
      render_template('example')
    end

    def self.loader(registry = Zeitwerk::Registry)
      @loader ||= registry.loaders.each.find { |loader| loader.tag == 'rspec-html_messages' }
    end

    def self.diff_css
      # Minimal Diffy styles - only what's essential for diffs
      # Removed: hardcoded fonts, sizes, and backgrounds
      <<~CSS
        .diff { overflow: auto; }
        .diff ul {#{' '}
          overflow: auto;
          list-style: none;
          margin: 0;
          padding: 0;
          display: table;
          width: 100%;
        }
        .diff del, .diff ins {#{' '}
          display: block;
          text-decoration: none;
        }
        .diff li {
          padding: 0;
          display: table-row;
          margin: 0;
          height: 1em;
        }
        .diff li.ins { background: #dfd; color: #080; }
        .diff li.del { background: #fee; color: #b00; }
        .diff li:hover { background: #ffc; }
        .diff del, .diff ins, .diff span { white-space: pre-wrap; }
        .diff del strong { font-weight: normal; background: #fcc; }
        .diff ins strong { font-weight: normal; background: #9f9; }
        .diff li.diff-comment { display: none; }
        .diff li.diff-block-info { background: none repeat scroll 0 0 gray; }
      CSS
    end

    private

    # Helper methods for templates
    def status
      example['status']
    end

    def details
      @details ||= example['details'] || {}
    end

    def matcher_name
      details['matcher_name'] || 'Unknown'
    end

    def failure_message
      return nil unless status == 'failed'

      message = example.dig('exception', 'message')
      return nil unless message

      # Strip leading newline that RSpec's built-in matchers add
      message = message.sub(/\A\n/, '')

      # Strip RSpec's diff section if requested
      unless options[:rspec_diff_in_message]
        # RSpec appends diffs with "\nDiff:" or "\nDiff for (...):"
        # The diff always contains @@ markers (unified diff format) or the empty diff message
        # This regex requires either @@ or "The diff is empty" to appear after Diff:
        # to avoid false positives where "Diff:" might appear in user data
        message = message.sub(
          /\n\s*Diff(?:\s+for\s+\([^)]+\))?:.*?(?:@@|The diff is empty).*\z/m,
          ''
        )
      end

      message
    end

    def exception_class
      example.dig('exception', 'class')
    end

    def exception_backtrace
      example.dig('exception', 'backtrace') || []
    end

    def has_exception?
      example.key?('exception')
    end

    def error_before_assertion?
      # Check if this is an error (not a matcher failure)
      has_exception? && !has_actual? && !has_expected?
    end

    def has_expected?
      details.key?('expected')
    end

    def backtrace_cleaner
      @backtrace_cleaner ||= build_backtrace_cleaner
    end

    def build_backtrace_cleaner
      ActiveSupport::BacktraceCleaner.new.tap do |bc|
        # Clean up paths by removing project root
        bc.add_filter { |line| line.gsub("#{project_root}/", '') }

        # Optionally silence gem frames
        if options[:backtrace_silence_gems]
          bc.add_silencer { |line| line.include?('/gems/') && !line.include?(project_root) }
          bc.add_silencer { |line| line.include?('/bundle/') }
          bc.add_silencer { |line| line.match?(%r{/ruby/\d+\.\d+\.\d+/}) }
        end

        # Always silence RSpec internals
        bc.add_silencer { |line| line.match?(%r{/lib/rspec/(core|expectations|mocks)/}) }
      end
    end

    def project_root
      @project_root ||= File.expand_path('../..', File.dirname(file_path))
    end

    def has_actual?
      details.key?('actual')
    end

    def actual_value
      @actual_value ||= deserialize_value(details['actual']) if has_actual?
    end

    def expected_value
      @expected_value ||= deserialize_value(details['expected']) if has_expected?
    end

    def prettified_actual
      @prettified_actual ||= prettify_for_diff(actual_value)
    end

    def prettified_expected
      @prettified_expected ||= prettify_for_diff(expected_value)
    end

    def negated?
      details['negated']
    end

    def show_diff?
      return false if status == 'passed'
      return false unless expected_value && actual_value
      return false if negated?

      # Check if values are identical (likely a negated matcher)
      return false if prettified_actual == prettified_expected

      effective_diffable?
    end

    def diff_html
      @diff_html ||= create_diff(prettified_actual, prettified_expected) if show_diff?
    end

    def formatted_backtrace(max_lines = nil)
      return [] if exception_backtrace.empty?

      max_lines ||= options[:backtrace_max_lines]
      cleaned = backtrace_cleaner.clean(exception_backtrace)

      # If all lines were filtered out, show original with cleaned paths
      if cleaned.empty?
        cleaned = ActiveSupport::BacktraceCleaner.new.tap do |bc|
          bc.add_filter { |line| line.gsub("#{project_root}/", '') }
        end.clean(exception_backtrace)
      end

      cleaned.first(max_lines)
    end
  end
end
