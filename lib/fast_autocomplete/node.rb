module FastAutocomplete
  class Node
    attr_accessor :value, :parent, :children, :terminal

    def initialize(value, parent, terminal = false)
      @value = value
      @parent = parent
      @terminal = terminal
      @children = {}
    end

    public

    def has_child?(value)
      @children.key?(value)
    end

    def has_children?
      !@children.keys.empty?
    end

    def path(str = '')
      if self.parent.nil?
        return str
      end
      return self.parent.path + self.value
    end

    def depth
      if self.parent.nil?
        return 1
      end
      return 1 + self.parent.depth
    end

    def insert(word)
      return if word.empty? || word.nil?
      c = word[0]
      i = c.ord
      l = word.length
      node = self
      if !node.has_child?(i)
        node.children[i] = Node.new(c, node, l == 1)
      end
      node = node.children[i]
      node.terminal = true if l == 1
      node.insert(word.slice(1, l - 1))
    end

    def traverse_bfs(array, prefix, limit = 10)
      queue = Queue.new
      queue.enq([prefix, self])
      while !queue.empty? do
        entry = queue.deq
        array << entry.first if entry.last.terminal
        break if limit > 0 && array.length >= limit
        entry.last.children.each_pair do |value, child|
          queue.enq([entry.first + child.value, child])
        end
      end
    end

    def traverse_dfs(array, prefix, limit = 10)
      @children.each_key do |c|
        break if limit > 0 && array.length >= limit
        @children[c].traverse_dfs(array, prefix + c, limit)
      end
      if @terminal
        return if array.length >= limit
        array << prefix
      end
    end
  end
end