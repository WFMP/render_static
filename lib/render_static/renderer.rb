require 'selenium-webdriver'
require 'headless'

module RenderStatic
  class Renderer

    def self.render(env)
      if RenderStatic::Middleware.use_headless
        Headless.ly { self.call_browser(env) }
      else
        self.call_browser(env)
      end
    end
    
    protected
    def self.wait_for_load_complete(browser)
      unless RenderStatic::Middleware.load_complete.nil?
        wait = Selenium::WebDriver::Wait.new(:timeout => 10)
        wait.until { RenderStatic::Middleware.load_complete.call(browser) }
      end
    end
    
    def self.call_browser(env)
      browser = Selenium::WebDriver.for(RenderStatic::Middleware.driver)
      path = "#{env["rack.url_scheme"]}://#{env["HTTP_HOST"]}#{env["REQUEST_PATH"]}"
      browser.navigate.to(path)
      self.wait_for_load_complete(browser)
      [200, { "Content-Type" => "text/html" }, [browser.page_source]] # TODO status code not supported by selenium
    ensure
      browser.quit if browser.present?
    end
    
  end
end