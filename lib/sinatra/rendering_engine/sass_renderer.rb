require 'sass' unless defined? ::Sass

module Sinatra
  module RenderingEngine
    class SassRenderer < Base
      def render(template, data, options)
        options[:layout] = false
        super
      end

      def render_template(template, data, options)
        engine = ::Sass::Engine.new(data, options[:sass] || {})
        engine.render
      end
    end
  end
end
