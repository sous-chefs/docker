# -*- encoding: utf-8 -*-
require File.expand_path('../lib/docker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Swipely, Inc."]
  gem.email         = %w{tomhulihan@swipely.com bright@swipely.com toddlunter@swipely.com}
  gem.description   = %q{A simple REST client for the Docker Remote API}
  gem.summary       = %q{A simple REST client for the Docker Remote API}
  gem.homepage      = 'https://github.com/swipely/docker-api'
  gem.license       = 'MIT'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "docker-api"
  gem.require_paths = %w{lib}
  gem.version       = Docker::VERSION
  gem.add_dependency 'excon', '>= 0.38.0'
  gem.add_dependency 'json'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'cane'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'vcr', '>= 2.7.0'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'
  # > 1.3.4 doesn't support ruby 1.9.2
  gem.add_development_dependency 'parallel', '1.3.3'
end
