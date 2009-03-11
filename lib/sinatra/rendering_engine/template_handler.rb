module Sinatra
  module RenderingEngine
    class TemplateHandler
      def initialize(context, engine)
        @context = context
        @engine = engine
      end

      def lookup_template(template, options)
        case template
        when Symbol
          if cached = find_cached_template(template)
            lookup_template(cached, options)
          else
            read_template(template, options)
          end
        when Proc
          template.call
        when String
          template
        else
          raise ArgumentError
        end
      end

      def lookup_layout(options)
        if layout?(options)
          options.delete(:layout) if options[:layout] == true
          template = options[:layout] || :layout
          data     = lookup_template(template, options)
          [template, data]
        end
      rescue Errno::ENOENT
        nil
      end

      def layout?(options)
        !no_layout?(options)
      end

      def no_layout?(options)
        options[:layout] == false
      end

    private

      def engine_name
        @engine.engine_name
      end

      def read_template(template, options)
        ::File.read(template_path(template, options))
      end

      def find_cached_template(template)
        cached_templates[template]
      end

      def cached_templates
        @context.class.templates
      end

      def template_path(template, options={})
        views_dir = options[:views_directory] || @context.options.views || "./views"
        "#{views_dir}/#{template}.#{engine_name}"
      end
    end
  end
end
