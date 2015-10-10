source 'https://rubygems.org'

gem 'chef', github: 'chef/chef'

group :lint do
  gem 'foodcritic', '~> 4.0'
  gem 'rake'
end

group :unit do
  gem 'berkshelf', '~> 4.0'
  gem 'chefspec', github: 'jkeiser/chefspec', branch: 'jk/chefspec-12.5'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.3'
  gem 'kitchen-vagrant'
end

group :development do
  gem 'guard'
  gem 'growl'
  gem 'guard-foodcritic'
  gem 'guard-rspec'
  gem 'guard-rubocop'
end
