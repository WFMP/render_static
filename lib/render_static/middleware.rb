require 'render_static/rails/railtie' if defined?(Rails)
require 'render_static/renderer'

module RenderStatic
  class NotSeoFriendly < Exception
  end

  class Middleware
    class << self
      attr_accessor :base_path, :use_headless, :driver
      attr_reader :load_complete
      
      def load_complete=(proc)
        raise "RenderStatic::Middleware.load_complete must be a Proc, not a #{proc.class.name}" unless proc.nil? || proc.is_a?(Proc)
        @load_complete = proc
      end
    end
    self.use_headless = true
    self.driver = :firefox

    def initialize(app)
      @app = app
    end

    def call(env)
      if will_render?(env)
        RenderStatic::Renderer.render(env)
      else
        @app.call(env)
      end
    end

    private

    def will_render?(env)
      is_bot?(env) && is_renderable?(env)
    end

    def is_bot?(env)
      [
          "Googlebot",
          "Googlebot-Mobile",
          "AdsBot-Google",
          "Mozilla/5.0 (compatible; Ask Jeeves/Teoma; +http://about.ask.com/en/docs/about/webmasters.shtml)",
          "Baiduspider",
          "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)",
      ].include?(env["HTTP_USER_AGENT"])
    end

    def is_renderable?(env)
      path = env["PATH_INFO"]
      content_type = path.index(".") && path.split(".").last

      path.start_with?(self.class.base_path) & [nil, "htm", "html"].include?(content_type) && env["REQUEST_METHOD"] == "GET"
    end
  end
end
