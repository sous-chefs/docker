require 'spec_helper'

describe 'docker_test::network' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge('docker_test::network') }

  context 'testing default action, default properties' do
    it 'creates a network without options' do
      expect(chef_run).to create_docker_network('test-network')
    end
  end

  context 'testing default action, overlay network' do
    it 'creates a network with overlay driver' do
      expect(chef_run).to create_docker_network('test-network-overlay').with(
        driver: 'overlay'
      )
    end
  end

  context 'testing default action, with gateway and subnet' do
    it 'creates a network with subnet and gateway' do
      expect(chef_run).to create_docker_network('test-network-ip').with(
        subnet: '192.168.88.0/24',
        gateway: '192.168.88.3'
      )
    end
  end

  context 'testing default action, with aux address' do
    it 'creates a network with aux_addr' do
      expect(chef_run).to create_docker_network('test-network-aux').with(
        subnet: '192.168.89.0/24',
        gateway: '192.168.89.3',
        aux_address: ['a=192.168.89.4', 'b=192.168.89.5']
      )
    end
  end

  context 'testing to connect a container to a network' do
    it 'connects a container to a network' do
      expect(chef_run).to connect_docker_network('test-network-aux-connect').with(
        network_name: 'test-network-aux',
        container: 'busybox-network'
      )
    end
  end

  context 'testing to disconnect a container from a network' do
    it 'disconnect a container from a network' do
      expect(chef_run).to disconnect_docker_network('test-network-aux-disconnect').with(
        network_name: 'test-network-aux',
        container: 'busybox-network'
      )
    end
  end

  context 'testing to delete a network' do
    it 'deletes a network' do
      expect(chef_run).to delete_docker_network('test-network-ip')
    end
  end
end
