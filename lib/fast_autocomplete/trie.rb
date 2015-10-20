module FastAutocomplete
  class Trie
    attr_accessor :size, :height

    def initialize(words, options = {})
      @words = words
      @root = Node.new('', nil)
      @height = 1 # height of trie
      @size = 1 # size of trie
      build
    end

    def build
      @words.each do |word|
        insert(word)
      end
    end

    def insert(word)
      node = @root
      chars = word.split('')
      chars.each_with_index do |c, index|
        if !node.has_child?(c)
          node.add_child(Node.new(c, node, index == chars.length - 1))
          @size += 1
          @height = [@height, index + 1].max
        end
        node = node.children[c]
      end
    end

    def remove(word)

    end

    def has?(word)

    end

    def autocomplete(word, options = { bfs: true, limit: 10 })
      node = @root
      chars = word.split('')
      prefix = ''
      chars.each_with_index do |c, index|
        break unless node.has_child?(c)
        prefix += c
        node = node.children[c]
      end
      suffixes = []
      return [] if node == @root  # no matches
      if options[:bfs]
        node.traverse_bfs(suffixes, prefix, options[:limit])
      else
        node.traverse_dfs(suffixes, prefix, options[:limit])
      end
      suffixes
    end
  end
end