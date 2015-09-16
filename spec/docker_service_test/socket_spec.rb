require 'spec_helper'

describe 'docker_service_test::socket on centos-7.0' do
  cached(:default) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '7.0',
      step_into: 'docker_service'
    ) do |node|
      node.set['docker']['version'] = nil
    end.converge('docker_service_test::socket')
  end

  # Resource in docker_service_test::socket
  context 'compiling the test recipe' do
    it 'creates docker_service[default]' do
      expect(default).to create_docker_service('default')
    end
  end

  context 'stepping into docker_service[default] resource' do
    it 'creates remote_file[/usr/bin/docker]' do
      expect(default).to create_remote_file('/usr/bin/docker')
        .with(
          source: 'https://get.docker.io/builds/Linux/x86_64/docker-1.8.1',
          checksum: '843f90f5001e87d639df82441342e6d4c53886c65f72a5cc4765a7ba3ad4fc57',
          owner: 'root',
          group: 'root',
          mode: '0755'
        )
    end
  end
end
