module Sinatra
  # Template rendering methods. Each method takes a the name of a template
  # to render as a Symbol and returns a String with the rendered output.
  module Templates
    
    require "sinatra/templates/helpers"
    require "sinatra/templates/engine_resolver"
    include Helpers

  private

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

      def lookup_layout(engine, options)
        return if options[:layout] == false
        options.delete(:layout) if options[:layout] == true
        template = options[:layout] || :layout
        data     = lookup_template(engine, template, options)
        [template, data]
      rescue Errno::ENOENT
        nil
      end
    end

  private

    def template_resolver
      @template_resolver ||= TemplateResolver.new(self)
    end

    def resolve_engine(engine)
      EngineResolver.resolve(engine)
    end
  end
end
