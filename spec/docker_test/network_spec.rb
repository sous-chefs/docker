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
end
