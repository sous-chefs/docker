require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker::upstart' do
  include Helpers::Docker

  it 'starts docker' do
    service('docker').must_be_running
  end
end
