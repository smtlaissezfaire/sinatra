module Sinatra
  # Template rendering methods. Each method takes a the name of a template
  # to render as a Symbol and returns a String with the rendered output.
  module Templates
    
    require "sinatra/templates/helpers"
    require "sinatra/templates/engine_resolver"
    require "sinatra/templates/template_resolver"
    include Helpers
  end
end
