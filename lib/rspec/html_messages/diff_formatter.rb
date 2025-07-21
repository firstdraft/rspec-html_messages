# frozen_string_literal: true

require "diffy"

module Rspec
  class HtmlMessages
    module DiffFormatter
      def effective_diffable?(force_diffable: [], force_not_diffable: [])
        return true if force_diffable&.include?(matcher_name)
        return false if force_not_diffable&.include?(matcher_name)

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
