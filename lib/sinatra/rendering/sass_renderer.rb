require 'sass' unless defined? ::Sass

module Sinatra
  module Rendering
    class SassRenderer < Base
      def render(template, data, options)
        engine = ::Sass::Engine.new(data, options[:sass] || {})
        engine.render
      end
    end
  end
end
