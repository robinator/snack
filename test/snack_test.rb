# use 'turn test/snack_test.rb' for pretty output
# TODO: test build and new commands?
require File.expand_path('../../lib/snack', __FILE__)
require 'minitest/autorun'
require 'rack/test'
require 'coveralls'

Coveralls.wear!

Minitest.autorun

describe Snack::Server do
  include Rack::Test::Methods

  def app
    @app = Snack::Application.new(root: "#{File.dirname(__FILE__)}/test_app").builder
  end

  it 'should respond with 404 on bad requests' do
    get '/foo'
    last_response.status.must_equal 404
  end

  it 'should serve static file directly first' do
    get '/public/style.css'
    last_response.body.must_equal "body {\n\tbackground: blue;\n}"
  end

  it 'should compile and serve sass files' do
    get '/public/sass_style.css'
    last_response.body.must_equal "body {\n  background: blue; }\n"
  end

  it 'should serve coffeescript files compiled through tilt if request path exists with coffee extension' do
    get '/public/application.js'
    last_response.body.must_equal "(function() {\n  $(document).ready(function() {\n    return alert('hello from snack');\n  });\n\n}).call(this);\n"
  end

  it 'should default to index.html if directory is requested' do
    direct = get '/index.html'
    get '/'

    last_response.status.must_equal direct.status
    last_response.body.must_equal direct.body
  end

  # partials
  it 'should render partials if found' do
    get '/pages/partial-normal.html'
    last_response.body.must_equal "This is a partial!\n"
  end

  it 'should error if partial not found' do
    get '/pages/partial-failing.html'
    last_response.status.must_equal 500
  end

  # layouts
  it 'should render a page within a layout if layout exists' do
    get '/pages/layout-normal.html'
    last_response.body.must_equal "<div id='content'>\n  <h1>Page Content</h1>\n</div>\n"
  end

  it 'should error if user set layout and layout not found' do
    get '/pages/layout-failing.html'
    last_response.status.must_equal 500
  end

  # variables
  it 'should pass variables defined in the page to the layout' do
    get '/pages/variable-normal.html'
    last_response.body.must_equal "happy\nsad\nmad\n"
  end

end