require 'thread'
require 'time'
require 'uri'
require 'rack'
require 'rack/builder'

module Sinatra
  VERSION = '0.9.1.1'

  class NotFound < NameError #:nodoc:
    def code ; 404 ; end
  end

  dir = File.dirname(__FILE__)
  require "#{dir}/request"
  require "#{dir}/response"
  require "#{dir}/helpers"
  require "#{dir}/templates"
  require "#{dir}/real_base"
  require "#{dir}/default_base"
  require "#{dir}/core_extensions"
  require "#{dir}/delegator"
  require "#{dir}/top_level_helpers"

  extend TopLevelHelpers

  # The top-level Application. All DSL methods executed on main are delegated
  # to this class.
  class Application < Default
  end
end

