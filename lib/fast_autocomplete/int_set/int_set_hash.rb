module FastAutocomplete
  module IntSet
    class IntSetHash < IntSetInterface
      # Hash-backed int set
      def initialize
        @children = {}
      end

      # Overrides
      def has?(key)
        @children.key?(key)
      end

      def empty?
        @children.keys.length == 0
      end

      def insert(key, value)
        @children[key] = value
      end

      def delete(key)
        @children.delete(key)
      end

      def get(key)
        @children[key]
      end

      def values
        @children.values
      end
    end
  end
end