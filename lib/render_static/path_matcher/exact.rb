require 'render_static/path_matcher/base'
module RenderStatic
  module PathMatcher
    class Exact < RenderStatic::PathMatcher::Base 
      def matches?(path)
        base_path == path
      end
    end
  end
end