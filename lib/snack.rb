require 'rubygems'
require 'ostruct'
require 'rack'
require 'tilt'
require 'coffee-script'

module Snack

  class Application
    attr_accessor :settings, :builder

    def initialize(options = {})
      @settings = OpenStruct.new(options)
      @settings.layout   ||= '_layouts/application'
      @settings.output_dir ||= '../_output'

      app = self
      @builder = Rack::Builder.new do
        use Rack::CommonLogger
        use Rack::ShowStatus      # Nice looking 404s and other messages
        use Rack::ShowExceptions  # Nice looking errors

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
      Rack::Handler::Thin.run @builder, :Port => 9393
    end

    def build
      puts "-: Snack :- Building: '#{File.join(self.root, self.output_dir)}'"
      FileUtils.cd(self.root) do
        # collect all files that don't start with '_'
        files = Dir[File.join('**', '*')].reject{ |f| f.include?('/_') || f.start_with?('_') }

        # setup output directory
        FileUtils.mkdir(self.output_dir) unless File.exists?(self.output_dir)

        files.each do |file|
          new_path = File.join(self.output_dir, file)

          if File.directory?(file)
            FileUtils.mkdir(new_path) unless File.exists?(new_path)
          elsif Tilt.registered?(File.extname(file).gsub('.', ''))
            body = View.new(self, file).render
            new_path = new_path.gsub(File.extname(new_path), '') # trim template extension
            File.open(new_path, 'w') { |f| f.write(body) }
          else
            FileUtils.cp(file, new_path)
          end
          
          puts "-: Snack :- Added: '#{new_path}'"
        end
        
      end
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
      template_path = File.join(@app.root, @env["PATH_INFO"])
      
      # default to index if path to directory
      template_path = File.join(template_path, 'index') if File.directory?(template_path)

      # return the first filename that matches file
      template = Dir[File.join(template_path + '*')].first
      return View.new(@app, template).render if template
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
      Dir[File.join(File.dirname(@template), @layout) + '*'].first if @layout
    end

    def partial(path, locals = {})
      pieces = path.to_s.split('/')
      name = '_' + pieces.pop
      filepath = File.join(File.dirname(@template), pieces, name)
      template = Dir[filepath + '*'].first

      if template
        Tilt.new(template).render(self, locals)
      else
        raise "-: Snack :- Unable to locate partial at: '#{filepath}'"
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
          if name.first
            (@content_for[name.first] || []).join("\n")
          else
            template_body
          end
        end
      elsif @layout && @layout != @app.layout # user changed; alert them to fails
        raise "-: Snack :- Unable to locate layout at: '#{@layout}'"
      end
      @body || template_body
    end
  end
end