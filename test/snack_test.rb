require 'rubygems'
require 'minitest/spec'
require 'rack/test'
require 'rack/mock'

require "#{File.dirname(__FILE__)}/../lib/snack"

MiniTest::Unit.autorun

describe Snack::Server do
  include Rack::Test::Methods

  def app
    @app = Snack::Application.new(:root => "#{File.dirname(__FILE__)}/test_app").builder
  end

  it "should respond with 404 on bad requests" do
    get('/foo')
    last_response.status.must_equal 404
  end

  it "should serve file directly first if a file matches the request" do
    get('/public/style.css')
    last_response.body.must_equal "body {\n\tbackground: blue;\n}"
  end

  it "should serve file compiled through tilt if request path exists with different extension" do
    get('/sass_style.css')
    last_response.body.must_equal "body {\n  background: blue; }\n"
  end
  
  it "should default to index.html if directory is requested" do
    response = get('/index.html')
    response = get('/')

    last_response.status.must_equal response.status
    last_response.body.must_equal response.body
  end

  # partials
  it "should render partials if found" do
    get('/partial_test/normal.html')
    last_response.body.must_equal "This is a partial!\n"
  end

  it "should error if partial not found" do
    get('/partial_test/failing.html')
    last_response.status.must_equal 500
  end
  
  # layouts
  it "should render a page within a layout if layout exists" do
    get('/layout_test/page.html')
    last_response.body.must_equal "<div id='content'>\n  <h1>Page Content</h1>\n</div>\n"
  end

  it "should render a page within a layout if layout exists" do
    get('/layout_test/page.html')
    last_response.body.must_equal "<div id='content'>\n  <h1>Page Content</h1>\n</div>\n"
  end

  it "should render a page within a specific layout if given valid path to that layout" do
    get('/layout_test/page_with_alternate_layout.html')
    last_response.body.must_equal "<div id='alternate_content'>\n  <h1>Alternate Page Content</h1>\n</div>\n"
  end

  # throw error when layout not found? (log it?)
  
  # yield
  
  # content_for
  
  # Engine specific tests
  
  # Sass
  
  # Haml
  
  # Coffeescript
  
  # Erb
  
  



  # yield
  # yield :name (content_for)
  # set layout in view
  # set vars in view
  # index default
  
  # sass
  # haml
  # coffeescript
  
  


end
