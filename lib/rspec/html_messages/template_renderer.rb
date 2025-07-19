# frozen_string_literal: true

require 'action_view'

module Rspec
  class HtmlMessages
    module TemplateRenderer
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::OutputSafetyHelper

      def render_template(template_name, locals = {})
        template_path = template_path_for(template_name)
        erb = ERB.new(File.read(template_path))
        
        # Create a binding with access to helper methods and locals
        binding_with_locals = binding
        locals.each do |key, value|
          binding_with_locals.local_variable_set(key, value)
        end
        
        erb.result(binding_with_locals)
      end

      def render_partial(partial_name)
        render_template("_#{partial_name}")
      end

      private

      def template_path_for(template_name)
        File.join(templates_dir, "#{template_name}.html.erb")
      end

      def templates_dir
        @templates_dir ||= File.expand_path('templates', __dir__)
      end

      def html_escape(text)
        ERB::Util.html_escape(text)
      end
    end
  end
end