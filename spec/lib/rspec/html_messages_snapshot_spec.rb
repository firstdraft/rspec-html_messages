# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Rspec::HtmlMessages snapshots" do
  def render_and_format(example_data, **options)
    renderer = Rspec::HtmlMessages.new(example_data)
    html = renderer.render_html(**options)
    # Format the HTML for consistent snapshots
    formatted = html
      .gsub(/>\s+</, ">\n<")
      .gsub(/\s+/, " ")
      .strip
    formatted
  end

  describe "passing tests" do
    it "renders a simple passing test" do
      example = {
        "id" => "spec/example_spec.rb[1:1]",
        "description" => "should equal 42",
        "status" => "passed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 5
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("passing_test")
    end

    it "renders a passing test with output" do
      example = {
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

      html = render_and_format(example)
      expect(html).to match_snapshot("passing_test_with_output")
    end
  end

  describe "failing tests with diffs" do
    it "renders string comparison failure" do
      example = {
        "id" => "spec/example_spec.rb[1:2]",
        "description" => "should match strings",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 10,
        "details" => {
          "expected" => '"Hello, World!"',
          "actual" => '"Hello, Ruby!"',
          "matcher_name" => "RSpec::Matchers::BuiltIn::Eq",
          "diffable" => true
        },
        "exception" => {
          "message" => "expected: \"Hello, World!\"\n     got: \"Hello, Ruby!\"\n\n(compared using ==)"
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("string_diff")
    end

    it "renders array comparison failure" do
      example = {
        "id" => "spec/example_spec.rb[1:3]",
        "description" => "should match arrays",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 15,
        "details" => {
          "expected" => '[1, 2, 3, 4]',
          "actual" => '[1, 2, 5, 4]',
          "matcher_name" => "RSpec::Matchers::BuiltIn::Eq",
          "diffable" => true
        },
        "exception" => {
          "message" => "expected: [1, 2, 3, 4]\n     got: [1, 2, 5, 4]\n\n(compared using ==)"
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("array_diff")
    end

    it "renders hash comparison failure" do
      example = {
        "id" => "spec/example_spec.rb[1:4]",
        "description" => "should match hashes",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 20,
        "details" => {
          "expected" => '{"name": "Alice", "age": 30, "city": "NYC"}',
          "actual" => '{"name": "Alice", "age": 25, "city": "NYC"}',
          "matcher_name" => "RSpec::Matchers::BuiltIn::Eq",
          "diffable" => true
        },
        "exception" => {
          "message" => "expected: {\"name\"=>\"Alice\", \"age\"=>30, \"city\"=>\"NYC\"}\n     got: {\"name\"=>\"Alice\", \"age\"=>25, \"city\"=>\"NYC\"}\n\n(compared using ==)"
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("hash_diff")
    end
  end

  describe "non-diffable matchers" do
    it "renders include matcher failure" do
      example = {
        "id" => "spec/example_spec.rb[1:5]",
        "description" => "should include element",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 25,
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

      html = render_and_format(example)
      expect(html).to match_snapshot("include_matcher")
    end

    it "renders compound matcher failure" do
      example = {
        "id" => "spec/example_spec.rb[1:6]",
        "description" => "should satisfy compound condition",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 30,
        "details" => {
          "expected" => '(be > 5) and (be < 10)',
          "actual" => '3',
          "matcher_name" => "RSpec::Matchers::BuiltIn::Compound::And",
          "diffable" => false
        },
        "exception" => {
          "message" => "expected 3 to be > 5 and be < 10"
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("compound_matcher")
    end
  end

  describe "exceptions and errors" do
    it "renders error before assertion" do
      example = {
        "id" => "spec/example_spec.rb[1:7]",
        "description" => "encounters an error",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 35,
        "exception" => {
          "class" => "NoMethodError",
          "message" => "undefined method `foo' for nil:NilClass",
          "backtrace" => [
            "/Users/test/project/spec/example_spec.rb:36:in `block (2 levels) in <top (required)>'",
            "/Users/test/.rvm/gems/ruby-3.0.0/gems/rspec-core-3.10.0/lib/rspec/core/example.rb:257:in `block in run'",
            "/Users/test/.rvm/gems/ruby-3.0.0/gems/rspec-core-3.10.0/lib/rspec/core/example.rb:503:in `instance_exec'",
            "/Users/test/.rvm/gems/ruby-3.0.0/gems/rspec-core-3.10.0/lib/rspec/core/hooks.rb:390:in `execute_with'",
            "/Users/test/.rvm/gems/ruby-3.0.0/gems/rspec-core-3.10.0/lib/rspec/core/hooks.rb:628:in `block (2 levels) in run_around_example_hooks_for'"
          ]
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("error_exception")
    end

    it "renders custom error" do
      example = {
        "id" => "spec/example_spec.rb[1:8]",
        "description" => "raises custom error",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 40,
        "exception" => {
          "class" => "MyApp::ValidationError",
          "message" => "Invalid configuration: missing required field 'api_key'",
          "backtrace" => [
            "/Users/test/project/lib/my_app/config.rb:15:in `validate!'",
            "/Users/test/project/spec/example_spec.rb:41:in `block (2 levels) in <top (required)>'"
          ]
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("custom_error")
    end
  end

  describe "with custom options" do
    it "renders with rspec diff in message" do
      example = {
        "id" => "spec/example_spec.rb[1:9]",
        "description" => "shows RSpec diff in message",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 45,
        "details" => {
          "expected" => '"foo"',
          "actual" => '"bar"',
          "matcher_name" => "RSpec::Matchers::BuiltIn::Eq",
          "diffable" => true
        },
        "exception" => {
          "message" => "expected: \"foo\"\n     got: \"bar\"\n\n(compared using ==)\n\nDiff:\n@@ -1 +1 @@\n-\"foo\"\n+\"bar\"\n"
        }
      }

      html = render_and_format(example, rspec_diff_in_message: true)
      expect(html).to match_snapshot("with_rspec_diff")
    end

    it "renders forced diffable matcher" do
      example = {
        "id" => "spec/example_spec.rb[1:10]",
        "description" => "forces diff for contain_exactly",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 50,
        "details" => {
          "expected" => '[1, 2, 3]',
          "actual" => '[1, 3, 2]',
          "matcher_name" => "RSpec::Matchers::BuiltIn::ContainExactly",
          "diffable" => false # Normally false, but forced to true
        },
        "exception" => {
          "message" => "expected collection contained: [1, 2, 3]\n     actual collection contained: [1, 3, 2]\n     the missing elements were: [2]\n     the extra elements were: [3]"
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("forced_diffable")
    end

    it "renders with limited backtrace" do
      example = {
        "id" => "spec/example_spec.rb[1:11]",
        "description" => "shows limited backtrace",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 55,
        "exception" => {
          "class" => "RuntimeError",
          "message" => "Something went wrong",
          "backtrace" => Array.new(20) { |i| "/Users/test/project/lib/file#{i}.rb:#{i}:in `method#{i}'" }
        }
      }

      html = render_and_format(example, backtrace_max_lines: 5)
      expect(html).to match_snapshot("limited_backtrace")
    end
  end

  describe "special cases" do
    it "renders negated matcher" do
      example = {
        "id" => "spec/example_spec.rb[1:12]",
        "description" => "should not equal",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 60,
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

      html = render_and_format(example)
      expect(html).to match_snapshot("negated_matcher")
    end

    it "renders custom failure message" do
      example = {
        "id" => "spec/example_spec.rb[1:13]",
        "description" => "validates with custom message",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 65,
        "details" => {
          "expected" => '100',
          "actual" => '50',
          "matcher_name" => "RSpec::Matchers::BuiltIn::BeComparedTo",
          "diffable" => false,
          "original_message" => "expected: >= 100\n     got:    50"
        },
        "exception" => {
          "message" => "Insufficient funds: $50 available, $100 required"
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("custom_message")
    end

    it "renders HTML-escaped content" do
      example = {
        "id" => "spec/example_spec.rb[1:14]",
        "description" => "handles HTML content",
        "status" => "failed",
        "file_path" => "spec/example_spec.rb",
        "line_number" => 70,
        "details" => {
          "expected" => '"<div>Expected</div>"',
          "actual" => '"<script>alert(\'XSS\')</script>"',
          "matcher_name" => "RSpec::Matchers::BuiltIn::Eq",
          "diffable" => true
        },
        "exception" => {
          "message" => "expected: \"<div>Expected</div>\"\n     got: \"<script>alert('XSS')</script>\"\n\n(compared using ==)"
        }
      }

      html = render_and_format(example)
      expect(html).to match_snapshot("html_escaped")
    end
  end
end