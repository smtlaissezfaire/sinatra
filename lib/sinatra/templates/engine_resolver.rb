module Sinatra
  module Templates
    class EngineResolver
      def self.resolve(engine, context)
        new.resolve(engine, context)
      end

      class EngineNotFound < StandardError; end

      def resolve(engine, context)
        case engine
        when :erb
          RenderingEngine::ERBRenderer.new(context)
        when :builder
          RenderingEngine::BuilderRenderer.new(context)
        when :haml
          RenderingEngine::HamlRenderer.new(context)
        when :sass
          RenderingEngine::SassRenderer.new(context)
        else
          raise EngineNotFound, "Could not find an engine for '#{engine}'"
        end
      end
    end
  end
end
