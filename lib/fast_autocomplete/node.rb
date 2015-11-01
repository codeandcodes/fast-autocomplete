module FastAutocomplete
  class Node
    attr_accessor :value, :parent, :children, :terminal

    def initialize(value, parent, terminal = false)
      @value = value
      @parent = parent
      @terminal = terminal
      @children = Hash.new
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
      node = self
      l = word.length
      counter = 0
      word.each_char do |c|
        i = c.ord
        node.children[i] ||= Node.new(c, node, l == 1)
        counter += 1
        node = node.children[i]
        node.terminal = true if counter == l
      end
    end

    def traverse_bfs(array, prefix, limit = 10)
      queue = Queue.new
      queue.enq([prefix, self])
      while !queue.empty? do
        entry = queue.deq
        array << entry.first if entry.last.terminal
        break if limit > 0 && array.length >= limit
        entry.last.children.each_value do |child|
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