module Sinatra
  # Methods available to routes, before filters, and views.
  module Helpers
    dir = File.dirname(__FILE__) + "/helpers"
    require "#{dir}/template_helpers"
    require "#{dir}/action_helpers"

    include TemplateHelpers
    include ActionHelpers
  end
end
