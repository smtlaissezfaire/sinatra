require 'builder' unless defined? ::Builder

module Sinatra
  module Rendering
    class BuilderRenderer
      def initialize(target)
        @target = target
      end

      def render(template, data, options, &block)
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
    end
  end
end
