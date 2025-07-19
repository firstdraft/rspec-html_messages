# frozen_string_literal: true

require 'zeitwerk'
require 'json'

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

    def render(options = {})
      @options = default_options.merge(options)
      
      # Render styles if this is the first time or in debug mode
      styles = render_partial('styles') if should_include_styles?
      
      # Render the main example template
      content = render_template('example')
      
      # Combine styles and content
      [styles, content].compact.join("\n")
    end

    def self.loader(registry = Zeitwerk::Registry)
      @loader ||= registry.loaders.each.find { |loader| loader.tag == 'rspec-html_messages' }
    end

    private

    def default_options
      {
        debug: false,
        force_diffable: nil,
        force_not_diffable: nil,
        rspec_diff_in_message: false
      }
    end

    def should_include_styles?
      # Always include styles for now, can be optimized later
      true
    end

    # Helper methods for templates
    def status
      example['status']
    end

    def status_class
      status == 'passed' ? 'passed' : 'failed'
    end

    def description
      example['description']
    end

    def file_path
      example['file_path']
    end

    def line_number
      example['line_number']
    end

    def details
      @details ||= example['details'] || {}
    end

    def matcher_name
      details['matcher_name'] || 'Unknown'
    end

    def matcher_type
      case matcher_name
      when /DSL::Matcher/
        'Custom DSL Matcher'
      when /BuiltIn/
        'Built-in Matcher'
      else
        'Matcher'
      end
    end

    def failure_message
      return nil unless status == 'failed'
      
      example.dig('exception', 'message')
    end

    def has_actual?
      details.key?('actual')
    end

    def actual_value
      @actual_value ||= deserialize_value(details['actual']) if has_actual?
    end

    def expected_value
      @expected_value ||= deserialize_value(details['expected']) if details.key?('expected')
    end

    def prettified_actual
      @prettified_actual ||= prettify_for_diff(actual_value)
    end

    def prettified_expected
      @prettified_expected ||= prettify_for_diff(expected_value)
    end

    def negated?
      details['negated'] || false
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

    # For the debug header template
    def effective_diffable
      effective_diffable?
    end
  end
end
