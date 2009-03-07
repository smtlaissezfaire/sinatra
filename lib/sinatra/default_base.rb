module Sinatra
  # Base class for classic style (top-level) applications.
  class Default < Base
    set :raise_errors, Proc.new { test? }
    set :dump_errors, true
    set :sessions, false
    set :logging, Proc.new { ! test? }
    set :methodoverride, true
    set :static, true
    set :run, Proc.new { ! test? }

    def self.register(*extensions, &block) #:nodoc:
      added_methods = extensions.map {|m| m.public_instance_methods }.flatten
      Delegator.delegate *added_methods
      super(*extensions, &block)
    end
  end
end
