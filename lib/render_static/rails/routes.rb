# require "active_support/core_ext/object/try"
# require "active_support/core_ext/hash/slice"
require 'render_static/matcher/exact'
require 'render_static/matcher/start_with'
module ActionDispatch::Routing
  class Mapper
    def get(*args, &block)
      options = args.extract_options!
      if crawl = options.delete(:crawlable)
        path = args[0]
        RenderStatic::Middleware.base_paths << RenderStatic::Matcher::StartWith.new(path)
        options[:anchor] ||= false
      end
      args.push(options)
      super(*args, &block)
    end
    
    def root(options={})
      if crawl = options.delete(:crawlable)
        if crawl.to_sym == :exact
          RenderStatic::Middleware.base_paths << RenderStatic::Matcher::Exact.new('/')
        else
          RenderStatic::Middleware.base_paths << RenderStatic::Matcher::StartWith.new('/')
        end
      end
      super(options)
    end
  end
end
