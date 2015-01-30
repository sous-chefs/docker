source 'https://rubygems.org'

gem 'rake'

group :test, :integration do
  gem 'berkshelf', '~> 3.0'
end

group :test do
  gem 'chefspec', '~> 4.2.0'
  # elecksee is lxc dependency
  gem 'elecksee', '~> 1.0.20'
  gem 'foodcritic', '~> 3.0.3'
  gem 'rubocop', '~> 0.23'
end

group :integration do
  gem 'busser-serverspec', '~> 0.2.6'
  gem 'kitchen-vagrant', '~> 0.14'
  gem 'test-kitchen', '~> 1.1'
end

# group :development do
#   gem 'guard',         '~> 2.0'
#   gem 'guard-kitchen'
#   gem 'guard-rubocop', '~> 1.0'
#   gem 'guard-rspec',   '~> 3.0'
#   gem 'rb-inotify',    :require => false
#   gem 'rb-fsevent',    :require => false
#   gem 'rb-fchange',    :require => false
# end
