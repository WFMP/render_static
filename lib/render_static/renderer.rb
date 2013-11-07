require 'selenium-webdriver'
require 'headless'
require 'json'

module RenderStatic
  class Renderer

    def self.render(env,request)
      if RenderStatic::Middleware.use_headless
        Headless.ly { self.call_browser(env,request) }
      else
        self.call_browser(env,request)
      end
    end
    
    protected
    def self.wait_for_load_complete(browser)
      unless RenderStatic::Middleware.load_complete.nil?
        wait = Selenium::WebDriver::Wait.new(:timeout => 10)
        wait.until { RenderStatic::Middleware.load_complete.call(browser) }
      end
    end
    
    def self.call_browser(env,request)
      browser = Selenium::WebDriver.for(RenderStatic::Middleware.driver)
      path = request.url
      if RenderStatic::Middleware.logger
        RenderStatic::Middleware.logger.info("RenderStatic::Renderer - Rendering #{path} with #{RenderStatic::Middleware.driver}") 
        RenderStatic::Middleware.logger.info("env:\n#{env}")
      end
      browser.navigate.to(path)
      self.wait_for_load_complete(browser)
      [200, { "Content-Type" => "text/html" }, [browser.page_source]] # TODO status code not supported by selenium
    ensure
      browser.quit if browser.present?
    end
    
  end
end