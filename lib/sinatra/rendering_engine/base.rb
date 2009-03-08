module Sinatra
  module RenderingEngine
    class Base
      class EngineNotFound < StandardError; end

      class << self
        def engines
          {
            :erb     => :ERBRenderer,
            :builder => :BuilderRenderer,
            :haml    => :HamlRenderer,
            :sass    => :SassRenderer
          }
        end

        def resolve_engine(engine_name, context)
          if engine_class = engines[engine_name.to_sym]
            engine = RenderingEngine.const_get(engine_class)
            engine.new(context)
          else
            raise EngineNotFound, "Could not find an engine for '#{engine_name}'"
          end
        end
      end

      def initialize(target)
        @target = target
      end

      attr_reader :target
      alias_method :context, :target

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
