# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rspec::HtmlMessages do
  describe "#render" do
    context "with a simple passing example" do
      let(:example_json) do
        {
          "id" => "spec/example_spec.rb[1:1]",
          "description" => "should equal 42",
          "status" => "passed",
          "file_path" => "spec/example_spec.rb",
          "line_number" => 5
        }
      end

      it "renders the expected HTML" do
        actual = described_class.new(example_json).render

        # For now, just check that it includes the key elements
        expect(actual).to include("<style>")
        expect(actual).to include('<div class="example passed">')
        expect(actual).to include("✓")
        expect(actual).to include("should equal 42")
        expect(actual).to include("spec/example_spec.rb:5")
      end
    end

    context "with a failing example with diff" do
      let(:example_json) do
        {
          "id" => "spec/example_spec.rb[1:2]",
          "description" => "should match",
          "status" => "failed",
          "file_path" => "spec/example_spec.rb",
          "line_number" => 10,
          "details" => {
            "expected" => '"foo"',
            "actual" => '"bar"',
            "matcher_name" => "RSpec::Matchers::BuiltIn::Eq",
            "diffable" => true
          },
          "exception" => {
            "message" => "expected: \"foo\"\n     got: \"bar\"\n\n(compared using ==)"
          }
        }
      end

      it "renders the expected HTML with diff" do
        actual = described_class.new(example_json).render

        # Check for key failure elements
        expect(actual).to include('<div class="example failed">')
        expect(actual).to include("✗")
        expect(actual).to include("should match")

        # Check for diff
        expect(actual).to include('<div class="diff-container">')
        expect(actual).to include("Expected")
        expect(actual).to include("Actual")

        # Check for failure message
        expect(actual).to include("failure-message")
        expect(actual).to include("expected: &quot;foo&quot;")
        expect(actual).to include("got: &quot;bar&quot;")
      end
    end
  end
end
