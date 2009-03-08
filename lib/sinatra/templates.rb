module Sinatra
  # Template rendering methods. Each method takes a the name of a template
  # to render as a Symbol and returns a String with the rendered output.
  module Templates
    
    require "sinatra/templates/helpers"
    require "sinatra/templates/engine_resolver"
    require "sinatra/templates/template_resolver"
    include Helpers

  private

    def template_resolver
      @template_resolver ||= TemplateResolver.new(self)
    end

    def resolve_engine(engine)
      EngineResolver.resolve(engine)
    end
  end
end
