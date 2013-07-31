require "render_static/renderer"

describe RenderStatic::Renderer do
  class Headless
    def self.ly &block
      yield
    end
  end

  describe ".render" do
    let(:env) {{ "HTTP_HOST" => "localhost:3000", "REQUEST_PATH" => "/abc", "rack.url_scheme" => "https" }}
    let(:navigate) { stub }
    let(:browser) {stub(navigate: navigate, page_source: "loaded page", present?: true, quit: stub)}
    let(:navigate_url) { "https://localhost:3000/abc" }
    it "requests the content" do
      Selenium::WebDriver.should_receive(:for).with(:firefox) { browser }

      navigate.should_receive(:to).with("https://localhost:3000/abc")

      response = RenderStatic::Renderer.render(env)

      response[0].should == 200
      response[1].should == {"Content-Type"=>"text/html"}
      response[2].should == ["loaded page"]
    end
    
    it "uses phantomjs driver" do
      RenderStatic::Middleware.driver = :phantomjs
      
      Selenium::WebDriver.should_receive(:for).with(:phantomjs) { browser }
      
      navigate.should_receive(:to).with(navigate_url)
      
      RenderStatic::Renderer.render(env)
    end
    
    it "uses a custom wait block" do
      RenderStatic::Middleware.load_complete = proc do |browser|
        browser.find_element(:css, "#app_view.loading").empty?
      end
      wait = stub
      
      Selenium::WebDriver.should_receive(:for) { browser }
      navigate.should_receive(:to).with(navigate_url)
      
      browser.should_receive(:find_element).with(:css, "#app_view.loading") { [] }
      
      RenderStatic::Renderer.render(env)
    end
  end
end