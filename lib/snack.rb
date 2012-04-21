%w[ rack tilt ].each { |s| require s }

module Snack
  class Application
    attr_accessor :settings, :builder

    def initialize(options = {})
      @settings = options
      @settings[:output_dir] ||= '../'

      app = self
      @builder = Rack::Builder.new do
        use Rack::CommonLogger
        use Rack::ShowStatus      # Nice looking 404s and other messages
        use Rack::ShowExceptions  # Nice looking errors
        run Snack::Server.new app
      end
    end

    def serve
      Rack::Handler::Thin.run @builder, :Port => 9393
    end

    def build
      FileUtils.cd @settings[:root] do
        # collect all files that don't start with '_'
        files = Dir[File.join('**', '*')].reject { |f| f =~ /(^_|\/_)/ }

        files.each do |file|
          path = File.join @settings[:output_dir], file

          if Tilt[path]
            body = View.new(file).render
            File.open(path.chomp(File.extname(path)), 'w') { |f| f.write body }
          elsif Dir.exists? file
            FileUtils.mkpath path
          else
            FileUtils.cp file, path
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
      body = render File.join(@app.settings[:root], env['PATH_INFO'])
      if body
        [200, { 'Content-Type' => Rack::Mime.mime_type(File.extname(env['PATH_INFO']), 'text/html') }, [body]]
      else
        [404, { 'Content-Type' => 'text/plain' }, 'Not Found']
      end
    end

    def render(path)
      return File.read path if File.file? path

      # default to index if path to directory
      path = File.join(path, 'index') if Dir.exists? path

      # return the first filename that matches file
      template = Dir[File.join("#{path}*")].first
      return View.new(template).render if template
    end
  end

  class View
    def initialize(template)
      @template = template
    end

    def partial(path, locals = {})
      filepath = File.join File.dirname(@template), path.to_s
      # insert a '_' before the filename before we search
      _partial = Dir["#{filepath.sub(/\/(?!.*\/)/, '/_')}*"].first

      if _partial
        Tilt.new(_partial).render(self, locals)
      else
        raise "-: Snack :- Unable to locate partial at: '#{filepath}'"
      end
    end

    # return a view body or nil if adequate template cannot be found
    def render
      template_body = Tilt.new(@template).render(self)
      if @layout
        layout = Dir[File.join(File.dirname(@template), @layout) + '*'].first
        raise "-: Snack :- Unable to locate layout at: '#@layout'" unless layout
        @body = Tilt.new(layout).render(self) { template_body }
      end
      @body || template_body
    end
  end
end