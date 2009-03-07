module Sinatra
  module Rendering
    class Base
      def self.render(obj, template, data, options, &block)
        new(obj).render(template, data, options, &block)
      end

      def initialize(target)
        @target = target
      end
    end
  end
end
