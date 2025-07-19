# frozen_string_literal: true

require "diffy"

module Rspec
  class HtmlMessages
    module DiffFormatter
      # List of matchers that should show diffs even when diffable is false
      # Note: match_array and contain_exactly are aliases - both use ContainExactly
      FORCE_DIFFABLE = [
        "RSpec::Matchers::BuiltIn::ContainExactly"  # Used by both contain_exactly and match_array
      ].freeze

      # List of matchers to treat as non-diffable even when they report diffable: true
      # These matchers work better with simple expected/actual display
      FORCE_NOT_DIFFABLE = [
        "RSpec::Matchers::BuiltIn::Include"  # Include matcher shows what's missing, not a line-by-line diff
      ].freeze

      def effective_diffable?
        # Handle simple boolean options first
        return true if options[:force_diffable] == true
        return false if options[:force_not_diffable] == true

        # Handle array-based options for specific matchers
        if options[:force_diffable].is_a?(Array) && options[:force_diffable].include?(matcher_name)
          return true
        end

        if options[:force_not_diffable].is_a?(Array) && options[:force_not_diffable].include?(matcher_name)
          return false
        end

        # Check hardcoded lists
        return true if FORCE_DIFFABLE.include?(matcher_name)
        return false if FORCE_NOT_DIFFABLE.include?(matcher_name)

        # Default to the matcher's own diffable setting
        details["diffable"]
      end

      def create_diff(actual_value, expected_value)
        split_diff = Diffy::SplitDiff.new(actual_value, expected_value, format: :html)

        {
          left: split_diff.left,
          right: split_diff.right
        }
      end
    end
  end
end
