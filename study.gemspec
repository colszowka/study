# -*- encoding: utf-8 -*-
require File.expand_path('../lib/study/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Christoph Olszowka"]
  gem.email         = ["christoph at olszowka dot de"]
  gem.description   = %q{Easy application operation metrics with Ruby using munin and redis}
  gem.summary       = %q{Easy application operation metrics with Ruby using munin and redis}
  gem.homepage      = "https://github.com/colszowka/study"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "study"
  gem.require_paths = ["lib"]
  gem.version       = Study::VERSION
  
  gem.add_dependency 'redis'
  
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'simplecov'
end
