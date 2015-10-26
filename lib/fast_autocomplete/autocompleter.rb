module FastAutocomplete
  # Example Usage
  # a = FastAutocomplete::Autocompleter.new(
  #   JSON.parse(File.read("#{Dir.pwd}/spec/data/dictionary.json")).keys.map(&:downcase),
  #   prefix: true)
  # a.autocomplete("wonder")
  # => ["wonders", "wonderer", "wondered", "wonderly", "wonderful", "wonderous", "wonderland", "wonderwork", "wonderment", "wonderingly", "wonderstruck", "wonder-worker", "wonder-working", "wonder", "unwonder"]
  class Autocompleter

    class UninitializedError < StandardError; end

    @@default_options = { bfs: true, limit: 0 }.freeze

    # Options
    # =======
    # limit           : integer
    #       default   : 0 for unlimited, otherwise n
    #       note      : use limit 0 if using wildcard search
    #                   if using prefix or suffix search, you can limit
    #
    # bfs             : boolean
    #       default   : true
    #       note      : use bfs for breadth first search of prefixes/suffixes
    #                   bfs will return strings in order of length
    #
    # dfs             : boolean
    #       default   : true
    #       note      : use dfs for depth first search of prefixes/suffixes
    #                   dfs will return strings in alpha ordering
    #
    # prefix          : boolean
    #       default   : true
    #       note      : if you set prefix true only, suffix trie will not be initialized
    #                   use this if you know you only want prefix searches
    #
    # suffix          : boolean
    #       default   : true
    #       note      : if you set suffix to true, only the suffix trie will be initialized
    #                   use this if you know you only want suffix searches
    #
    # case_sensitive  : boolean
    #       default   : false
    #       note      : if case sensitive is true, autocomplete will only work on matching case
    #                   otherwise the autocompleter will maintain a map from the downcase result
    #                   to the original key
    #                 : if case sensitive is false and multiple keys map onto the same key
    #                   the autocompleter will only keep the last mapping
    #                   Example: {'TiGER' => 'tiger', 'Tiger' => 'tiger'} autocomplete keeps
    #                     the mapping from tiger -> 'Tiger'
    attr_accessor :suffix_trie, :prefix_trie
    def initialize(words, options = { case_sensitive: false, both: true })
      if words.is_a?(Array)
        keys = words
      elsif words.is_a?(Hash)
        keys = words.keys
        @map = words
      else
        raise ArgumentError, 'words must be an array or a hash'
      end
      @case_sensitive = options[:case_sensitive] || false
      @key_map = keys.reduce({}) do |memo, key|
        memo[key.downcase] = key
        memo
      end unless @case_sensitive
      keys = keys.map(&:downcase) unless @case_sensitive
      @prefix_trie = FastAutocomplete::Trie.new(keys) if
          options[:prefix] || options[:both]
      @suffix_trie = FastAutocomplete::Trie.new(keys.map(&:reverse)) if
          options[:suffix] || options[:both]
      @options = options
    end

    public

    # Usage:
    # query    : String
    #       ex : 'wonder*' will perform a prefix search only
    #       ex : '*wonder' will perform a suffix search only
    #       ex : 'wonder*ment' will perform both a prefix & suffix and intersect the sets
    #       ex : 'wonder' will perform both a prefix & suffix search and union the sets
    def autocomplete(query, options = @@default_options)
      query = query.downcase unless @case_sensitive
      parsed = parse_wildcards(query)
      prefixes, suffixes = parsed.first, parsed.last
      pre = prefixes.map { |prefix| autocomplete_prefix(prefix, options) }.flatten
      suf = suffixes.map { |suffix| autocomplete_suffix(suffix, options) }.flatten
      return prefixes.empty? || suffixes.empty? ? pre + suf : pre & suf
    end

    # Usage:
    # If an autocompleter is initialized with a hash, this will return
    # the matches associated with autocompleted keys
    # Example:
    # $ autocomplete_matches('aard')
    # =>
    #   "AARD-VARK" => "An edentate mammal, of the genus Orycteropus, somewhat resembling a pig, common in some parts of Southern Africa. It burrows in the ground, and feeds entirely on ants, which it catches with itslong, slimy tongue."
    def autocomplete_matches(query, options = @@default_options)
      raise ArgumentError, 'words must be an array or a hash' if @map.nil?
      query = query.downcase unless @case_sensitive
      matches = autocomplete(query, options)
      map_to_results(matches)
    end

    def autocomplete_prefix(query, options = @@default_options)
      raise UninitializedError if @prefix_trie.nil?
      query = query.downcase unless @case_sensitive
      pre_results = @prefix_trie.autocomplete(query, options) unless
          @prefix_trie.nil?
      pre_results || []
    end

    def autocomplete_suffix(query, options = @@default_options)
      raise UninitializedError if @suffix_trie.nil?
      query = query.downcase unless @case_sensitive
      suf_results = @suffix_trie.autocomplete(query.reverse, options) unless
          @suffix_trie.nil?
      suf_results.map(&:reverse) || []
    end

    def map_to_results(matches)
      if @map.nil?
        return matches if @case_sensitive
        return matches.map{ |match| @key_map[match] }.flatten
      else
        matches.reduce({}) do |memo, key|
          if @case_sensitive
            memo[key] = @map[key]
          else
            memo[@key_map[key]] = @map[@key_map[key]]
          end
          memo
        end
      end
    end

    def parse_wildcards(substring)
      return [[substring], [substring]] if substring.index('*').nil?
      substrs = substring.split('*')
      s = substring[substring.length - 1] == '*' ? 1 : 0
      prefixes = substrs.slice(0, substrs.length - 1 + s)
      p = substring[0] == '*' ? 1 : 0
      suffixes = substrs.slice(1 - p, substrs.length)
      [prefixes.reject(&:empty?), suffixes.reject(&:empty?)]
    end
  end
end