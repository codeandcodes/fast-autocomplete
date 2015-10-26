# FastAutocomplete

FastAutocomplete provides a backend data structure and framework for autocompleting
partial queries (prefixes, suffixes or pre*suffix) queries.  The design is based
on prefix and suffix tries.

FastAutocomplete can accept either an array of words or a hash and will autocomplete
on either each element in the array or each key in the hash.

If an array is passed in, an array will be passed back.
If a hash is passed in, you can invoke #autocomplete_matches to return a filtered
hash by the autocompleted results.

This is a work-in-progress.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fast_autocomplete'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fast_autocomplete

## Usage

This gem is unopinionated about how you decide to use the backend.  Thus, plug it
right into your controller, but you will have to rebuild or add/remove elements
by manually invoking the API.

### Public API

You can instantiate an autocompleter with either an array or a hash.

```ruby
  autocompleter = a = FastAutocomplete::Autocompleter.new(["apples", "banana", "honeydew", "kiwi", "lemon", "mango", "orange", "strawberry"])
```

Then you can autocomplete on prefixes, suffixes, or pre*suffixes:

```ruby
  # by default, autocomplete will do a prefix and suffix search and union the results together
  a.autocomplete('a')
   => ["apples", "banana"]

  # Prefix search
  a.autocomplete('a*')
   => ["apples"]
  # or
  a.autocomplete_prefix('a')

  # Suffix search
  a.autocomplete('*a')
   => ["banana"]

  # Pre*suffix search
  a.autocomplete('a*les')
   => ["apples"]
```

#### Options

You can instantiate each autocompleter with a set of options (reproduced here)
```ruby
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
```

### Example Usage (for adding to rails):

#### Add this to your controller
```ruby
  def typeahead
    autocompleter = Rails.cache.fetch('companies_ac', expires_in: 1.hour) do
      FastAutocomplete::Autocompleter.new(Company.all.group_by(&:name))
    end
    respond_to do |format|
      format.json { render json: autocompleter.autocomplete_matches(params[:query]) }
    end
  end
```

#### Then add your route
```ruby
  resources :your_controller do
    collection do
      get 'typeahead'
    end
  end

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fast_autocomplete/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
