require 'chefspec'
require 'chefspec/berkshelf'

# See https://github.com/sethvargo/chefspec/issues/393
# ChefSpec::Coverage.start!

# Require all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

# Prevent system calls from getting run on our local machine
# lxc cookbook does this: https://github.com/hw-cookbooks/lxc/blob/master/recipes/default.rb#L47
# TODO: Figure out a better way to do this - couldn't get stubbing to work (see below)
# Kernel module
# rubocop:disable all
module Kernel
  def system(*)
    true
  end
end
# rubocop:enable all

# Specify defaults -- these can be overridden
RSpec.configure do |config|
  config.log_level = :error # necessary to suppress all the WARNs for Chef resource cloning
  config.platform = 'ubuntu'
  config.version = '12.04'
  config.before(:each) do
    stub_command('/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"').and_return(false)
    # Also stub system, because it's called in the lxc cookbook: https://github.com/hw-cookbooks/lxc/blob/9f113a34c0535c3e474b03fdd45af886c2132d3c/recipes/default.rb#L47
    # allow(Kernel).to receive(:system).and_return(true)
  end
end
