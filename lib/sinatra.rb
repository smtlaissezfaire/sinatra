libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'thread'
require 'time'
require 'uri'
require 'rack'
require 'rack/builder'

module Sinatra
  VERSION = '0.9.1'

  class NotFound < NameError #:nodoc:
    def code ; 404 ; end
  end
  
  dir = File.dirname(__FILE__) + "/sinatra"
  require "#{dir}/request"
  require "#{dir}/response"
  require "#{dir}/helpers"
  require "#{dir}/templates"
  require "#{dir}/delegator"
  require "#{dir}/base"
  require "#{dir}/default"
  require "#{dir}/core_extensions"
  require "#{dir}/compat"
  require "#{dir}/top_level_helpers"
  
  extend TopLevelHelpers

  # The top-level Application. All DSL methods executed on main are delegated
  # to this class.
  class Application < Default
  end
end

use_in_file_templates!
