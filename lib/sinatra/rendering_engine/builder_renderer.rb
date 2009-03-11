require 'builder' unless defined? ::Builder

module Sinatra
  module RenderingEngine
    class BuilderRenderer < Base
      def render(data, options, &block)
        data = lambda { block } if data.nil?
        super(data, options)
      end

      def render_template(data, options)
        @context.instance_eval do
          xml = ::Builder::XmlMarkup.new(:indent => 2)
          if data.respond_to?(:to_str)
            eval data.to_str, binding, '<BUILDER>', 1
          elsif data.kind_of?(Proc)
            data.call(xml)
          end
          xml.target!
        end
      end

      alias_method :render_layout, :render_template

      def engine_name
        :builder
      end
    end
  end
end
