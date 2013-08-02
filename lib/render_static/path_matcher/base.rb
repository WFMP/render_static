module RenderStatic
  module PathMatcher
    class Base
      attr_reader :base_path
      def initialize(base_path)
        @base_path = base_path
      end
      
      def matches?(path)
        false
      end
    end
  end
end