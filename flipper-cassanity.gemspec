# -*- encoding: utf-8 -*-
require File.expand_path('../lib/flipper/adapters/cassanity/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "flipper-cassanity"
  gem.version       = Flipper::Adapters::Cassanity::VERSION
  gem.authors       = ["John Nunemaker"]
  gem.email         = ["nunemaker@gmail.com"]
  gem.description   = %q{Cassanity adapter for Flipper.}
  gem.summary       = %q{Cassanity adapter for Flipper.}
  gem.homepage      = "http://jnunemaker.github.com/flipper-cassanity"
  gem.require_paths = ["lib"]

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_dependency 'flipper', '~> 0.5.0'
  gem.add_dependency 'cassanity', '~> 0.4.0'
end
