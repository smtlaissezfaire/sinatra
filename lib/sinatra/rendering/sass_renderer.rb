require 'sass' unless defined? ::Sass

module Sinatra
  module Rendering
    class SassRenderer
      def self.render(data, options)
        new.render(data, options)
      end

      def render(data, options)
        engine = ::Sass::Engine.new(data, options[:sass] || {})
        engine.render
      end
    end
  end
end
