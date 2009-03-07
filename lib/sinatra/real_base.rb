module Sinatra
  # Base class for all Sinatra applications and middleware.
  class Base
    include Rack::Utils
    include Helpers
    include Templates

    attr_accessor :app

    def initialize(app=nil)
      @app = app
      yield self if block_given?
    end

    # Rack call interface.
    def call(env)
      dup.call!(env)
    end

    attr_accessor :env, :request, :response, :params

    def call!(env)
      @env      = env
      @request  = Request.new(env)
      @response = Response.new
      @params   = nil

      invoke { dispatch! }
      invoke { error_block!(response.status) }

      status, header, body = @response.finish

      # Never produce a body on HEAD requests. Do retain the Content-Length
      # unless it's "0", in which case we assume it was calculated erroneously
      # for a manual HEAD response and remove it entirely.
      if @env['REQUEST_METHOD'] == 'HEAD'
        body = []
        header.delete('Content-Length') if header['Content-Length'] == '0'
      end

      [status, header, body]
    end

    # Access options defined with Base.set.
    def options
      self.class
    end

    # Exit the current block and halt the response.
    def halt(*response)
      response = response.first if response.length == 1
      throw :halt, response
    end

    # Pass control to the next matching route.
    def pass
      throw :pass
    end

    # Forward the request to the downstream app -- middleware only.
    def forward
      fail "downstream app not set" unless @app.respond_to? :call
      status, headers, body = @app.call(@request.env)
      @response.status = status
      @response.body = body
      @response.headers.merge! headers
      nil
    end

  private
    # Run before filters and then locate and run a matching route.
    def route!
      @params = nested_params(@request.params)

      # before filters
      self.class.filters.each { |block| instance_eval(&block) }

      # routes
      if routes = self.class.routes[@request.request_method]
        original_params = @params
        path            = unescape(@request.path_info)

        routes.each do |pattern, keys, conditions, block|
          if match = pattern.match(path)
            values = match.captures.to_a
            params =
              if keys.any?
                keys.zip(values).inject({}) do |hash,(k,v)|
                  if k == 'splat'
                    (hash[k] ||= []) << v
                  else
                    hash[k] = v
                  end
                  hash
                end
              elsif values.any?
                {'captures' => values}
              else
                {}
              end
            @params = original_params.merge(params)
            @block_params = values

            catch(:pass) do
              conditions.each { |cond|
                throw :pass if instance_eval(&cond) == false }
              throw :halt, instance_eval(&block)
            end
          end
        end
      end

      # No matching route found or all routes passed -- forward downstream
      # when running as middleware; 404 when running as normal app.
      if @app
        forward
      else
        raise NotFound
      end
    end

    def nested_params(params)
      return indifferent_hash.merge(params) if !params.keys.join.include?('[')
      params.inject indifferent_hash do |res, (key,val)|
        if key.include?('[')
          head = key.split(/[\]\[]+/)
          last = head.pop
          head.inject(res){ |hash,k| hash[k] ||= indifferent_hash }[last] = val
        else
          res[key] = val
        end
        res
      end
    end

    def indifferent_hash
      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
    end

    # Run the block with 'throw :halt' support and apply result to the response.
    def invoke(&block)
      res = catch(:halt) { instance_eval(&block) }
      return if res.nil?

      case
      when res.respond_to?(:to_str)
        @response.body = [res]
      when res.respond_to?(:to_ary)
        res = res.to_ary
        if Fixnum === res.first
          if res.length == 3
            @response.status, headers, body = res
            @response.body = body if body
            headers.each { |k, v| @response.headers[k] = v } if headers
          elsif res.length == 2
            @response.status = res.first
            @response.body   = res.last
          else
            raise TypeError, "#{res.inspect} not supported"
          end
        else
          @response.body = res
        end
      when res.respond_to?(:each)
        @response.body = res
      when (100...599) === res
        @response.status = res
      end

      res
    end

    # Dispatch a request with error handling.
    def dispatch!
      route!
    rescue NotFound => boom
      handle_not_found!(boom)
    rescue ::Exception => boom
      handle_exception!(boom)
    end

    def handle_not_found!(boom)
      @env['sinatra.error'] = boom
      @response.status      = 404
      @response.body        = ['<h1>Not Found</h1>']
      error_block! boom.class, NotFound
    end

    def handle_exception!(boom)
      @env['sinatra.error'] = boom

      dump_errors!(boom) if options.dump_errors?
      raise boom         if options.raise_errors?

      @response.status = 500
      error_block! boom.class, Exception
    end

    # Find an custom error block for the key(s) specified.
    def error_block!(*keys)
      errmap = self.class.errors
      keys.each do |key|
        if block = errmap[key]
          res = instance_eval(&block)
          return res
        end
      end
      nil
    end

    def dump_errors!(boom)
      backtrace = clean_backtrace(boom.backtrace)
      msg = ["#{boom.class} - #{boom.message}:",
        *backtrace].join("\n ")
      @env['rack.errors'].write(msg)
    end

    def clean_backtrace(trace)
      return trace unless options.clean_trace?

      trace.reject { |line|
        line =~ /lib\/sinatra.*\.rb/ ||
          (defined?(Gem) && line.include?(Gem.dir))
      }.map! { |line| line.gsub(/^\.\//, '') }
    end

    @routes     = {}
    @filters    = []
    @conditions = []
    @templates  = {}
    @middleware = []
    @errors     = {}
    @prototype  = nil
    @extensions = []

    class << self
      attr_accessor :routes, :filters, :conditions, :templates,
        :middleware, :errors

      def set(option, value=self)
        if value.kind_of?(Proc)
          metadef(option, &value)
          metadef("#{option}?") { !!__send__(option) }
          metadef("#{option}=") { |val| set(option, Proc.new{val}) }
        elsif value == self && option.respond_to?(:to_hash)
          option.to_hash.each { |k,v| set(k, v) }
        elsif respond_to?("#{option}=")
          __send__ "#{option}=", value
        else
          set option, Proc.new{value}
        end
        self
      end

      def enable(*opts)
        opts.each { |key| set(key, true) }
      end

      def disable(*opts)
        opts.each { |key| set(key, false) }
      end

      def error(codes=Exception, &block)
        if codes.respond_to? :each
          codes.each { |err| error(err, &block) }
        else
          @errors[codes] = block
        end
      end

      def not_found(&block)
        error 404, &block
      end

      def template(name, &block)
        templates[name] = block
      end

      def layout(name=:layout, &block)
        template name, &block
      end

      def use_in_file_templates!(file=nil)
        file ||= caller_files.first
        if data = ::IO.read(file).split('__END__')[1]
          data.gsub!(/\r\n/, "\n")
          template = nil
          data.each_line do |line|
            if line =~ /^@@\s*(.*)/
              template = templates[$1.to_sym] = ''
            elsif template
              template << line
            end
          end
        end
      end

      # Look up a media type by file extension in Rack's mime registry.
      def media_type(type)
        return type if type.nil? || type.to_s.include?('/')
        type = ".#{type}" unless type.to_s[0] == ?.
        Rack::Mime.mime_type(type, nil)
      end

      def before(&block)
        @filters << block
      end

      def condition(&block)
        @conditions << block
      end

   private
      def host_name(pattern)
        condition { pattern === request.host }
      end

      def user_agent(pattern)
        condition {
          if request.user_agent =~ pattern
            @params[:agent] = $~[1..-1]
            true
          else
            false
          end
        }
      end

      def accept_mime_types(types)
        types = [types] unless types.kind_of? Array
        types.map!{|t| media_type(t)}

        condition {
          matching_types = (request.accept & types)
          unless matching_types.empty?
            response.headers['Content-Type'] = matching_types.first
            true
          else
            false
          end
        }
      end

    public
      def get(path, opts={}, &block)
        conditions = @conditions.dup
        route('GET', path, opts, &block)

        @conditions = conditions
        route('HEAD', path, opts, &block)
      end

      def put(path, opts={}, &bk); route 'PUT', path, opts, &bk; end
      def post(path, opts={}, &bk); route 'POST', path, opts, &bk; end
      def delete(path, opts={}, &bk); route 'DELETE', path, opts, &bk; end
      def head(path, opts={}, &bk); route 'HEAD', path, opts, &bk; end

    private
      def route(verb, path, opts={}, &block)
        host_name  opts[:host]  if opts.key?(:host)
        user_agent opts[:agent] if opts.key?(:agent)
        accept_mime_types opts[:provides] if opts.key?(:provides)

        pattern, keys = compile(path)
        conditions, @conditions = @conditions, []

        define_method "#{verb} #{path}", &block
        unbound_method = instance_method("#{verb} #{path}")
        block =
          if block.arity != 0
            lambda { unbound_method.bind(self).call(*@block_params) }
          else
            lambda { unbound_method.bind(self).call }
          end

        invoke_hook(:route_added, verb, path)

        (routes[verb] ||= []).
          push([pattern, keys, conditions, block]).last
      end

      def invoke_hook(name, *args)
        extensions.each { |e| e.send(name, *args) if e.respond_to?(name) }
      end

      def compile(path)
        keys = []
        if path.respond_to? :to_str
          special_chars = %w{. + ( )}
          pattern =
            path.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
              case match
              when "*"
                keys << 'splat'
                "(.*?)"
              when *special_chars
                Regexp.escape(match)
              else
                keys << $2[1..-1]
                "([^/?&#]+)"
              end
            end
          [/^#{pattern}$/, keys]
        elsif path.respond_to? :match
          [path, keys]
        else
          raise TypeError, path
        end
      end

    public
      def helpers(*extensions, &block)
        class_eval(&block)  if block_given?
        include *extensions if extensions.any?
      end

      def extensions
        (@extensions + (superclass.extensions rescue [])).uniq
      end

      def register(*extensions, &block)
        extensions << Module.new(&block) if block_given?
        @extensions += extensions
        extensions.each do |extension|
          extend extension
          extension.registered(self) if extension.respond_to?(:registered)
        end
      end

      def development? ; environment == :development ; end
      def test? ; environment == :test ; end
      def production? ; environment == :production ; end

      def configure(*envs, &block)
        return if reloading?
        yield if envs.empty? || envs.include?(environment.to_sym)
      end

      def use(middleware, *args, &block)
        @prototype = nil
        @middleware << [middleware, args, block]
      end

      def run!(options={})
        set options
        handler      = detect_rack_handler
        handler_name = handler.name.gsub(/.*::/, '')
        puts "== Sinatra/#{Sinatra::VERSION} has taken the stage " +
          "on #{port} for #{environment} with backup from #{handler_name}" unless handler_name =~/cgi/i
        handler.run self, :Host => host, :Port => port do |server|
          trap(:INT) do
            ## Use thins' hard #stop! if available, otherwise just #stop
            server.respond_to?(:stop!) ? server.stop! : server.stop
            puts "\n== Sinatra has ended his set (crowd applauds)" unless handler_name =~/cgi/i
          end
        end
      rescue Errno::EADDRINUSE => e
        puts "== Someone is already performing on port #{port}!"
      end

      # The prototype instance used to process requests.
      def prototype
        @prototype ||= new
      end

      # Create a new instance of the class fronted by its middleware
      # pipeline. The object is guaranteed to respond to #call but may not be
      # an instance of the class new was called on.
      def new(*args, &bk)
        builder = Rack::Builder.new
        builder.use Rack::Session::Cookie if sessions? && !test?
        builder.use Rack::CommonLogger if logging?
        builder.use Rack::MethodOverride if methodoverride?
        @middleware.each { |c, args, bk| builder.use(c, *args, &bk) }
        builder.run super
        builder.to_app
      end

      def call(env)
        synchronize do
          reload! if reload?
          prototype.call(env)
        end
      end

      def reloading?
        @reloading
      end

      def reload!
        @reloading = true
        reset!
        $LOADED_FEATURES.delete("sinatra.rb")
        ::Kernel.load app_file
        @reloading = false
      end

      def reset!(base=superclass)
        @routes     = base.dupe_routes
        @templates  = base.templates.dup
        @conditions = []
        @filters    = base.filters.dup
        @errors     = base.errors.dup
        @middleware = base.middleware.dup
        @prototype  = nil
        @extensions = []
      end

    protected
      def dupe_routes
        routes.inject({}) do |hash,(request_method,routes)|
          hash[request_method] = routes.dup
          hash
        end
      end

    private
      def detect_rack_handler
        servers = Array(self.server)
        servers.each do |server_name|
          begin
            return Rack::Handler.get(server_name)
          rescue LoadError
          rescue NameError
          end
        end
        fail "Server handler (#{servers.join(',')}) not found."
      end

      def inherited(subclass)
        subclass.reset! self
        super
      end

      @@mutex = Mutex.new
      def synchronize(&block)
        if lock?
          @@mutex.synchronize(&block)
        else
          yield
        end
      end

      def metadef(message, &block)
        (class << self; self; end).
          send :define_method, message, &block
      end

      # Like Kernel#caller but excluding certain magic entries and without
      # line / method information; the resulting array contains filenames only.
      def caller_files
        ignore = [
          /lib\/sinatra.*\.rb$/, # all sinatra code
          /\(.*\)/,              # generated code
          /custom_require\.rb$/, # rubygems require hacks
          /active_support/,      # active_support require hacks
        ]
        caller(1).
          map    { |line| line.split(/:\d/, 2).first }.
          reject { |file| ignore.any? { |pattern| file =~ pattern } }
      end
    end

    set :raise_errors, true
    set :dump_errors, false
    set :clean_trace, true
    set :sessions, false
    set :logging, false
    set :methodoverride, false
    set :static, false
    set :environment, (ENV['RACK_ENV'] || :development).to_sym

    set :run, false
    set :server, %w[thin mongrel webrick]
    set :host, '0.0.0.0'
    set :port, 4567

    set :app_file, nil
    set :root, Proc.new { app_file && File.expand_path(File.dirname(app_file)) }
    set :views, Proc.new { root && File.join(root, 'views') }
    set :public, Proc.new { root && File.join(root, 'public') }
    set :reload, Proc.new { app_file? && app_file !~ /\.ru$/i && development? }
    set :lock, Proc.new { reload? }

    # static files route
    get(/.*[^\/]$/) do
      pass unless options.static? && options.public?
      public_dir = File.expand_path(options.public)
      path = File.expand_path(public_dir + unescape(request.path_info))
      pass if path[0, public_dir.length] != public_dir
      pass unless File.file?(path)
      send_file path, :disposition => nil
    end

    error ::Exception do
      response.status = 500
      content_type 'text/html'
      '<h1>Internal Server Error</h1>'
    end

    configure :development do
      get '/__sinatra__/:image.png' do
        filename = File.dirname(__FILE__) + "/images/#{params[:image]}.png"
        content_type :png
        send_file filename
      end

      error NotFound do
        (<<-HTML).gsub(/^ {8}/, '')
        <!DOCTYPE html>
        <html>
        <head>
          <style type="text/css">
          body { text-align:center;font-family:helvetica,arial;font-size:22px;
            color:#888;margin:20px}
          #c {margin:0 auto;width:500px;text-align:left}
          </style>
        </head>
        <body>
          <h2>Sinatra doesn't know this ditty.</h2>
          <img src='/__sinatra__/404.png'>
          <div id="c">
            Try this:
            <pre>#{request.request_method.downcase} '#{request.path_info}' do\n  "Hello World"\nend</pre>
          </div>
        </body>
        </html>
        HTML
      end

      error do
        next unless err = request.env['sinatra.error']
        heading = err.class.name + ' - ' + err.message.to_s
        (<<-HTML).gsub(/^ {8}/, '')
        <!DOCTYPE html>
        <html>
        <head>
          <style type="text/css">
            body {font-family:verdana;color:#333}
            #c {margin-left:20px}
            h1 {color:#1D6B8D;margin:0;margin-top:-30px}
            h2 {color:#1D6B8D;font-size:18px}
            pre {border-left:2px solid #ddd;padding-left:10px;color:#000}
            img {margin-top:10px}
          </style>
        </head>
        <body>
          <div id="c">
            <img src="/__sinatra__/500.png">
            <h1>#{escape_html(heading)}</h1>
            <pre>#{escape_html(clean_backtrace(err.backtrace) * "\n")}</pre>
            <h2>Params</h2>
            <pre>#{escape_html(params.inspect)}</pre>
          </div>
        </body>
        </html>
        HTML
      end
    end
  end
end
