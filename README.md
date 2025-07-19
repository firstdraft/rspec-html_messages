# RSpec HTML Messages

Transform RSpec's JSON output into beautifully formatted HTML with syntax highlighting, side-by-side diffs, and Bootstrap styling.

## Overview

`rspec-html_messages` takes the enriched JSON output from [`rspec-enriched_json`](https://github.com/firstdraft/rspec-enriched_json) and renders it as HTML. It provides:

- 🎨 **Beautiful formatting** - Clean, Bootstrap-styled output
- 🔍 **Side-by-side diffs** - Visual comparison of expected vs actual values
- 📊 **Smart data rendering** - Pretty-printing for complex objects
- 🐛 **Debug mode** - See matcher details and raw JSON data
- ⚙️ **Flexible options** - Control diff display and message formatting

## Installation

Add to your Gemfile:

```ruby
gem 'rspec-html_messages'
```

Or install directly:

```bash
$ gem install rspec-html_messages
```

## Usage

### Basic Usage

```ruby
require 'rspec/html_messages'

# Get enriched JSON from RSpec
# (typically from running with rspec-enriched_json formatter)
example_json = {
  'id' => 'spec/example_spec.rb[1:1]',
  'description' => 'should equal 42',
  'status' => 'failed',
  'file_path' => 'spec/example_spec.rb',
  'line_number' => 10,
  'details' => {
    'expected' => '"42"',
    'actual' => '"41"',
    'matcher_name' => 'RSpec::Matchers::BuiltIn::Eq',
    'diffable' => true
  },
  'exception' => {
    'message' => 'expected: "42"\n     got: "41"\n\n(compared using ==)'
  }
}

# Render as HTML
renderer = Rspec::HtmlMessages.new(example_json)
html = renderer.render

# Output includes styled HTML with diff
puts html
```

### Options

You can customize the rendering with various options:

```ruby
html = renderer.render(
  debug: true,                    # Show debug information (default: false)
  force_diffable: ["CustomMatcher"],  # Array of matchers to always show diffs for
  force_not_diffable: ["RSpec::Matchers::BuiltIn::Include"],  # Array of matchers to never show diffs for
  rspec_diff_in_message: true    # Include RSpec's text diff in failure message (default: false)
)
```

#### Option Details

- **`debug`**: When `true`, displays additional information including the matcher class, diffable status, and raw JSON data

- **`force_diffable`**: Array of matcher class names that should always show diffs, even if they report as non-diffable
  - Default: `["RSpec::Matchers::BuiltIn::ContainExactly"]` (used by `contain_exactly` and `match_array`)
  - Override by passing your own array

- **`force_not_diffable`**: Array of matcher class names that should never show diffs, even if they report as diffable
  - Default: `["RSpec::Matchers::BuiltIn::Include"]` (the `include` matcher shows what's missing more clearly than a diff)
  - Override by passing your own array

- **`rspec_diff_in_message`**: By default, RSpec's text-based diff is stripped from failure messages since we show a visual diff. Set to `true` to keep it

### Complete Example

Here's a complete example that processes RSpec output and generates an HTML report:

```ruby
require 'json'
require 'rspec/html_messages'

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
    <p>#{results['summary_line']}</p>
    
HTML

# Render each example
results['examples'].each do |example|
  renderer = Rspec::HtmlMessages.new(example)
  html << renderer.render(debug: ENV['DEBUG'])
end

html << <<~HTML
  </div>
</body>
</html>
HTML

File.write('rspec_results.html', html)
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

### Debug Mode

With `debug: true`, additional information is displayed:
- Matcher class name (e.g., `RSpec::Matchers::BuiltIn::Eq`)
- Whether the matcher is diffable
- Collapsible section with raw JSON data

## Working with rspec-enriched_json

This gem is designed to work with [`rspec-enriched_json`](https://github.com/firstdraft/rspec-enriched_json), which provides structured data about test failures including:

- Expected and actual values as structured data (not just strings)
- Matcher information
- Diffable status
- Original failure messages

To use both gems together:

1. Add both gems to your Gemfile:
   ```ruby
   gem 'rspec-enriched_json'
   gem 'rspec-html_messages'
   ```

2. Run RSpec with the enriched JSON formatter:
   ```bash
   bundle exec rspec --require rspec/enriched_json \
     -f RSpec::EnrichedJson::Formatters::EnrichedJsonFormatter
   ```

3. Process the output with rspec-html_messages as shown in the examples above

## Customization

### Templates

The gem uses ERB templates for rendering. The templates are located in `lib/rspec/html_messages/templates/`:

- `example.html.erb` - Main template for each test example
- `_styles.html.erb` - CSS styles (includes Diffy styles)
- `_debug_header.html.erb` - Debug information header
- `_diff.html.erb` - Side-by-side diff display
- `_actual.html.erb` - Actual value display (for non-diffable failures)
- `_failure_message.html.erb` - Failure message display
- `_raw_json.html.erb` - Raw JSON display for debug mode

### Styling

The output uses Bootstrap 5 classes and includes custom styles for:
- Example containers (`.example.passed`, `.example.failed`)
- Status icons
- Diff display (using Diffy's CSS)
- Terminal-style output for failure messages

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/firstdraft/rspec-html_messages.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).