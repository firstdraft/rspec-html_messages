# frozen_string_literal: true

ruby file: '.ruby-version'

source 'https://rubygems.org'

gemspec

group :quality do
  gem 'simplecov', '~> 0.22', require: false
  gem 'standard', '~> 1.40'
end

group :development do
  gem 'rake', '~> 13.3'
end

group :test do
  gem 'rspec', '~> 3.13'
end

group :tools do
  gem 'amazing_print', '~> 1.8'
  gem 'debug', '~> 1.11'
  gem 'irb-kit', '~> 1.1'
  gem 'repl_type_completor', '~> 0.1'
end
