require 'benchmark'
require 'json'
require 'fast_autocomplete'

namespace :benchmark do
  def read_dictionary
    f = File.read("#{Dir.pwd}/spec/data/dictionary.json")
    if f.nil?
      f = File.read("#{Dir.pwd}/spec/data/abridged.json")
    end
    JSON.parse(f)
  end

  def random_substrings(dictionary, options = {n: 10000, prefix: true})
    words = []
    options[:n].times do
      w = dictionary.keys.sample
      words << (options[:prefix] ? w.slice(0, rand(w.length - 1) + 1) : w.slice(rand(w.length - 1), w.length))
    end
    words
  end

  desc 'benchmark all'
  task :all => ["benchmark:creation", "benchmark:prefix", "benchmark:suffix"]

  desc 'benchmark autocomplete creation against dictionary'
  task :creation, [:times] do |task, args|
    dictionary = read_dictionary
    n = args[:times] || 5
    puts "Dictionary size: #{dictionary.size}.  Running through creation #{n} times."
    Benchmark.bm(n, ">avg:") do |x|
      tt = x.report("creation:") { for i in 1..n; FastAutocomplete::Autocompleter.new(dictionary); end }
      [tt/n]
    end
  end

  desc 'benchmark autocomplete prefix search against dictionary'
  task :prefix, [:times] do |task, args|
    dictionary = read_dictionary
    n = args[:times].to_i == 0 ? 1000 : args[:times].to_i
    puts "Dictionary size: #{dictionary.size}.  Running through prefix traversal #{n} times."
    autocompleter = FastAutocomplete::Autocompleter.new(dictionary)
    words = random_substrings(dictionary, n: n, prefix: true)
    Benchmark.bm do |x|
      tt = x.report("prefix:") do
        n.times { |i| autocompleter.autocomplete_prefix(words[i]) }
      end
      [tt/n]
    end
  end

  desc 'benchmark autocomplete suffix search against dictionary'
  task :suffix, [:times] do |task, args|
    dictionary = read_dictionary
    n = args[:times].to_i == 0 ? 10000 : args[:times].to_i
    puts "Dictionary size: #{dictionary.size}.  Running through suffix traversal #{n} times."
    autocompleter = FastAutocomplete::Autocompleter.new(dictionary)
    words = random_substrings(dictionary, n: n, suffix: true)
    Benchmark.bm do |x|
      tt = x.report("suffix:") do
        n.times { |i| autocompleter.autocomplete_suffix(words[i]) }
      end
      [tt/n]
    end
  end

  desc 'brute force'
  task :brute_force, [:times] do |task, args|
    dictionary = read_dictionary
    n = args[:times].to_i == 0 ? 1000 : args[:times].to_i
    puts "Dictionary size: #{dictionary.size}.  Running through brute force traversal #{n} times."
    words = random_substrings(dictionary, n: n, suffix: true)
    Benchmark.bm do |x|
      tt = x.report("brute force:") do
        n.times do |i|
          dictionary.keys.select {|k| k.start_with?(words[i])}
        end
      end
      [tt/n]
    end
  end
end