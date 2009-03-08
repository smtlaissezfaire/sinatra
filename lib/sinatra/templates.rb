module Sinatra
  # Template rendering methods. Each method takes a the name of a template
  # to render as a Symbol and returns a String with the rendered output.
  module Templates
    dir = File.dirname(__FILE__) + "/templates"

    require "#{dir}/helpers"
    require "#{dir}/engine_resolver"
    require "#{dir}/template_resolver"
  end
end
