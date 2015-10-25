module FastAutocomplete
  class Trie
    attr_accessor :size, :height, :root

    @@default_limit = 10

    def initialize(words, options = {})
      @words = words
      @root = Node.new('', nil)
      build
    end

    def build
      @words.each do |word|
        @root.insert(word)
      end
    end

    def remove(word)

    end

    def has?(word)

    end

    def traverse(word)
      node = @root
      chars = word.split('')
      prefix = ''
      chars.each_with_index do |c, index|
        if node.has_child?(c)
          prefix += c
          node = node.children[c]
        else
          return [prefix, nil] if node.terminal
          return [nil, nil]
        end
      end
      [prefix, node]
    end

    def autocomplete(word, options = { bfs: true, limit: 10 })
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
  end
end