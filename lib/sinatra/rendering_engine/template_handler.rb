module Sinatra
  module RenderingEngine
    class TemplateHandler
      def initialize(context)
        @context = context
      end

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

      def layout?(options)
        !(options[:layout] == false)
      end

    private

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
