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

        def use_engine(engine_name, context)
          if engine_class = engines[engine_name.to_sym]
            engine = RenderingEngine.const_get(engine_class)
            engine.new(context)
          else
            raise EngineNotFound, "Could not find an engine for '#{engine_name}'"
          end
        end
      end

      def initialize(context)
        @context = context
      end

      attr_reader :context

      def render_template_with_layout(engine_name, template, data, options)
        output = render_template(template, data, options)
        layout, data = lookup_layout(engine_name, options)

        if layout
          render_layout(template, data, options) { output }
        else
          output
        end
      end

      def render(engine_name, template, options={}) #:nodoc:
        data = lookup_template(engine_name, template, options)
        render_template_with_layout(engine_name, template, data, options)
      end

      def render_template(template, data, options, &block)
        raise NotImplementedError, "render_template must be implemented by subclasses of RenderingEngine::Base"
      end

      def render_layout(template, data, options, &block)
        raise NotImplementedError, "render_layout must be implemented by subclasses of RenderingEngine::Base"
      end

    private

      def lookup_template(engine, template, options)
        case template
        when Symbol
          if cached = find_cached_template(template)
            lookup_template(engine, cached, options)
          else
            read_template(engine, template, options)
          end
        when Proc
          template.call
        when String
          template
        else
          raise ArgumentError
        end
      end

      def lookup_layout(engine, options)
        return if options[:layout] == false
        options.delete(:layout) if options[:layout] == true
        template = options[:layout] || :layout
        data     = lookup_template(engine, template, options)
        [template, data]
      rescue Errno::ENOENT
        nil
      end

      def read_template(engine, template, options)
        ::File.read(template_path(engine, template, options))
      end

      def find_cached_template(template)
        cached_templates[template]
      end

      def cached_templates
        @context.class.templates
      end

      def template_path(engine, template, options={})
        views_dir = options[:views_directory] || @context.options.views || "./views"
        "#{views_dir}/#{template}.#{engine}"
      end
    end
  end
end
