# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rspec::HtmlMessages do
  describe "#render_html" do
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

      it "renders minimal output for passing tests" do
        actual = described_class.new(example_json).render_html

        # Passing tests should have empty output (no diff, no failure message, no exception)
        expect(actual).to eq("<div class=\"rspec-html-messages\">\n  \n\n  \n\n  \n</div>\n")
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

      it "renders diff and failure message sections" do
        actual = described_class.new(example_json).render_html

        # Should contain the wrapper
        expect(actual).to include('<div class="rspec-html-messages">')

        # Check for diff section
        expect(actual).to include('<div class="diff-container">')
        expect(actual).to include("Side-by-Side Comparison")
        expect(actual).to include("Expected")
        expect(actual).to include("Actual")

        # Check for failure message section
        expect(actual).to include("Failure Message")
        expect(actual).to include("failure-message bg-dark text-white")
        expect(actual).to include("expected: &quot;foo&quot;")
        expect(actual).to include("got: &quot;bar&quot;")
      end
    end
  end
end
