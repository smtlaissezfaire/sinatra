module Sinatra
  module Rendering
    class HamlRenderer
      def self.render(data, options, &block)
        new.render(data, options, &block)
      end

      def render(data, options, &block)
        engine = ::Haml::Engine.new(data, options[:options] || {})
        engine.render(self, options[:locals] || {}, &block)
      end
    end
  end
end
