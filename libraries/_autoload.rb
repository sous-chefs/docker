# Set up rubygems to activate any gems we find herein.
ENV['GEM_PATH'] = ([File.expand_path('../../files/default/vendor', __FILE__)] + Gem.path).join(Gem.path_separator)
Gem.paths = ENV
gem 'docker-api', '~> 1.24'

$LOAD_PATH.unshift *Dir[File.expand_path('..', __FILE__)]
