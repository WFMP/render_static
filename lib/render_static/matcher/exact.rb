require 'render_static/matcher/base'
module RenderStatic
  module Matcher
    class Exact < RenderStatic::Matcher::Base 
      def matches?(str)
        (!str.nil?) && match == str
      end
    end
  end
end