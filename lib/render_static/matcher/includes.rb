require 'render_static/matcher/base'
module RenderStatic
  module Matcher
    class Includes < RenderStatic::Matcher::Base
      def matches?(str)
        (!str.nil?) && str.include?(match)
      end
    end
  end
end