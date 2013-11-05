require "render_static/middleware"

describe RenderStatic::Middleware do
  let(:app) { stub }
  let(:middleware) { RenderStatic::Middleware.new(app) }
  let(:request) {
    {
        "PATH_INFO" => "/somewhere/",
        "REQUEST_METHOD" => "GET"
    }
  }

  before :all do
    RenderStatic::Middleware.base_path = "/somewhere/"
    RenderStatic::Middleware.base_path = "/elsewhere/"
  end

  describe "a non-bot user agent" do
    it "passes-through" do
      env = request.merge("HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31")

      app.should_receive(:call).with(env)
      RenderStatic::Renderer.should_not_receive(:render)

      middleware.call(env)
    end
  end

  describe "a bot user agent" do
    it "does not render if path doesn't match" do
      env = request.merge("HTTP_USER_AGENT" => "Googlebot", "PATH_INFO" => "/somewhere_else/a.html")

      app.should_receive(:call).with(env)
      RenderStatic::Renderer.should_not_receive(:render)
      middleware.call(env)
    end

    it "requests the same url and renders it" do
      env = request.merge("HTTP_USER_AGENT" => "Googlebot", "PATH_INFO" => "/somewhere/index.html")

      app.should_not_receive(:call)
      RenderStatic::Renderer.should_receive(:render).with(env)
      middleware.call(env)
    end

    it "handles multiple base_paths" do
      env = request.merge("HTTP_USER_AGENT" => "Googlebot", "PATH_INFO" => "/elsewhere/index.html")

      app.should_not_receive(:call)
      RenderStatic::Renderer.should_receive(:render).with(env)
      middleware.call(env)
    end
    
    it "renders content without an explicit type" do
      env = request.merge("HTTP_USER_AGENT" => "Googlebot", "PATH_INFO" => "/somewhere/index")

      app.should_not_receive(:call)
      RenderStatic::Renderer.should_receive(:render).with(env)
      middleware.call(env)
    end

    it "only renders GETs" do
      env = request.merge("REQUEST_METHOD" => "POST", "PATH_INFO" => "/somewhere/index")

      app.should_receive(:call)
      RenderStatic::Renderer.should_not_receive(:render)
      middleware.call(env)
    end

    it "does not render non-html content" do
      env = request.merge("HTTP_USER_AGENT" => "Googlebot", "PATH_INFO" => "/somewhere/a.js")

      app.should_receive(:call).with(env)
      RenderStatic::Renderer.should_not_receive(:render)
      middleware.call(env)
      
    end
    
    it "should render headless" do
      env = request.merge("HTTP_USER_AGENT" => "Googlebot", "PATH_INFO" => "/somewhere/index.html")

      app.should_not_receive(:call)
      RenderStatic::Middleware.use_headless.should be true
      Headless.should_receive(:ly)
      
      middleware.call(env)
    end
    
    it "should not use headless" do
      RenderStatic::Middleware.use_headless=false
      env = request.merge("HTTP_USER_AGENT" => "Googlebot", "PATH_INFO" => "/somewhere/index.html")
      
      app.should_not_receive(:call)
      RenderStatic::Middleware.use_headless.should be false
      Headless.should_not_receive(:ly)
      RenderStatic::Renderer.should_receive(:call_browser).with(env)
      
      middleware.call(env)
      
    end
  end
  
  describe ".load_complete" do
    it "should raise an exception if assign a non-Proc value" do
      expect { RenderStatic::Middleware.load_complete="string"}.to raise_error("RenderStatic::Middleware.load_complete must be a Proc, not a String")
    end
    
    it "should not raise an exception if assigned a proc" do
      expect { RenderStatic::Middleware.load_complete=proc { true } }.not_to raise_error
    end
    it "should not raise an exception if assigned nil" do
      expect { RenderStatic::Middleware.load_complete = nil }.not_to raise_error
    end
  end
  
  describe ".base_paths" do
    it "should have two entries" do
      expect(RenderStatic::Middleware.base_paths.size).to eq(2)
    end
  end
  
  describe "a include matcher" do
    let(:include_bots) { [{matcher: :include, user_agent: 'Googlebot'}, {matcher: :start_with, user_agent: 'AdsBot-Google'} ] }
    before :all do
      RenderStatic::Middleware.initialize_bots(include_bots)
    end
    it "should have 2 bots" do
      expect(RenderStatic::Middleware.bots.size).to eq(2)
    end
    it "should match and render" do
      env = request.merge("HTTP_USER_AGENT" => "Googlebot", "PATH_INFO" => "/somewhere/index.html")

      app.should_not_receive(:call)
      RenderStatic::Renderer.should_receive(:render).with(env)
      middleware.call(env)
    end
    it "should match and render" do
      env = request.merge("HTTP_USER_AGENT" => "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)", "PATH_INFO" => "/somewhere/index.html")

      app.should_not_receive(:call)
      RenderStatic::Renderer.should_receive(:render).with(env)
      middleware.call(env)
    end
    it "should match and render" do
      env = request.merge("HTTP_USER_AGENT" => "Googlebot/2.1 (+http://www.google.com/bot.html)", "PATH_INFO" => "/somewhere/index.html")

      app.should_not_receive(:call)
      RenderStatic::Renderer.should_receive(:render).with(env)
      middleware.call(env)
    end
    it "should match and render" do
      env = request.merge("HTTP_USER_AGENT" => "AdsBot-Google (+http://www.google.com/adsbot.html)", "PATH_INFO" => "/somewhere/index.html")

      app.should_not_receive(:call)
      RenderStatic::Renderer.should_receive(:render).with(env)
      middleware.call(env)
    end
    it "should not match a bot and pass through" do
      env = request.merge("HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AdsBot-Google")

      app.should_receive(:call).with(env)
      RenderStatic::Renderer.should_not_receive(:render)

      middleware.call(env)
    end
    
    it "should not match a bot and pass through" do
      env = request.merge("HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31")

      app.should_receive(:call).with(env)
      RenderStatic::Renderer.should_not_receive(:render)

      middleware.call(env)
    end
    
  end
end