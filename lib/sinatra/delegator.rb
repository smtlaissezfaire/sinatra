module Sinatra
  module Delegator #:nodoc:
    def self.delegate(*methods)
      methods.each do |method_name|
        eval <<-RUBY, binding, '(__DELEGATE__)', 1
          def #{method_name}(*args, &b)
            ::Sinatra::Application.#{method_name}(*args, &b)
          end
          private :#{method_name}
        RUBY
      end
    end

    delegate :get, :put, :post, :delete, :head, :template, :layout, :before,
             :error, :not_found, :configures, :configure, :set, :set_option,
             :set_options, :enable, :disable, :use, :development?, :test?,
             :production?, :use_in_file_templates!, :helpers
  end
end
