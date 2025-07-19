# frozen_string_literal: true

require 'oj'
require 'amazing_print'

module Rspec
  class HtmlMessages
    module ValueFormatter
      # Oj options for deserializing - use object mode to restore symbols
      # but keep safety options to prevent code execution
      OJ_LOAD_OPTIONS = {
        mode: :object,        # Restore Ruby objects and symbols
        auto_define: false,   # DON'T auto-create classes (safety)
        symbol_keys: false,   # Preserve symbols as they were serialized
        circular: true,       # Handle circular references
        create_additions: false, # Don't allow custom deserialization (safety)
        create_id: nil        # Disable create_id (safety)
      }.freeze

      def prettify_for_diff(value)
        case value
        when String
          # For strings, just return them as-is (not their inspect representation)
          value
        when nil
          'nil'
        else
          # Use amazing_print for complex objects
          # raw: true enables display of instance variables for custom objects
          # plain: true removes color codes
          # index: false removes array indices
          # indent: -2 reduces indentation to 2 spaces per level
          # sort_keys: true ensures consistent hash key ordering for better diffs
          # object_id: false removes object IDs for cleaner diffs
          value.awesome_inspect(
            plain: true,
            index: false,
            indent: -2,
            sort_keys: true,
            object_id: false,
            raw: true
          )
        end
      rescue StandardError
        # Fallback for any formatting errors
        value.to_s
      end

      def deserialize_value(serialized_value)
        return nil unless serialized_value

        Oj.load(serialized_value, OJ_LOAD_OPTIONS)
      rescue StandardError
        # If deserialization fails, return the original value
        serialized_value
      end
    end
  end
end