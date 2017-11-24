require 'spec_helper'

describe 'docker_test::swarm' do
  cached(:chef_run) do
    ChefSpec::SoloRunner
      .new(platform: 'ubuntu', version: '16.04')
      .converge(described_recipe)
  end

  describe 'Cluster creation' do
    it 'creates a docker_swarm_manager resource' do
      expect(chef_run).to create_docker_swarm_manager('test')
        .with(first_manager: true)
    end
  end

  describe 'Overlay network creation' do
    it 'creates a docker_swarm_overlay_network resource' do
      expect(chef_run).to create_docker_swarm_overlay_network('test_network')
    end
  end
end
