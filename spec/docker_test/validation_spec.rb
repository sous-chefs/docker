require 'spec_helper'

describe 'docker_test::validation' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge('docker_test::validation') }

  it 'creates a service with conflicting version and installation method' do
    expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
  end
end
