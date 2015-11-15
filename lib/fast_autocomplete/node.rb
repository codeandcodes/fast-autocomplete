module FastAutocomplete
  class Node
    attr_accessor :value, :parent, :children, :terminal

    def initialize(value, parent, terminal = false)
      @value = value
      @parent = parent
      @terminal = terminal
      @children = IntSet::IntSetArray.new # can replace this implementation
    end

    public

    def has_child?(value)
      @children.has?(value)
    end

    def has_children?
      !@children.empty?
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
      word.bytes.each do |c|
        i = c
        node.children.insert(i, Node.new(c.chr, node, l == 1)) unless node.children.has?(i)
        counter += 1
        node = node.children.get(i)
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
        entry.last.children.values.each do |child|
          queue.enq([entry.first + child.value, child])
        end
      end
    end

    def traverse_dfs(array, prefix, limit = 10)
      if @terminal
        return if limit > 0 && array.length >= limit
        array << prefix
      end
      @children.values.each do |c|
        break if limit > 0 && array.length >= limit
        c.traverse_dfs(array, prefix + c.value, limit)
      end
    end
  end
end