module Sinatra
  module Templates
    # Template rendering methods. Each method takes a the name of a template
    # to render as a Symbol and returns a String with the rendered output.
    module Helpers
      def erb(template, options={})
        @engine = resolve_engine(:erb)
        render :erb, template, options
      end

      def haml(template, options={})
        @engine = resolve_engine(:haml)
        render :haml, template, options
      end

      def sass(template, options={})
        @engine = resolve_engine(:sass)
        render :sass, template, options
      end

      def builder(template=nil, options={}, &block)
        @engine = resolve_engine(:builder)
        render :builder, template, options, &block
      end

      def render(engine_name, template, options={}, &block) #:nodoc:
        @engine ||= resolve_engine(engine_name)
        @engine.render(engine_name, template, options, &block)
      end

    private

      def resolve_engine(engine)
        RenderingEngine::Base.resolve_engine(engine, self)
      end
    end
  end
end
