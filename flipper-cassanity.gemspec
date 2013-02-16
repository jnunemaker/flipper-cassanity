# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flipper/adapters/cassanity/version'

Gem::Specification.new do |gem|
  gem.name          = "flipper-cassanity"
  gem.version       = Flipper::Adapters::Cassanity::VERSION
  gem.authors       = ["John Nunemaker"]
  gem.email         = ["nunemaker@gmail.com"]
  gem.description   = %q{Flipper adapter for cassanity.}
  gem.summary       = %q{Flipper adapter for cassanity.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'flipper'
  gem.add_dependency 'cassanity'
end
