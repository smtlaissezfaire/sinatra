require 'haml' unless defined? ::Haml

module Sinatra
  module RenderingEngine
    class HamlRenderer < Base
      def render(data, options)
        options[:options] ||= @context.class.haml if @context.class.respond_to? :haml
        super
      end

      def render_template(data, options, &block)
        engine = ::Haml::Engine.new(data, options[:options] || {})
        engine.render(self, options[:locals] || {}, &block)
      end

      def render_layout(data, options, &block)
        data = data.call if data.is_a?(Proc)
        render_template(data, options, &block)
      end

      def engine_name
        :haml
      end
    end
  end
end
