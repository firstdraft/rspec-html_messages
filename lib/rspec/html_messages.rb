# frozen_string_literal: true

require 'zeitwerk'

Zeitwerk::Loader.new.then do |loader|
  loader.tag = 'rspec-html_messages'
  loader.push_dir "#{__dir__}/.."
  loader.setup
end

module Rspec
  # Main namespace.
  module HtmlMessages
    def self.loader(registry = Zeitwerk::Registry)
      @loader ||= registry.loaders.each.find { |loader| loader.tag == 'rspec-html_messages' }
    end
  end
end
