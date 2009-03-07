module Sinatra
  module TopLevelHelpers
    def new(base=Base, options={}, &block)
      base = Class.new(base)
      base.send :class_eval, &block if block_given?
      base
    end

    # Extend the top-level DSL with the modules provided.
    def register(*extensions, &block)
      Default.register(*extensions, &block)
    end

    # Include the helper modules provided in Sinatra's request context.
    def helpers(*extensions, &block)
      Default.helpers(*extensions, &block)
    end
  end
end
