module Sinatra
  module Rendering
    class Base
      def self.render(obj, data, options, &block)
        new(obj).render(data, options, &block)
      end

      def initialize(target)
        @target = target
      end
    end
  end
end
