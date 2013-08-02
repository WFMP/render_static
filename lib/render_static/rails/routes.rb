# require "active_support/core_ext/object/try"
# require "active_support/core_ext/hash/slice"
require 'render_static/path_matcher/exact'
require 'render_static/path_matcher/start_with'
module ActionDispatch::Routing
  class Mapper
    def get(*args, &block)
      options = args.extract_options!
      if crawl = options.delete(:crawlable)
        path = args[0]
        RenderStatic::Middleware.base_paths << RenderStatic::PathMatcher::StartWith.new(path)
        options[:anchor] ||= false
      end
      args.push(options)
      super(*args, &block)
    end
    
    def root(options={})
      if crawl = options.delete(:crawlable)
        RenderStatic::Middleware.base_paths << RenderStatic::PathMatcher::Exact.new('/')
      end
      super(options)
    end
  end
end