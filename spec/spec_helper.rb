require 'fast_autocomplete'
require 'json'

def keys_start_with(dict, substr)
  dict.keys.reduce([]) do |memo, key|
    memo << key if key.start_with?(substr.upcase)
    memo
  end.map(&:downcase)
end

def keys_end_with(dict, substr)
  dict.keys.reduce([]) do |memo, key|
    memo << key if key.end_with?(substr.upcase)
    memo
  end.map(&:downcase)
end