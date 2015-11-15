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
        # DEFAULT BSEARCH
        # (a = [*@children.each_with_index].bsearch { |x, _| x.key >= key }).nil? ? nil : a.last
        return nil if @s_max.nil? || @s_max < key
        # ITERATIVE
        # i = 0
        # while i < @children.size - 1 && @children[i].key < key do
        #   i += 1
        # end
        # i
        return b_search(key)
      end

      # [1, 5, 10, 22, 33, 45]
      # b_search(1) = 0
      # b_search(46) = nil
      # b_search(10) = 2
      # b_search(11) = 3
      def b_search(key)
        low, hi = 0, @children.size
        while (low < hi)
          mid = (low + hi) / 2
          if @children[mid].key == key
            return mid
          elsif @children[mid].key < key
            low = mid + 1
          else
            hi = mid
          end
        end
        if hi == low # first element
          return 0 if hi == 0
          return hi if hi < @children.size
          return nil
        end
      end
    end
  end
end