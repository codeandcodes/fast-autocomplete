module FastAutocomplete
  class Trie
    attr_accessor :size, :height, :root

    @@default_limit = 10

    def initialize(words)
      @root = Node.new('', nil)
      build(words)
    end

    def remove(word)
      n = traverse(word)
      return false if n.last.nil?
      if n.last.has_children?
        n.last.terminal = false
      else
        n.last.parent.children.delete(n.last.value)
      end
      true
    end

    def has?(word)
      (n = traverse(word)).last.nil? ? false : n.last.terminal
    end

    def traverse(word)
      node = @root
      prefix = ''
      word.each_char do |c|
        i = c.ord
        if node.has_child?(i)
          prefix << c
          node = node.children.get(i)
        else
          return [prefix, nil] if node.terminal
          return [nil, nil]
        end
      end
      [prefix, node]
    end

    def autocomplete(word, options = { bfs: true, limit: 10 })
      return [] if word.empty?
      to = traverse(word)
      prefix, node = to.first, to.last
      if node.nil? # no matches
        return [prefix] unless prefix.nil?
        return []
      end
      suffixes = []
      if options[:bfs]
        node.traverse_bfs(suffixes, prefix, options[:limit] || @@default_limit)
      else
        node.traverse_dfs(suffixes, prefix, options[:limit] || @@default_limit)
      end
      suffixes
    end

    private

    def build(words)
      words.each do |word|
        @root.insert(word)
      end
    end
  end
end