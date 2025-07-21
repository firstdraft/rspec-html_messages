# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rspec::HtmlMessages do
  # Test data helpers
  let(:passing_example) do
    {
      "id" => "spec/example_spec.rb[1:1]",
      "description" => "should equal 42",
      "status" => "passed",
      "file_path" => "spec/example_spec.rb",
      "line_number" => 5
    }
  end

  let(:passing_example_with_output) do
    {
      "id" => "spec/example_spec.rb[1:1]",
      "description" => "should equal 42",
      "status" => "passed",
      "file_path" => "spec/example_spec.rb",
      "line_number" => 5,
      "details" => {
        "expected" => '"42"',
        "actual" => '"42"',
        "matcher_name" => "RSpec::Matchers::BuiltIn::Eq"
      }
    }
  end

  let(:failing_example_with_diff) do
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

  let(:failing_example_without_diff) do
    {
      "id" => "spec/example_spec.rb[1:3]",
      "description" => "should include element",
      "status" => "failed",
      "file_path" => "spec/example_spec.rb",
      "line_number" => 15,
      "details" => {
        "expected" => '"missing"',
        "actual" => '["a", "b", "c"]',
        "matcher_name" => "RSpec::Matchers::BuiltIn::Include",
        "diffable" => true
      },
      "exception" => {
        "message" => "expected [\"a\", \"b\", \"c\"] to include \"missing\""
      }
    }
  end

  let(:error_before_assertion) do
    {
      "id" => "spec/example_spec.rb[1:4]",
      "description" => "encounters an error",
      "status" => "failed",
      "file_path" => "spec/example_spec.rb",
      "line_number" => 20,
      "exception" => {
        "class" => "NoMethodError",
        "message" => "undefined method `foo' for nil:NilClass",
        "backtrace" => [
          "/Users/test/project/spec/example_spec.rb:21:in `block (2 levels) in <top (required)>'",
          "/Users/test/.rvm/gems/ruby-3.0.0/gems/rspec-core-3.10.0/lib/rspec/core/example.rb:257:in `block in run'"
        ]
      }
    }
  end

  let(:negated_matcher_example) do
    {
      "id" => "spec/example_spec.rb[1:5]",
      "description" => "should not equal",
      "status" => "failed",
      "file_path" => "spec/example_spec.rb",
      "line_number" => 25,
      "details" => {
        "expected" => '"same"',
        "actual" => '"same"',
        "matcher_name" => "RSpec::Matchers::BuiltIn::Eq",
        "diffable" => true,
        "negated" => true
      },
      "exception" => {
        "message" => "expected: not \"same\"\n     got: \"same\"\n\n(compared using ==)"
      }
    }
  end

  describe "#has_output?" do
    it "returns false for passing tests" do
      renderer = described_class.new(passing_example)
      expect(renderer.has_output?).to be false
    end

    it "returns true for failing tests" do
      renderer = described_class.new(failing_example_with_diff)
      expect(renderer.has_output?).to be true
    end

    it "returns false for errors before assertions" do
      renderer = described_class.new(error_before_assertion)
      expect(renderer.has_output?).to be false
    end

    it "returns true when actual value is present even for passing tests" do
      renderer = described_class.new(passing_example_with_output)
      expect(renderer.has_output?).to be true
    end
  end

  describe "#has_failure_message?" do
    it "returns false for passing tests" do
      renderer = described_class.new(passing_example)
      expect(renderer.has_failure_message?).to be false
    end

    it "returns true for failing tests" do
      renderer = described_class.new(failing_example_with_diff)
      expect(renderer.has_failure_message?).to be true
    end

    it "returns false for errors before assertions" do
      renderer = described_class.new(error_before_assertion)
      expect(renderer.has_failure_message?).to be false
    end
  end

  describe "#has_exception_details?" do
    it "returns false for passing tests" do
      renderer = described_class.new(passing_example)
      expect(renderer.has_exception_details?).to be false
    end

    it "returns false for test failures" do
      renderer = described_class.new(failing_example_with_diff)
      expect(renderer.has_exception_details?).to be false
    end

    it "returns true for errors before assertions" do
      renderer = described_class.new(error_before_assertion)
      expect(renderer.has_exception_details?).to be true
    end
  end

  describe "#has_backtrace?" do
    it "returns false when no backtrace" do
      renderer = described_class.new(failing_example_with_diff)
      expect(renderer.has_backtrace?).to be false
    end

    it "returns true when backtrace exists" do
      renderer = described_class.new(error_before_assertion)
      expect(renderer.has_backtrace?).to be true
    end
  end

  describe "#output_html" do
    context "with passing test" do
      it "returns nil" do
        renderer = described_class.new(passing_example)
        expect(renderer.output_html).to be_nil
      end
    end

    context "with failing diffable test" do
      it "returns diff HTML" do
        renderer = described_class.new(failing_example_with_diff)
        html = renderer.output_html

        expect(html).to include("card-group")
        expect(html).to include("Expected")
        expect(html).to include("Expected")
        expect(html).to include("Actual")
        expect(html).to include("foo")
        expect(html).to include("bar")
      end
    end

    context "with non-diffable matcher" do
      it "returns actual value HTML" do
        renderer = described_class.new(failing_example_without_diff)
        html = renderer.output_html

        expect(html).not_to include("Side-by-Side Comparison")
        expect(html).to include("Actual")
        expect(html).to include("card-header")
        expect(html).to include("[")
        expect(html).to include("&quot;a&quot;")
      end
    end

    context "with force_diffable option" do
      it "shows diff even for non-diffable matchers" do
        renderer = described_class.new(failing_example_without_diff)
        html = renderer.output_html(force_diffable: ["RSpec::Matchers::BuiltIn::Include"])

        expect(html).to include("card-group")
        expect(html).to include("Expected")
      end
    end

    context "with negated matcher" do
      it "shows only actual value" do
        renderer = described_class.new(negated_matcher_example)
        html = renderer.output_html

        expect(html).not_to include("Side-by-Side Comparison")
        expect(html).to include("Actual")
        expect(html).to include("card-header")
      end
    end
  end

  describe "#failure_message_html" do
    context "with passing test" do
      it "returns nil" do
        renderer = described_class.new(passing_example)
        expect(renderer.failure_message_html).to be_nil
      end
    end

    context "with failing test" do
      it "returns failure message HTML" do
        renderer = described_class.new(failing_example_with_diff)
        html = renderer.failure_message_html

        expect(html).to include("failure-message")
        expect(html).to include("bg-warning text-bg-warning")
        expect(html).to include("expected: &quot;foo&quot;")
        expect(html).to include("got: &quot;bar&quot;")
      end
    end

    context "with error before assertion" do
      it "returns nil" do
        renderer = described_class.new(error_before_assertion)
        expect(renderer.failure_message_html).to be_nil
      end
    end

    context "with rspec_diff_in_message option" do
      it "includes RSpec diff when true" do
        example = failing_example_with_diff.dup
        example["exception"]["message"] += "\n\n  Diff:\n@@ -1,2 +1,2 @@\n-foo\n+bar"

        renderer = described_class.new(example)
        html = renderer.failure_message_html(rspec_diff_in_message: true)

        expect(html).to include("Diff:")
        expect(html).to include("@@")
      end

      it "strips RSpec diff by default" do
        example = failing_example_with_diff.dup
        example["exception"]["message"] += "\n\n  Diff:\n@@ -1,2 +1,2 @@\n-foo\n+bar"

        renderer = described_class.new(example)
        html = renderer.failure_message_html

        expect(html).not_to include("Diff:")
        expect(html).not_to include("@@")
      end
    end
  end

  describe "#exception_details_html" do
    context "with test failure" do
      it "returns nil" do
        renderer = described_class.new(failing_example_with_diff)
        expect(renderer.exception_details_html).to be_nil
      end
    end

    context "with error before assertion" do
      it "returns exception HTML" do
        renderer = described_class.new(error_before_assertion)
        html = renderer.exception_details_html

        expect(html).to include("undefined method `foo&#39;")
        expect(html).to include("NoMethodError on line 21")
        expect(html).to include("bg-danger text-bg-danger")
        expect(html).to include("text-danger")
      end
    end
  end

  describe "#backtrace_html" do
    context "without backtrace" do
      it "returns nil" do
        renderer = described_class.new(failing_example_with_diff)
        expect(renderer.backtrace_html).to be_nil
      end
    end

    context "with backtrace" do
      it "returns backtrace HTML" do
        renderer = described_class.new(error_before_assertion)
        html = renderer.backtrace_html

        expect(html).to include("Backtrace:")
        expect(html).to include("spec/example_spec.rb:21")
        expect(html).to include("bg-dark")
      end

      it "respects backtrace_max_lines option" do
        example = error_before_assertion.dup
        example["exception"]["backtrace"] = (1..20).map { |i| "line #{i}" }

        renderer = described_class.new(example)
        html = renderer.backtrace_html(backtrace_max_lines: 5)

        expect(html).to include("line 1")
        expect(html).to include("line 5")
        expect(html).not_to include("line 6")
        expect(html).to include("more frames omitted")
      end
    end
  end

  describe "#render_html" do
    it "combines all sections for failing test" do
      renderer = described_class.new(failing_example_with_diff)
      html = renderer.render_html

      expect(html).to include('<div class="rspec-html-messages">')
      expect(html).to include("Actual")
      expect(html).to include("Expected")
      expect(html).to include("Test failure message")
      expect(html).not_to include("Code error details")
    end

    it "shows only exception for errors" do
      renderer = described_class.new(error_before_assertion)
      html = renderer.render_html

      expect(html).to include('<div class="rspec-html-messages">')
      expect(html).not_to include("Output")
      expect(html).not_to include("Test failure message")
      expect(html).to include("Error in code")
    end

    it "returns minimal HTML for passing tests" do
      renderer = described_class.new(passing_example)
      html = renderer.render_html

      expect(html).to include('<div class="rspec-html-messages">')
      expect(html).not_to include("Output")
      expect(html).not_to include("Test failure message")
      expect(html).not_to include("Code error details")
    end
  end

  describe "HTML escaping" do
    it "escapes HTML in failure messages" do
      example = failing_example_with_diff.dup
      example["exception"]["message"] = 'expected: "<script>alert(1)</script>"'

      renderer = described_class.new(example)
      html = renderer.failure_message_html

      expect(html).to include("&lt;script&gt;")
      expect(html).not_to include("<script>")
    end

    it "escapes HTML in exception messages" do
      example = error_before_assertion.dup
      example["exception"]["message"] = "undefined method `<script>alert(1)</script>`"

      renderer = described_class.new(example)
      html = renderer.exception_details_html

      expect(html).to include("&lt;script&gt;")
      expect(html).not_to include("<script>")
    end
  end

  describe ".diff_css" do
    it "returns CSS string" do
      css = described_class.diff_css
      expect(css).to include(".diff")
      expect(css).to include("del")
      expect(css).to include("ins")
    end
  end
end
