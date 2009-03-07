require 'sass' unless defined? ::Sass

module Sinatra
  module Rendering
    class SassRenderer < Base
      def render(data, options)
        engine = ::Sass::Engine.new(data, options[:sass] || {})
        engine.render
      end
    end
  end
end
