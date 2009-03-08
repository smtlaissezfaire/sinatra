module Sinatra
  # Template rendering methods. Each method takes a the name of a template
  # to render as a Symbol and returns a String with the rendered output.
  module Templates
    module Helpers
      def erb(template, options={})
        @engine = resolve_engine(:erb)
        render :erb, template, options
      end

      def haml(template, options={})
        @engine = resolve_engine(:haml)
        options[:options] ||= self.class.haml if self.class.respond_to? :haml
        render :haml, template, options
      end

      def sass(template, options={}, &block)
        @engine = resolve_engine(:sass)
        options[:layout] = false
        render :sass, template, options
      end

      def builder(template=nil, options={}, &block)
        @engine = resolve_engine(:builder)
        options, template = template, nil if template.is_a?(Hash)
        template = lambda { block } if template.nil?
        render :builder, template, options
      end

      def render(engine_name, template, options={}) #:nodoc:
        data   = template_resolver.lookup_template(engine_name, template, options)
        @engine ||= resolve_engine(engine_name)
        
        render_template_with_layout(engine_name, template, data, options)
      end

    private

      def render_template_with_layout(engine_name, template, data, options)
        output = render_template(template, data, options)
        layout, data = lookup_layout(engine_name, options)

        if layout
          render_layout(template, data, options, output)
        else
          output
        end
      end

      def render_layout(template, data, options, output)
        @engine.render(self, layout, data, options) { output }
      end

      def render_template(template, data, options)
        @engine.render(self, template, data, options)
      end
    end

    include Helpers

  private

    class EngineNotFound < StandardError; end

    def resolve_engine(engine)
      case engine
      when :erb
        RenderingEngine::ERBRenderer
      when :builder
        RenderingEngine::BuilderRenderer
      when :haml
        RenderingEngine::HamlRenderer
      when :sass
        RenderingEngine::SassRenderer
      else
        raise EngineNotFound, "Could not find an engine for '#{engine}'"
      end
    end

    class TemplateResolver
      def initialize(base)
        @base = base
      end

      def template_path(engine, template, options={})
        views_dir = options[:views_directory] || @base.options.views || "./views"
        "#{views_dir}/#{template}.#{engine}"
      end

      def lookup_template(engine, template, options)
        case template
        when Symbol
          if cached = @base.class.templates[template]
            lookup_template(engine, cached, options)
          else
            ::File.read(template_path(engine, template, options))
          end
        when Proc
          template.call
        when String
          template
        else
          raise ArgumentError
        end
      end
    end

    def lookup_layout(engine, options)
      return if options[:layout] == false
      options.delete(:layout) if options[:layout] == true
      template = options[:layout] || :layout
      data     = template_resolver.lookup_template(engine, template, options)
      [template, data]
    rescue Errno::ENOENT
      nil
    end

  private

    def template_resolver
      @template_resolver ||= TemplateResolver.new(self)
    end
  end
end
