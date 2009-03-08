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

      alias_method :render, :render_template_with_layout

    private

      def template_resolver
        @template_resolver ||= Templates::TemplateResolver.new(@target)
      end

      def resolve_engine(engine)
        EngineResolver.resolve(engine, self)
      end
    end
  end
end
