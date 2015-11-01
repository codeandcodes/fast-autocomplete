# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fast_autocomplete/version'

Gem::Specification.new do |spec|
  spec.name          = "fast_autocomplete"
  spec.version       = FastAutocomplete::VERSION
  spec.authors       = ["Al Ho"]
  spec.email         = ["codeandcodes@gmail.com"]
  spec.summary       = 'A fast autocomplete gem'
  spec.description   = 'A gem that constructs a prefix trie from a list of strings or a hash.'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files lib/ -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "google_hash", "~> 0.8.8"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "json", "~> 1.8.2"
  spec.add_development_dependency "ruby-prof", "~> 0.15.8"
end
