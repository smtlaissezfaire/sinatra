module Sinatra
  module Templates
    class EngineResolver
      def self.resolve(engine)
        new.resolve(engine)
      end

      class EngineNotFound < StandardError; end

      def resolve(engine)
        case engine
        when :erb
          RenderingEngine::ERBRenderer
        when :builder
          RenderingEngine::BuilderRenderer
        when :haml
          RenderingEngine::HamlRenderer
        when :sass
          RenderingEngine::SassRenderer
        else
          raise EngineNotFound, "Could not find an engine for '#{engine}'"
        end
      end
    end
  end
end
