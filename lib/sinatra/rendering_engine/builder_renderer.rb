require 'builder' unless defined? ::Builder

module Sinatra
  module RenderingEngine
    class BuilderRenderer < Base
      def render_template(template, data, options, &block)
        @target.instance_eval do
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
    end
  end
end
