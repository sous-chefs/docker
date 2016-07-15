source 'https://rubygems.org'

group :docker do
  gem 'docker-api', '= 1.28.0'
end

group :rake do
  gem 'rake'
  gem 'tomlrb'
end

group :lint do
  gem 'foodcritic', '~> 7.0'
  gem 'cookstyle'
end

group :unit do
  gem 'berkshelf',  '~> 4.3'
  gem 'chefspec',   '~> 4.6'
  gem 'rspec-its'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.10'
  gem 'kitchen-sync'
  gem 'kitchen-inspec'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant'
end

group :kitchen_cloud do
  gem 'kitchen-digitalocean', git: 'https://github.com/someara/kitchen-digitalocean', branch: 'someara'
  gem 'kitchen-ec2'
end
