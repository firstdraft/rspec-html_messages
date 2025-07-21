# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-01-21

### Added
- Initial release of rspec-html_messages gem
- Support for rendering RSpec enriched JSON output as HTML
- Bootstrap-styled HTML output with diffs, failure messages, and backtraces
- Configurable options for backtrace filtering and diff display
- Support for all major RSpec matchers including custom matchers
- Side-by-side diff comparison for diffable matchers
- Proper HTML escaping for security
- CSS for diff highlighting
- Methods for checking presence of output, failure messages, exceptions, and backtraces
- Flexible API with individual rendering methods for each section
