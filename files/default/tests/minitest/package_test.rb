require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker::package' do
  include Helpers::Docker

  it 'installs lxc-docker package' do
    package('lxc-docker').must_be_installed
  end
end
