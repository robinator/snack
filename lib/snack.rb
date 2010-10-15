require 'rubygems'
require 'ostruct'
require 'rack'
require 'tilt'
require 'coffee-script'
require 'ruby-debug'

module Snack
  
  #### Public Interface

  # `Rocco.new` takes a source `filename`, an optional list of source filenames
  # for other documentation sources, an `options` hash, and an optional `block`.
  # The `options` hash respects two members: `:language`, which specifies which
  # Pygments lexer to use; and `:comment_chars`, which specifies the comment
  # characters of the target language. The options default to `'ruby'` and `'#'`,
  # respectively.
  # When `block` is given, it must read the contents of the file using whatever
  # means necessary and return it as a string. With no `block`, the file is read
  # to retrieve data.
  class Application
    attr_accessor :settings, :builder

    def initialize(options = {})
      @settings = OpenStruct.new(options)
      @settings.paths    ||= ['/views', '/public']
      @settings.layout  ||= '_layouts/application'
      @settings.partials ||= '_partials'
      
      app = self
      @builder = Rack::Builder.new do
        use Rack::CommonLogger
        use Rack::ShowStatus      # Nice looking 404s and other messages
        use Rack::ShowExceptions  # Nice looking errors
        use Rack::Lint
        use Rack::Reloader

        run Rack::Cascade.new([
          Rack::File.new(app.root),
          Snack::Server.new(app)
        ])
      end
    end

    def method_missing(sym)
      self.settings.send(sym)
    end

    def serve
=begin
Rack::Server.start(
   :app => @builder,
   :server => 'thin',
   :port => '9393'
 )
=end
      Rack::Handler::Thin.run @builder, :Port => 9393
    end

    def build
      # static builder here
    end
  end

  class Server
    attr_accessor :app

    def initialize(app)
      @app = app
    end

    def call(env)
      @env = env
      body = render
      if body
        @response = Rack::Response.new
        @response['Content-Type'] = Rack::Mime.mime_type(File.extname(@env["PATH_INFO"]), 'text/html')
        @response.write(body)
        @response.finish
      else
        [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end

    def render
      # look for a matching template at each path
      @app.paths.each do |path|
        template_path = File.join(@app.root, path, @env["PATH_INFO"])

        # default to index if path to directory
        template_path = File.join(template_path, 'index') if File.directory?(template_path)

        # return the first filename that matches file
        template = Dir.glob(File.join(template_path + '*')).first
        return View.new(@app, template).render if template
      end
      nil
    end

  end

  # Ideally we can take any file and an app and create a view from it
  # render will return a string, so to write to a file we just 'render' inside file
  # to serve it we just render at server level
  class View
    #include Tilt::CompileSite
    attr_accessor :app, :template
    attr_accessor :layout, :content_for

    def initialize(app, template)
      @app = app
      @template = template
      @content_for = {}
      @layout = @app.layout
    end

    # return the path to a valid layout file
    def layout
      Dir.glob(File.join(File.dirname(@template), @layout) + '*').first
    end

    def render_partial(path, locals = {})
      pieces = path.to_s.split('/')
      partial = '_' + pieces.pop
      partial = File.join(File.dirname(@template), @app.partials, pieces, partial)
      template = Dir.glob(partial + '*').first

      if template
        Tilt.new(template).render(self, locals)
      else
        raise "Unable to locate partial at: #{partial}"
      end
    end

    def content_for(name, &block)
      @content_for[name] = []
      @content_for[name] << capture_haml(&block) if block_is_haml?(block)
      @content_for[name] unless block_given?
    end

    # return a view body from a full path to the resource
    # return nil if adequate template cannot be found
    def render
      template_body = Tilt.new(@template).render(self)

      if layout
        @body = Tilt.new(layout).render(self) do |*name|
          name.first ?
            (@content_for[name.first] || []).join("\n") :
            template_body
        end
      end
      @body || template_body
    end

  end

end