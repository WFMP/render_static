module RenderStatic
  module Matcher
    class Base
      attr_reader :match
      def initialize(match)
        @match = match
      end
      
      def matches?(str)
        false
      end
    end
  end
end