require "markaby"

module Sinatra
  module RenderingEngine
    class MarkabyRenderer < Base
      def render(data, options, &block)
        data = block if data.nil?
        super(data, options)
      end

      def render_template(data, options)
        render_markaby(data, get_locals(options))
      end

      def render_layout(data, options, &output_wrapper)
        render_markaby(data, :content_for_layout => output_wrapper.call)
      end

      def engine_name
        :mab
      end

    private

      def render_markaby(data, ivars)
        data = data_to_block(data)
        Markaby::Builder.new(ivars, &data).to_s
      end

      def get_locals(options)
        options[:locals] || { }
      end
    end
  end
end
