# frozen_string_literal: true

require 'diffy'

module Rspec
  class HtmlMessages
    module DiffFormatter
      # List of matchers that should show diffs even when diffable is false
      # Note: match_array and contain_exactly are aliases - both use ContainExactly
      FORCE_DIFFABLE = [
        'RSpec::Matchers::BuiltIn::ContainExactly'  # Used by both contain_exactly and match_array
      ].freeze

      # List of matchers to treat as non-diffable even when they report diffable: true
      # These matchers work better with simple expected/actual display
      FORCE_NOT_DIFFABLE = [
        'RSpec::Matchers::BuiltIn::Include'  # Include matcher shows what's missing, not a line-by-line diff
      ].freeze

      def should_force_diff?(matcher_name)
        return true if options[:force_diffable]&.include?(matcher_name)
        
        FORCE_DIFFABLE.include?(matcher_name)
      end

      def should_force_non_diffable?(matcher_name)
        return true if options[:force_not_diffable]&.include?(matcher_name)
        
        FORCE_NOT_DIFFABLE.include?(matcher_name)
      end

      def effective_diffable?
        return false if should_force_non_diffable?(matcher_name)
        return true if should_force_diff?(matcher_name)
        
        details['diffable']
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