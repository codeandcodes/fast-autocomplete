module FastAutocomplete
  module IntSet
    class IntSetInterface
      class UnimplementedError; end
      # this class backs prefix tries through implementing a common interface

      attr_accessor :children

      def initialize
        @children = nil
      end

      def has?(key)
        raise UnimplementedError
      end

      def empty?
        raise UnimplementedError
      end

      def insert(key, value)
        raise UnimplementedError
      end

      def delete(key)
        raise UnimplementedError
      end

      def get(key)
        raise UnimplementedError
      end

      def values
        raise UnimplementedError
      end
    end
  end
end