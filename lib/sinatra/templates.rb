module Sinatra
  module Templates
    dir = File.dirname(__FILE__) + "/templates"

    require "#{dir}/helpers"
  end
end
