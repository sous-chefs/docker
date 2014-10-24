require 'serverspec'
include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

# Install required gems
require 'busser/rubygems'
Busser::RubyGems.install_gem('mixlib-shellout', '~> 1.0')
Busser::RubyGems.install_gem('docker-api', '~> 1.0')

# Require support files
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require_relative(file) }

# Require shared examples
Dir[File.expand_path('../spec/**/*.rb', __FILE__)].each { |file| require_relative(file) }

RSpec.configure do |config|
  config.before(:all) do
    config.os = backend(Serverspec::Commands::Base).check_os
  end
end
