require 'builder' unless defined? ::Builder

module Sinatra
  module RenderingEngine
    class BuilderRenderer < Base
      def render(data, options, &block)
        data = block if data.nil?
        super(data, options)
      end

      def render_template(data, options, xml = nil)
        xml = ::Builder::XmlMarkup.new(:indent => 2) unless xml

        @context.instance_eval do
          if data.respond_to?(:to_str)
            instance_eval(data.to_str, '<BUILDER>', 1)
          elsif data.kind_of?(Proc)
            data.call(xml)
          end
        end

        xml.target!
      end

      def render_layout(data, options, &output_wrapper)
        xml = ::Builder::XmlMarkup.new(:indent => 2)
        
        define_content_for_layout(xml, output_wrapper.call) if block_given?
        
        render_template(data, options, xml)
      end

      def engine_name
        :builder
      end

    private

      def define_content_for_layout(object, output)
        metaclass(object) do
          define_method :content_for_layout do
            self << output
          end
        end
      end

      def metaclass(object = self, &block)
        metaclass = class << object; self; end
        metaclass.class_eval(&block)
      end
    end
  end
end
