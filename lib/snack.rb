%w[ rubygems ostruct rack tilt ].each { |s| require s }

module Snack
  class Application
    attr_accessor :settings, :builder

    def initialize(options = {})
      @settings = OpenStruct.new(options)
      @settings.output_dir ||= '../'

      app = self
      @builder = Rack::Builder.new do
        use Rack::CommonLogger
        use Rack::ShowStatus      # Nice looking 404s and other messages
        use Rack::ShowExceptions  # Nice looking errors
        run Snack::Server.new app
      end
    end

    def method_missing(sym)
      settings.send sym
    end

    def serve
      Rack::Handler::Thin.run @builder, :Port => 9393
    end

    def new
      File.open(File.join(FileUtils.mkpath(root), 'index.html.haml'), 'w') { |f| f.puts 'Hello from snack!' }
    end

    def build
      FileUtils.cd root do
        # collect all files that don't start with '_'
        files = Dir[File.join('**', '*')].reject { |f| f.include?('/_') || f.start_with?('_') }

        files.each do |file|
          new_path = File.join(output_dir, file)

          if File.directory?(file)
            FileUtils.mkdir(new_path) unless File.exists?(new_path)
          elsif Tilt.registered?(File.extname(file).gsub('.', ''))
            body = View.new(file).render
            new_path = new_path.gsub(File.extname(new_path), '') # trim template extension
            File.open(new_path, 'w') { |f| f.write(body) }
          else
            FileUtils.cp(file, new_path)
          end
        end
        
      end
    end
  end

  class Server
    def initialize(app)
      @app = app
    end

    def call(env)
      body = render File.join(@app.root, env['PATH_INFO'])
      if body
        [200, { "Content-Type" => Rack::Mime.mime_type(File.extname(env['PATH_INFO']), 'text/html') }, [body]]
      else
        [404, { "Content-Type" => "text/plain" }, "Not Found"]
      end
    end

    def render(template_path)
      return File.read template_path if File.file? template_path

      # default to index if path to directory
      template_path = File.join(template_path, 'index') if File.directory? template_path

      # return the first filename that matches file
      template = Dir[File.join(template_path + '*')].first
      return View.new(template).render if template
    end

  end

  # Take a template and render a string from it.
  class View
    def initialize(template)
      @template = template
    end

    # return the path to a valid layout file
    def layout
      Dir[File.join(File.dirname(@template), @layout) + '*'].first if @layout
    end

    def partial(path, locals = {})
      # insert a '_' before the filename before we search
      filepath = File.join(File.dirname(@template), path.to_s)
      template = Dir[filepath.reverse.sub('/', '_/').reverse + '*'].first

      if template
        Tilt.new(template).render(self, locals)
      else
        raise "-: Snack :- Unable to locate partial at: '#{filepath}'"
      end
    end

    # return a view body or nil if adequate template cannot be found
    def render
      template_body = Tilt.new(@template).render(self)
      if layout
        @body = Tilt.new(layout).render(self) { template_body }
      elsif @layout # user changed; alert them to fails
        raise "-: Snack :- Unable to locate layout at: '#{@layout}'"
      end
      @body || template_body
    end
  end
end