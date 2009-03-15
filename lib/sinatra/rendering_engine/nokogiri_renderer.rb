require 'nokogiri'

module Sinatra
  module RenderingEngine
    class NokogiriRenderer < Base
      def render(data, options, &block)
        data = block if data.nil?
        super(data, options)
      end

      def render_template(data, options)
        data = data_to_block(data)
        define_locals(options)
        builder = html_builder.new(&data)
        builder.doc.root.to_s
      end

      def render_layout(data, options, &output_wrapper)
        define_content_for_layout(output_wrapper.call)
        render_template(data, options)
      end

      def engine_name
        :ng
      end

    private

      def define_content_for_layout(output)
        html_builder.class_eval do
          define_method :content_for_layout do
            output
          end
        end
      end

      def html_builder
        Nokogiri::HTML::Builder
      end

      def define_locals(options)
        locals = options[:locals] || { }

        locals.each do |key, value|
          metaclass do
            define_method key do
              value
            end
          end
        end
      end
    end
  end
end
