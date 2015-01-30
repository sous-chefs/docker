require 'spec_helper'

describe 'docker::group' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'creates the docker group' do
    expect(chef_run).to create_group('docker')
  end

  it 'manages the docker group' do
    expect(chef_run).to manage_group('docker')
  end

  context 'when group is set' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.node.set['docker']['group'] = 'vagrant'
      runner.converge(described_recipe)
    end

    it 'creates the set group' do
      expect(chef_run).to create_group('vagrant')
    end

    it 'manages the set group' do
      expect(chef_run).to manage_group('vagrant')
    end
  end

  context 'when group_members is set' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.node.set['docker']['group_members'] = ['vagrant']
      runner.converge(described_recipe)
    end

    it 'manages the docker group members' do
      expect(chef_run).to manage_group('docker').with(members: ['vagrant'])
    end
  end
end
