# frozen_string_literal: true

require "oj"
require "amazing_print"

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
        create_id: nil # Disable create_id (safety)
      }.freeze

      AWESOME_PRINT_OPTIONS = {
        plain: true,        # No color codes
        index: false,       # No array indices
        indent: -2,         # 2-space indentation
        sort_keys: true,    # Consistent hash ordering
        object_id: false,   # No object IDs
        raw: true # Show instance variables
      }

      def prettify_for_diff(value)
        case value
        when String then value
        when nil then "nil"
        else value.awesome_inspect(AWESOME_PRINT_OPTIONS)
        end
      end

      def deserialize_value(serialized_value)
        return nil unless serialized_value

        Oj.load(serialized_value, OJ_LOAD_OPTIONS)
      rescue
        serialized_value
      end
    end
  end
end
