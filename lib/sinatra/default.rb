module Sinatra
  # Base class for classic style (top-level) applications.
  class Default < Base
    set :raise_errors, Proc.new { test? }
    set :dump_errors, true
    set :sessions, false
    set :logging, Proc.new { ! test? }
    set :methodoverride, true
    set :static, true

    # we assume that the first file that requires 'sinatra' is the
    # app_file. all other path related options are calculated based
    # on this path by default.
    set :app_file, lambda {
      ignore = [
        /lib\/sinatra.*\.rb$/, # all sinatra code
        /\(.*\)/,              # generated code
        /custom_require\.rb$/  # rubygems require hacks
      ]
      path =
        caller.map{ |line| line.split(/:\d/, 2).first }.find do |file|
          next if ignore.any? { |pattern| file =~ pattern }
          file
        end
      path || $0
    }.call

    set :run, Proc.new { $0 == app_file }

    if run? && ARGV.any?
      require 'optparse'
      OptionParser.new { |op|
        op.on('-x')        {       set :mutex, true }
        op.on('-e env')    { |val| set :environment, val.to_sym }
        op.on('-s server') { |val| set :server, val }
        op.on('-p port')   { |val| set :port, val.to_i }
      }.parse!(ARGV.dup)
    end

    def self.register(*extensions, &block) #:nodoc:
      added_methods = extensions.map {|m| m.public_instance_methods }.flatten
      Delegator.delegate *added_methods
      super(*extensions, &block)
    end
  end
end

include Sinatra::Delegator

def mime(ext, type)
  ext = ".#{ext}" unless ext.to_s[0] == ?.
  Rack::Mime::MIME_TYPES[ext.to_s] = type
end

at_exit do
  raise $! if $!
  Sinatra::Application.run! if Sinatra::Application.run?
end
