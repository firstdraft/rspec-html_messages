# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rspec::HtmlMessages::ValueFormatter do
  # Create a test class that includes the module
  let(:formatter_class) do
    Class.new do
      include Rspec::HtmlMessages::ValueFormatter

      attr_accessor :options

      def initialize(options = {})
        @options = options
      end
    end
  end

  let(:formatter) { formatter_class.new }

  describe '#deserialize_value' do
    it 'deserializes JSON strings' do
      expect(formatter.deserialize_value('"hello"')).to eq('hello')
    end

    it 'deserializes JSON numbers' do
      expect(formatter.deserialize_value('42')).to eq(42)
    end

    it 'deserializes JSON arrays' do
      expect(formatter.deserialize_value('["a", "b", "c"]')).to eq(%w[a b c])
    end

    it 'deserializes JSON objects' do
      expect(formatter.deserialize_value('{"a": 1, "b": 2}')).to eq({ 'a' => 1, 'b' => 2 })
    end

    it 'deserializes nil' do
      expect(formatter.deserialize_value('null')).to be_nil
    end

    it 'returns string "nil" as-is when not valid JSON' do
      expect(formatter.deserialize_value('nil')).to eq('nil')
    end

    it 'returns original value if deserialization fails' do
      expect(formatter.deserialize_value('not json')).to eq('not json')
    end
  end

  describe '#prettify_for_diff' do
    it 'returns strings as-is' do
      expect(formatter.prettify_for_diff('hello world')).to eq('hello world')
    end

    it 'pretty prints hashes' do
      hash = { 'name' => 'John', 'age' => 30 }
      result = formatter.prettify_for_diff(hash)
      expect(result).to include('"age"')
      expect(result).to include('30')
      expect(result).to include('"name"')
      expect(result).to include('"John"')
    end

    it 'pretty prints arrays' do
      array = %w[apple banana cherry]
      result = formatter.prettify_for_diff(array)
      expect(result).to include('[')
      expect(result).to include('"apple"')
      expect(result).to include('"banana"')
      expect(result).to include('"cherry"')
      expect(result).to include(']')
    end

    it 'handles nil' do
      expect(formatter.prettify_for_diff(nil)).to eq('nil')
    end

    it 'handles complex nested structures' do
      data = {
        'users' => [
          { 'name' => 'Alice', 'id' => 1 },
          { 'name' => 'Bob', 'id' => 2 }
        ]
      }
      result = formatter.prettify_for_diff(data)
      expect(result).to include('"users"')
      expect(result).to include('"name"')
      expect(result).to include('"Alice"')
      expect(result).to include('"id"')
      expect(result).to include('1')
    end
  end
end
