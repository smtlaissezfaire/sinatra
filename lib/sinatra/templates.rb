module Sinatra
  # Template rendering methods. Each method takes a the name of a template
  # to render as a Symbol and returns a String with the rendered output.
  module Templates

    module Helpers
      def erb(template, options={})
        require 'erb' unless defined? ::ERB
        render :erb, template, options
      end

      def haml(template, options={})
        require 'haml' unless defined? ::Haml
        options[:options] ||= self.class.haml if self.class.respond_to? :haml
        render :haml, template, options
      end

      def sass(template, options={}, &block)
        require 'sass' unless defined? ::Sass
        options[:layout] = false
        render :sass, template, options
      end

      def builder(template=nil, options={}, &block)
        require 'builder' unless defined? ::Builder
        options, template = template, nil if template.is_a?(Hash)
        template = lambda { block } if template.nil?
        render :builder, template, options
      end
    end

    include Helpers

    def render(engine, template, options={}) #:nodoc:
      data   = lookup_template(engine, template, options)
      output = __send__("render_#{engine}", template, data, options)
      layout, data = lookup_layout(engine, options)
      if layout
        __send__("render_#{engine}", layout, data, options) { output }
      else
        output
      end
    end

    def lookup_template(engine, template, options={})
      case template
      when Symbol
        if cached = self.class.templates[template]
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

    def template_path(engine, template, options={})
      views_dir = options[:views_directory] || self.options.views || "./views"
      "#{views_dir}/#{template}.#{engine}"
    end

    def render_erb(template, data, options, &block)
      Rendering::ERBRenderer.new(self).render(template, data, options, &block)
    end

    def render_haml(template, data, options, &block)
      Rendering::HamlRenderer.render(data, options, &block)
    end

    def render_sass(template, data, options, &block)
      Rendering::SassRenderer.render(data, options)
    end

    def render_builder(template, data, options, &block)
      Rendering::BuilderRenderer.new(self).render(template, data, options, &block)
    end

    dir = File.dirname(__FILE__) + "/rendering"

    require "#{dir}/erb_renderer"
    require "#{dir}/haml_renderer"
    require "#{dir}/sass_renderer"
    require "#{dir}/builder_renderer"

  end
end
