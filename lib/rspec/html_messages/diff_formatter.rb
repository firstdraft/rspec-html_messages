# frozen_string_literal: true

require "diffy"

module Rspec
  class HtmlMessages
    module DiffFormatter

      def effective_diffable?
        # Check if this matcher is in the force_diffable list
        return true if options[:force_diffable]&.include?(matcher_name)

        # Check if this matcher is in the force_not_diffable list
        return false if options[:force_not_diffable]&.include?(matcher_name)

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
