require 'haml' unless defined? ::Haml

module Sinatra
  module Rendering
    class HamlRenderer < Base
      def render(data, options, &block)
        engine = ::Haml::Engine.new(data, options[:options] || {})
        engine.render(self, options[:locals] || {}, &block)
      end
    end
  end
end
