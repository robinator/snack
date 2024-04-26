# use 'turn test/snack_test.rb' for pretty output
# TODO: test build and new commands?
require File.expand_path('../../lib/snack', __FILE__)
require 'minitest/autorun'
require 'rack/test'
require 'debug'

Minitest.autorun

describe Snack::Server do
  include Rack::Test::Methods

  def app
    @app = Snack::Application.new(root: "#{File.dirname(__FILE__)}/test_app").builder
  end

  it 'should respond with 404 on bad requests' do
    get '/foo'
    assert_equal 404, last_response.status
  end

  it 'should serve static file directly first' do
    get '/public/style.css'
    assert_equal "body {\n\tbackground: blue;\n}", last_response.body
  end

  it 'should compile and serve sass files' do
    get '/public/sass_style.css'
    assert_equal "body {\n  background: blue; }\n", last_response.body
  end

  it 'should serve coffeescript files compiled through tilt if request path exists with coffee extension' do
    get '/public/application.js'
    assert_equal "(function() {\n  $(document).ready(function() {\n    return alert('hello from snack');\n  });\n\n}).call(this);\n", last_response.body 
  end

  it 'should default to index.html if directory is requested' do
    direct = get '/index.html'
    get '/'

    assert_equal direct.status, last_response.status
    assert_equal direct.body, last_response.body
  end

  # partials
  it 'should render partials if found' do
    get '/pages/partial-normal.html'
    assert_includes last_response.body,  "This is a partial!"
  end

  it 'should error if partial not found' do
    get '/pages/partial-failing.html'
    assert_equal 500, last_response.status
  end

  # layouts
  it 'should render a page within a layout if layout exists' do
    get '/pages/layout-normal.html'
    assert_includes last_response.body, "<div id=\"content\">\n  <h1>\n    Page Content\n  </h1>\n</div>"
  end

  it 'should error if user set layout and layout not found' do
    get '/pages/layout-failing.html'
    assert_equal 500, last_response.status
  end

  # variables
  it 'should pass variables defined in the page to the layout' do
    get '/pages/variable-normal.html'
    assert_includes last_response.body, "happy, sad, mad"
  end
end