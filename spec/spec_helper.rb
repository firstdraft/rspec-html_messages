# frozen_string_literal: true

require "simplecov"

unless ENV["NO_COVERAGE"]
  SimpleCov.start do
    add_filter %r{^/spec/}
    enable_coverage :branch
    enable_coverage_for_eval
    minimum_coverage line: 95
    minimum_coverage_by_file line: 90, branch: 60
  end
end

Bundler.require :tools

require "rspec/html_messages"
require "rspec/snapshot"

SPEC_ROOT = Pathname(__dir__).realpath.freeze

Dir[SPEC_ROOT.join("support/shared_contexts/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.color = true
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "./tmp/rspec-examples.txt"
  config.filter_run_when_matching :focus
  config.formatter = (ENV.fetch("CI", false) == "true") ? :progress : :documentation
  config.order = :random
  config.pending_failure_output = :no_backtrace
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true

  # Configure rspec-snapshot
  config.include RSpec::Snapshot
  config.snapshot_dir = "spec/fixtures/snapshots"

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
end
