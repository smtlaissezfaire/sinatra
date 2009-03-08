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
        layout, data = template_resolver.lookup_layout(engine_name, options)

        if layout
          render_layout(template, data, options, output)
        else
          output
        end
      end

      def render_layout(template, data, options, output)
        @engine.render_layout(layout, data, options) { output }
      end

      def render_template(template, data, options)
        @engine.render_template(template, data, options)
      end

      def template_resolver
        @template_resolver ||= TemplateResolver.new(self)
      end

      def resolve_engine(engine)
        EngineResolver.resolve(engine, self)
      end
    end
  end
end
