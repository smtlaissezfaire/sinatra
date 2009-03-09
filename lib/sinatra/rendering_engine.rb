module Sinatra
  module RenderingEngine
    class EngineNotFound < StandardError
    end
    
    dir = File.dirname(__FILE__) + "/rendering_engine"

    autoload :EngineSelection, "#{dir}/engine_selection"
    autoload :Base,            "#{dir}/base"
    autoload :ERBRenderer,     "#{dir}/erb_renderer"
    autoload :HamlRenderer,    "#{dir}/haml_renderer"
    autoload :SassRenderer,    "#{dir}/sass_renderer"
    autoload :BuilderRenderer, "#{dir}/builder_renderer"
  end
end
