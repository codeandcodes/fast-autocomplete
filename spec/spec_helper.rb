require 'fast_autocomplete'
require 'json'

def keys_start_with(dict, substr)
  dict.keys.reduce([]) do |memo, key|
    memo << key if key.start_with?(substr.upcase)
    memo
  end
end

def keys_end_with(dict, substr)
  dict.keys.reduce([]) do |memo, key|
    memo << key if key.end_with?(substr.upcase)
    memo
  end
end

def downcase_keys_start_with(dict, substr)
  keys_start_with(dict, substr).map(&:downcase)
end

def downcase_keys_end_with(dict, substr)
  keys_end_with(dict, substr).map(&:downcase)
end