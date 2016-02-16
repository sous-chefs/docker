require 'spec_helper'

describe 'docker_test::network' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge('docker_test::network') }

  context 'creates a network with defaults' do
    it 'creates docke_network_a' do
      expect(chef_run).to create_docker_network('network_a')
    end

    it 'creates echo-base-network_a' do
      expect(chef_run).to run_docker_container('echo-base-network_a')
    end

    it 'creates echo-station-network_a' do
      expect(chef_run).to run_docker_container('echo-station-network_a')
    end
  end

  context 'creates a network with subnet and gateway' do
    it 'creates docke_network_b' do
      expect(chef_run).to create_docker_network('network_b').with(
        subnet: '192.168.88.0/24',
        gateway: '192.168.88.1'
      )
    end

    it 'creates echo-base-network_b' do
      expect(chef_run).to run_docker_container('echo-base-network_b')
    end

    it 'creates echo-station-network_b' do
      expect(chef_run).to run_docker_container('echo-station-network_b')
    end
  end

  context 'creates a network with aux_address' do
    it 'creates docke_network_c' do
      expect(chef_run).to create_docker_network('network_c').with(
        subnet: '192.168.89.0/24',
        gateway: '192.168.89.1',
        aux_address: ['a=192.168.89.2', 'b=192.168.89.3']
      )
    end

    it 'creates echo-base-network_c' do
      expect(chef_run).to run_docker_container('echo-base-network_c')
    end

    it 'creates echo-station-network_c' do
      expect(chef_run).to run_docker_container('echo-station-network_c')
    end
  end

  context 'creates a network with overlay driver' do
    it 'creates network_d' do
      expect(chef_run).to create_docker_network('network_d').with(
        driver: 'overlay'
      )
    end
  end

  context 'testing to connect container to network' do
    it 'created a container' do
      expect(chef_run).to run_docker_container('network-container').with(
        repo: 'alpine',
        tag: '4.1',
        command: 'sleep 120'
      )
    end

    it 'created the network we are connecting to a container' do
      expect(chef_run).to create_docker_network('test-network-connect').with(
        container: 'network-container'
      )
    end

    it 'connects container to network' do
      expect(chef_run).to connect_docker_network('test-network-connect').with(
        container: 'network-container'
      )
    end
  end

  context 'testing ip range' do
    it 'should set a ip range' do
      expect(chef_run).to create_docker_netwrok('test-network-ip-range').with(
        subnet: '192.168.90.0/24',
        ip_range: '192.168.90.32/28'
      )
    end
  end

  context 'testing to connect a container to a network' do
    xit 'connects a container to a network' do
      expect(chef_run).to connect_docker_network('test-network-aux-connect').with(
        network_name: 'test-network-aux',
        container: 'network-container'
      )
    end
  end

  context 'testing to disconnect a container from a network' do
    xit 'disconnect a container from a network' do
      expect(chef_run).to disconnect_docker_network('test-network-aux-disconnect').with(
        network_name: 'test-network-aux',
        container: 'network-container'
      )
    end
  end

  context 'testing to delete a network' do
    xit 'deletes a network' do
      expect(chef_run).to delete_docker_network('delete-test-network-ip').with(
        network_name: 'test-network-ip'
      )
    end
  end
end
