source 'https://rubygems.org'

group :rake do
  gem 'rake'
  gem 'tomlrb'
end

group :lint do
  gem 'foodcritic', '~> 6.0'
  gem 'rubocop', '~> 0.36'
end

group :unit do
  gem 'berkshelf',  '~> 4.0'
  gem 'chefspec',   '~> 4.5'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.4.2'
  gem 'kitchen-sync'
  gem 'kitchen-inspec'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.19'
end

group :kitchen_cloud do
  gem 'kitchen-digitalocean', git: 'https://github.com/someara/kitchen-digitalocean', branch: 'someara'
  gem 'kitchen-ec2'
end
