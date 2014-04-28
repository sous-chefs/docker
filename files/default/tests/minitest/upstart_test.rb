require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker::upstart' do
  include Helpers::Docker

  it 'starts docker' do
    if node['platform'] == 'ubuntu' && Chef::VersionConstraint.new('>= 14.04').include?(node['platform_version'])
      service('docker.io').must_be_running
    else
      service('docker').must_be_running
    end
  end
end
