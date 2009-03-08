module Sinatra
  module Templates
    dir = File.dirname(__FILE__) + "/templates"

    require "#{dir}/helpers"
    require "#{dir}/engine_resolver"
    require "#{dir}/template_resolver"
  end
end
