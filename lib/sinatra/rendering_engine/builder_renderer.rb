require 'builder' unless defined? ::Builder

module Sinatra
  module RenderingEngine
    class BuilderRenderer < Base
      def render(data, options, &block)
        data = lambda { block } if data.nil?
        super(data, options)
      end

      def render_template(data, options)
        xml = ::Builder::XmlMarkup.new(:indent => 2)

        @context.instance_eval do
          if data.respond_to?(:to_str)
            instance_eval(data.to_str, '<BUILDER>', 1)
          elsif data.kind_of?(Proc)
            data.call(xml)
          end
        end

        xml.target!
      end

      alias_method :render_layout, :render_template

      def engine_name
        :builder
      end
    end
  end
end
