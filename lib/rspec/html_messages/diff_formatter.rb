# frozen_string_literal: true

require "diffy"

module Rspec
  class HtmlMessages
    module DiffFormatter
      def effective_diffable?
        return true if options[:force_diffable]&.include?(matcher_name)
        return false if options[:force_not_diffable]&.include?(matcher_name)
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
