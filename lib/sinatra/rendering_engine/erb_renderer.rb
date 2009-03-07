require 'erb' unless defined? ::ERB

module Sinatra
  module RenderingEngine
    class ERBRenderer < Base
      def render_template(data, options, &block)
        @context.instance_eval do
          original_out_buf = @_out_buf
          data = data.call if data.kind_of? Proc

          instance = ::ERB.new(data, nil, nil, '@_out_buf')
          locals = options[:locals] || {}
          locals_assigns = locals.to_a.collect { |k,v| "#{k} = locals[:#{k}]" }

          src = "#{locals_assigns.join("\n")}\n#{instance.src}"
          eval src, binding, '(__ERB__)', locals_assigns.length + 1
          @_out_buf, result = original_out_buf, @_out_buf
          result
        end
      end

      alias_method :render_layout, :render_template

      def engine_name
        :erb
      end
    end
  end
end
