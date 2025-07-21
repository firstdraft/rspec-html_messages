# frozen_string_literal: true

require_relative "lib/rspec/html_messages/version"

Gem::Specification.new do |spec|
  spec.name = "rspec-html_messages"
  spec.version = Rspec::HtmlMessages::VERSION
  spec.authors = ["Raghu Betina"]
  spec.email = ["raghu@firstdraft.com"]
  spec.homepage = "https://github.com/firstdraft/rspec-html_messages"
  spec.summary = "HTML formatting for RSpec enriched JSON output"
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/firstdraft/rspec-html_messages/issues",
    "changelog_uri" => "https://github.com/firstdraft/rspec-html_messages/blob/main/CHANGELOG.md",
    "label" => "Rspec Html Messages",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/firstdraft/rspec-html_messages"
  }

  spec.required_ruby_version = "~> 3.0"
  spec.add_dependency "actionview", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"
  spec.add_dependency "amazing_print", "~> 1.6"
  spec.add_dependency "diffy", "~> 3.4"
  spec.add_dependency "oj", "~> 3.16"
  spec.add_dependency "zeitwerk", "~> 2.7"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
