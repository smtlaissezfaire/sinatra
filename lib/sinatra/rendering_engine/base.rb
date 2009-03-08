module Sinatra
  module RenderingEngine
    class Base
      def initialize(target)
        @target = target
      end

      def render_template_with_layout(engine_name, template, data, options)
        output = render_template(template, data, options)
        layout, data = template_resolver.lookup_layout(engine_name, options)

        if layout
          render_layout(template, data, options) { output }
        else
          output
        end
      end

      def render(engine_name, template, options={}) #:nodoc:
        data   = template_resolver.lookup_template(engine_name, template, options)
        render_template_with_layout(engine_name, template, data, options)
      end

      def render_template(template, data, options, &block)
        raise NotImplementedError, "render_template must be implemented by subclasses of RenderingEngine::Base"
      end

      def render_layout(template, data, options, &block)
        raise NotImplementedError, "render_layout must be implemented by subclasses of RenderingEngine::Base"
      end

    private

      def template_resolver
        @template_resolver ||= Templates::TemplateResolver.new(@target)
      end
    end
  end
end
