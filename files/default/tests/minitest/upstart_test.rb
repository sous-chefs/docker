require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker::upstart' do
  include Helpers::Docker

  it 'starts docker' do
    if Docker::Helpers.using_docker_io_package?(node)
      service('docker.io').must_be_running
    else
      service('docker').must_be_running
    end
  end
end
