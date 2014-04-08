require 'chefspec'
require 'chefspec/berkshelf'

# See https://github.com/sethvargo/chefspec/issues/393
# ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.log_level = :error
  config.platform = 'ubuntu'
  config.version = '12.04'
end
