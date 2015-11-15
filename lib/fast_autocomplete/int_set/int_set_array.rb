module FastAutocomplete
  module IntSet
    class IntSetArray < IntSetInterface
      # Sorted array backed set
      def initialize
        @children = [] # an array of tuples
        @s_max = nil # sentinel max node
      end

      # Overrides
      def has?(key)
        f = f_index(key)
        return false if f.nil?
        @children[f].key == key
      end

      def empty?
        @children.length == 0
      end

      def insert(key, value)
        f = f_index(key)
        if f.nil?
          @children << IntSetTuple.new(key, value)
          @s_max = key
        else
          @children.insert(f, IntSetTuple.new(key, value))
        end
      end

      def delete(key)
        i = f_index(key)
        @children.delete_at(i) unless i.nil?
      end

      def get(key)
        i = f_index(key)
        @children[i].value unless i.nil?
      end

      def values
        @children.map { |t| t.value }
      end

      private

      def f_index(key)
        #  this allocates a tremendous amount of memory, it doesn't get collected
        # (a = [*@children.each_with_index].bsearch { |x, _| x.key >= key }).nil? ? nil : a.last
        return nil if @s_max.nil? || @s_max < key
        i = 0
        while i < @children.size - 1 && @children[i].key < key do
          i += 1
        end
        i
      end
    end
  end
end