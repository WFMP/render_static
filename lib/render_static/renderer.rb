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
    
    private
    def self.call_browser(env)
      browser = Selenium::WebDriver.for(RenderStatic::Middleware.driver)
      path = "#{env["rack.url_scheme"]}://#{env["HTTP_HOST"]}#{env["REQUEST_PATH"]}"
      browser.navigate.to(path)
      [200, { "Content-Type" => "text/html" }, [browser.page_source]] # TODO status code not supported by selenium
    ensure
      browser.quit if browser.present?
    end
    
  end
end