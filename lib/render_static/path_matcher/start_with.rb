require 'render_static/path_matcher/base'
module RenderStatic
  module PathMatcher
    class StartWith < RenderStatic::PathMatcher::Base
      def matches?(path)
        path.start_with? base_path
      end
    end
  end
end