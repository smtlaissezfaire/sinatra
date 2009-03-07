module Sinatra
  module RenderingEngine
    module EngineSelection
      def engines
        {
          :erb     => :ERBRenderer,
          :builder => :BuilderRenderer,
          :haml    => :HamlRenderer,
          :sass    => :SassRenderer
        }
      end

      def use_engine(engine_name, context)
        if engine_class = engines[engine_name.to_sym]
          engine = RenderingEngine.const_get(engine_class)
          engine.new(context)
        else
          raise EngineNotFound, "Could not find an engine for '#{engine_name}'"
        end
      end
    end
  end
end
