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
