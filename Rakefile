# frozen_string_literal: true

require "bundler/setup"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new { |task| task.verbose = false }

desc "Run code quality checks"
task quality: %i[]

task default: %i[quality spec]
