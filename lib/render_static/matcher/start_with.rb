require 'render_static/matcher/base'
module RenderStatic
  module Matcher
    class StartWith < RenderStatic::Matcher::Base
      def matches?(str)
        str.start_with? match
      end
    end
  end
end