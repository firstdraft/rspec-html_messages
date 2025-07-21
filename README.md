# RSpec HTML Messages

[![CI](https://github.com/firstdraft/rspec-html_messages/actions/workflows/ci.yml/badge.svg)](https://github.com/firstdraft/rspec-html_messages/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/rspec-html_messages.svg)](https://badge.fury.io/rb/rspec-html_messages)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/standardrb/standard)

Transform RSpec's JSON output into formatted HTML with syntax highlighting, side-by-side diffs, and Bootstrap styling.

## Overview

`rspec-html_messages` takes the enriched JSON output from [`rspec-enriched_json`](https://github.com/firstdraft/rspec-enriched_json) and renders it as HTML. It provides:

- 🎨 **Beautiful formatting** - Clean, Bootstrap-styled output.
- 🔍 **Side-by-side diffs** - Visual comparison of expected vs actual values.
- 📊 **Smart data rendering** - Pretty-printing for complex objects.
- 🧩 **Composable API** - Use individual components or the full renderer.
- ⚙️ **Flexible options** - Control diff display and message formatting.

## Installation

Add to your Gemfile:

```ruby
gem "rspec-html_messages"
```

Or install directly:

```bash
$ gem install rspec-html_messages
```

## Usage

### Basic Usage

```ruby
require "rspec/html_messages"

# Get enriched JSON from RSpec
# (typically from running with rspec-enriched_json formatter)
example_json = {
  "id" => "spec/example_spec.rb[1:1]",
  "description" => "should equal 42",
  "status" => "failed",
  "file_path" => "spec/example_spec.rb",
  "line_number" => 10,
  "details" => {
    "expected" => '"42"',
    "actual" => '"41"',
    "matcher_name" => "RSpec::Matchers::BuiltIn::Eq",
    "diffable" => true
  },
  "exception" => {
    "message" => "expected: \"42\"\n     got: \"41\"\n\n(compared using ==)"
  }
}

# Render as HTML
renderer = Rspec::HtmlMessages.new(example_json)
html = renderer.render_html

# Output includes styled HTML with diff
puts html
```

### Using Individual Components

The gem provides a composable API where you can use individual components to build your own custom layouts:

```ruby
renderer = Rspec::HtmlMessages.new(example_json)

# Check what content is available
if renderer.has_output?
  output_html = renderer.output_html
end

if renderer.has_failure_message?
  failure_html = renderer.failure_message_html
end

if renderer.has_exception_details?
  exception_html = renderer.exception_details_html
end

if renderer.has_backtrace?
  exception_html = renderer.backtrace_html
end

# Build your own custom layout
html = <<~HTML
  <div class="my-custom-test-result">
    #{output_html if renderer.has_output?}
    #{failure_html if renderer.has_failure_message?}
    #{exception_html if renderer.has_exception_details?}
  </div>
HTML
```

### Options

You can customize the rendering with various options:

```ruby
# Options can be passed to the render_html method
html = renderer.render_html(
  force_diffable: ["CustomMatcher"],  # Array of matchers to always show diffs for
  force_not_diffable: ["RSpec::Matchers::BuiltIn::Include"],  # Array of matchers to never show diffs for
  rspec_diff_in_message: true,   # Include RSpec's text diff in failure message (default: false)
  backtrace_max_lines: 10,       # Maximum backtrace lines to show (default: 10)
  backtrace_silence_gems: true   # Filter out gem frames from backtraces (default: true)
)

# Or to individual component methods
output_html = renderer.output_html(force_diffable: ["CustomMatcher"])
```

#### Option Details

- **`force_diffable`**: Array of matcher class names that should always show diffs, even if they report as non-diffable
  - Default: `["RSpec::Matchers::BuiltIn::ContainExactly"]` (used by `contain_exactly` and `match_array`)
  - Override by passing your own array

- **`force_not_diffable`**: Array of matcher class names that should never show diffs, even if they report as diffable
  - Default: `["RSpec::Matchers::BuiltIn::Include"]` (the `include` matcher shows what's missing more clearly than a diff)
  - Override by passing your own array

- **`rspec_diff_in_message`**: By default, RSpec's text-based diff is stripped from failure messages since we show a visual diff. Set to `true` to keep it

- **`backtrace_max_lines`**: Maximum number of backtrace lines to display for errors
  - Default: `10`
  - Set to a higher number to see more of the stack trace

- **`backtrace_silence_gems`**: Whether to filter out gem frames from backtraces
  - Default: `true` (hides frames from installed gems)
  - Set to `false` to see the complete backtrace including gem internals

### Complete Example

Here's a complete example that processes RSpec output and generates an HTML report:

```ruby
require "json"
require "rspec/html_messages"

# Run RSpec with enriched JSON formatter
json_output = `bundle exec rspec --require rspec/enriched_json \
  -f RSpec::EnrichedJson::Formatters::EnrichedJsonFormatter`

# Parse the JSON
results = JSON.parse(json_output)

# Generate HTML report
html = <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>RSpec Results</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
  <div class="container my-4">
    <h1>Test Results</h1>
    <p>#{results["summary_line"]}</p>
    
HTML

# Render each example
results["examples"].each do |example|
  renderer = Rspec::HtmlMessages.new(example)
  html << <<~EXAMPLE
    <div class="mb-4">
      <h3>#{example["description"]}</h3>
      #{renderer.render_html}
    </div>
  EXAMPLE
end

html << <<~HTML
  </div>
</body>
</html>
HTML

File.write("rspec_results.html", html)
```

## Output Examples

### Passing Test

For a passing test, you'll see:
- ✓ Green checkmark and background
- Test description and file location
- No failure message or diff

### Failing Test with Diff

For a failing test with diffable values:
- ✗ Red X and background  
- Test description and file location
- Side-by-side comparison showing differences
- Failure message (with RSpec's diff stripped by default)

### Error Display

For tests that encounter errors (exceptions) before assertions:
- Exception class name highlighted in red
- Stack trace with configurable depth
- Gem frames filtered by default (configurable)

## Working with rspec-enriched_json

This gem is designed to work with [`rspec-enriched_json`](https://github.com/firstdraft/rspec-enriched_json), which provides structured data about test failures including:

- Expected and actual values as structured data (not just strings)
- Matcher information
- Diffable status
- Original failure messages

To use both gems together:

1. Add both gems to your Gemfile:
   ```ruby
   gem "rspec-enriched_json"
   gem "rspec-html_messages"
   ```

2. Run RSpec with the enriched JSON formatter:
   ```bash
   bundle exec rspec --require rspec/enriched_json \
     -f RSpec::EnrichedJson::Formatters::EnrichedJsonFormatter
   ```

3. Process the output with rspec-html_messages as shown in the examples above

## API Reference

### Instance Methods

#### `new(example)`
Creates a new renderer instance with the example JSON data.

#### `has_output?`
Returns `true` if the example has output to display (failed tests or tests with actual values).

#### `has_failure_message?`
Returns `true` if the example has a failure message to display.

#### `has_exception_details?`
Returns `true` if the example has exception/error details to display.

#### `has_backtrace?`
Returns `true` if the example has a backtrace to display.

#### `output_html(**options)`
Renders just the output section (diff or actual value). Returns `nil` if no output to display.

#### `failure_message_html(**options)`
Renders just the failure message section. Returns `nil` if no failure message.

#### `exception_details_html(**options)`
Renders just the exception details section. Returns `nil` if no exception.

#### `backtrace_html(**options)`
Renders just the backtrace section. Returns `nil` if no backtrace.

#### `render_html(**options)`
Convenience method that renders all three sections in a standard layout.

### Class Methods

#### `Rspec::HtmlMessages.diff_css`
Returns the CSS needed for diff display styling.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/firstdraft/rspec-html_messages.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
