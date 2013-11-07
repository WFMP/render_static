require 'render_static/rails/railtie' if defined?(Rails)
require 'render_static/renderer'
require 'render_static/matcher/exact'
require 'render_static/matcher/start_with'
require 'render_static/matcher/includes'

module RenderStatic
  class NotSeoFriendly < Exception
  end

  class Middleware
    class << self
      attr_accessor :use_headless, :driver, :bots, :logger
      attr_reader :load_complete
      
      def base_path=(value)
        base_paths << RenderStatic::Matcher::StartWith.new(value)
      end
      def base_paths
        @base_paths ||= []
      end
      
      def load_complete=(proc)
        raise "RenderStatic::Middleware.load_complete must be a Proc, not a #{proc.class.name}" unless proc.nil? || proc.is_a?(Proc)
        @load_complete = proc
      end
      def initialize_bots(bots_array)
        bots_array = ([] << bots_array) unless bots_array.is_a? Array
        @bots = []
        bots_array.each do |bot|
          case bot
          when String
            @bots << RenderStatic::Matcher::Exact.new(bot)
          when Hash
            matcher = bot[:matcher]
            user_agent = bot[:user_agent]
            if matcher && user_agent && !(user_agent.nil? || user_agent.empty?)
              case matcher
              when :exact
                @bots << RenderStatic::Matcher::Exact.new(user_agent)
              when :start_with
                @bots << RenderStatic::Matcher::StartWith.new(user_agent)
              when :starts_with
                @bots << RenderStatic::Matcher::StartWith.new(user_agent)
              when :include
                @bots << RenderStatic::Matcher::Includes.new(user_agent)
              when :includes
                @bots << RenderStatic::Matcher::Includes.new(user_agent)
              end
            end
          end
        end
      end
    end
    DEFAULT_BOTS = [
        "Googlebot",
        "Googlebot-Mobile",
        "AdsBot-Google",
        "Mozilla/5.0 (compatible; Ask Jeeves/Teoma; +http://about.ask.com/en/docs/about/webmasters.shtml)",
        "Baiduspider",
        "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)",
    ]
    self.use_headless = true
    self.driver = :firefox
    self.initialize_bots(DEFAULT_BOTS)
    
    
    def initialize(app)
      @app = app
    end

    def call(env)
      if will_render?(env)
        logger = self.class.logger || env['rack.errors']
        logger.info("Request from #{env['REMOTE_ADDR']} with User-Agent: #{env['HTTP_USER_AGENT']} recognized as a bot.")
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
      self.class.bots.any? { |bot| bot.matches?(env["HTTP_USER_AGENT"]) }
    end

    def is_renderable?(env)
      path = env["PATH_INFO"]

      path_match?(path) & content_type_match?(content_type(env)) && env["REQUEST_METHOD"] == "GET"
    end
    
    def path_match?(path)
      self.class.base_paths.any? { |base_path| base_path.matches? path }
    end
    
    def content_type_match?(content_type)
      [nil, "htm", "html"].include?(content_type)
    end
    
    def content_type(env)
      path = env["PATH_INFO"]
      path.index(".") && path.split(".").last
    end
  end
end
