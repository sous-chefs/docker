require 'spec_helper'

describe 'Chef::Provider::DockerService::Sysvinit with Centos' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '7.0',
      step_into: 'docker_service'
    ).converge('docker_service_test::sysvinit')
  end

  it 'creates docker_service[default]' do
    expect(chef_run).to create_docker_service('default')
  end

  it 'creates the sysvinit file' do
    expect(chef_run).to create_template('/etc/init.d/docker')
  end
end
