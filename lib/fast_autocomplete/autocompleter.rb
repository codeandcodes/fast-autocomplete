module FastAutocomplete
  # Example Usage
  # a = FastAutocomplete::Autocompleter.new(
  #   JSON.parse(File.read("#{Dir.pwd}/spec/data/dictionary.json")).keys.map(&:downcase),
  #   prefix: true)
  # a.autocomplete("wonder")
  # => ["wonders", "wonderer", "wondered", "wonderly", "wonderful", "wonderous", "wonderland", "wonderwork", "wonderment", "wonderingly", "wonderstruck", "wonder-worker", "wonder-working", "wonder", "unwonder"]
  class Autocompleter

    class UnitializedError < StandardError; end

    @@default_options = { bfs: true, limit: 0 }.freeze

    # Usage
    # options
    # limit : interger
    #   ex  : 0 for unlimited, otherwise n
    #   note: use limit 0 if using wildcard search
    #         if using prefix or suffix search, you can limit
    #
    # bfs   : boolean
    #   ex  : true
    #   note: use bfs for breadth first search of prefixes/suffixes
    #         bfs will return strings in order of length
    #
    # dfs   : boolean
    #   ex  : true
    #   note: use dfs for depth first search of prefixes/suffixes
    #         dfs will return strings in alpha ordering
    #
    # prefix: boolean
    #   ex  : true
    #   note: if you set prefix true only, suffix trie will not be initialized
    #         use this if you know you only want prefix searches
    #
    # suffix: boolean
    #   ex  : true
    #   note: if you set suffix to true, only the suffix trie will be initialized
    #         use this if you know you only want suffix searches
    attr_accessor :suffix_trie, :prefix_trie
    def initialize(words, options = { both: true })
      @prefix_trie = FastAutocomplete::Trie.new(words) if
          options[:prefix] || options[:both]
      @suffix_trie = FastAutocomplete::Trie.new(words.map(&:reverse)) if
          options[:suffix] || options[:both]
      @options = options
    end

    public

    # Usage:
    # substring: String
    #       ex : 'wonder*' will perform a prefix search only
    #       ex : '*wonder' will perform a suffix search only
    #       ex : 'wonder*ment' will perform both a prefix & suffix and intersect the sets
    #       ex : 'wonder' will perform both a prefix & suffix search and union the sets
    def autocomplete(substring, options = @@default_options)
      parsed = parse_wildcards(substring)
      prefixes, suffixes = parsed.first, parsed.last
      pre = prefixes.map { |prefix| autocomplete_prefix(prefix, options) }.flatten
      suf = suffixes.map { |suffix| autocomplete_suffix(suffix, options) }.flatten
      return substring.index('*').nil? ? pre + suf : pre & suf
    end

    def autocomplete_prefix(substring, options = @@default_options)
      raise UnitializedError if @prefix_trie.nil?
      pre_results = @prefix_trie.autocomplete(substring, options) unless
          @prefix_trie.nil?
      pre_results || []
    end

    def autocomplete_suffix(substring, options = @@default_options)
      raise UnitializedError if @suffix_trie.nil?
      suf_results = @suffix_trie.autocomplete(substring.reverse, options) unless
          @suffix_trie.nil?
      suf_results.map(&:reverse) || []
    end

    protected

    private

    def parse_wildcards(substring)
      substrs = substring.split('*')
      p = substring[0] === '*' ? 1 : 0
      s = substring[substring.length-1] === '*' ? 1 : 0
      prefixes = substrs.length > 1 ? substrs.slice(p, substrs.length - 1 + s) : substrs
      suffixes = substrs.length > 1 ? substrs.slice(1 - p, substrs.length - s) : substrs
      [prefixes, suffixes]
    end

  end
end