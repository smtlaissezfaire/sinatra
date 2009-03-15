module Sinatra
  module RenderingEngine
    class Base
      extend EngineSelection

      def initialize(context)
        @context = context
      end

      attr_reader :context

      def render(template, options={}) #:nodoc:
        data = template_handler.lookup_template(template, options)
        render_template_with_layout(data, options)
      end

      def render_template_with_layout(data, options)
        output = render_template(data, options)
        layout, data = template_handler.lookup_layout(options)

        if layout
          render_layout(data, options) { output }
        else
          output
        end
      end

      def render_template(data, options, &block)
        raise NotImplementedError, "render_template must be implemented by subclasses of RenderingEngine::Base"
      end

      def render_layout(data, options, &block)
        raise NotImplementedError, "render_layout must be implemented by subclasses of RenderingEngine::Base"
      end

      def engine_name
        raise NotImplementedError, "subclasses of RenderingEngine::Base must implement an engine name"
      end

    private

      def template_handler
        @template_handler ||= TemplateHandler.new(@context, self)
      end

      def metaclass(object = self, &block)
        metaclass = class << object; self; end
        metaclass.class_eval(&block)
      end
    end
  end
end
