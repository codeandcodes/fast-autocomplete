module FastAutocomplete
  class Node

    attr_accessor :value, :parent, :children, :terminal

    def initialize(value, parent, terminal = false)
      @value = value
      @parent = parent
      @terminal = terminal
      @children = {}
    end

    def add_child(node)
      @children[node.value] = node
    end

    def has_child?(value)
      @children.key?(value)
    end

    def traverse_bfs(array, prefix, limit = 10)
      queue = Queue.new
      queue.enq([prefix, self])
      while !queue.empty? do
        entry = queue.deq
        array << entry.first if entry.last.terminal
        break if array.length >= limit
        entry.last.children.each_pair do |value, child|
          queue.enq([entry.first + value, child])
        end
      end
    end

    def traverse_dfs(array, prefix, limit = 10)
      @children.each_key do |c|
        break if array.length >= limit
        @children[c].traverse_dfs(array, prefix + c, limit)
      end
      if @terminal
        return if array.length >= limit
        array << prefix
      end
    end
  end
end