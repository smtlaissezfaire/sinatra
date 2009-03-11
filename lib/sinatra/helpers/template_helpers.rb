module Sinatra
  module Helpers
    # Template rendering methods. Each method takes a the name of a template
    # to render as a Symbol and returns a String with the rendered output.
    module TemplateHelpers
      def erb(template, options={})
        @engine = use_engine(:erb)
        render :erb, template, options
      end

      def haml(template, options={})
        @engine = use_engine(:haml)
        render :haml, template, options
      end

      def sass(template, options={})
        @engine = use_engine(:sass)
        render :sass, template, options
      end

      def builder(template=nil, options={}, &block)
        @engine = use_engine(:builder)
        render :builder, template, options, &block
      end

      def render(engine_name, template, options={}, &block) #:nodoc:
        @engine ||= use_engine(engine_name)
        @engine.render(template, options, &block)
      end

    private

      def use_engine(engine_name)
        RenderingEngine::Base.use_engine(engine_name, self)
      end
    end
  end
end
