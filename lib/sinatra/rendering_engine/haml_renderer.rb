require 'haml' unless defined? ::Haml

module Sinatra
  module RenderingEngine
    class HamlRenderer < Base
      def render_template(template, data, options, &block)
        engine = ::Haml::Engine.new(data, options[:options] || {})
        engine.render(self, options[:locals] || {}, &block)
      end

      alias_method :render_layout, :render_template
    end
  end
end
