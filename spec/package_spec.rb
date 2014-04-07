require 'spec_helper'

describe 'docker::package' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'adds the docker apt repository' do
    expect(chef_run).to add_apt_repository('docker')
  end

  it 'installs the lxc-docker package' do
    expect(chef_run).to install_package('lxc-docker')
  end

  context 'when version is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['version'] = '0.9.1'
      runner.converge(described_recipe)
    end

    it 'installs the lxc-docker-version package' do
      expect(chef_run).to install_package('lxc-docker-0.9.1')
    end
  end

  context 'when remove is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['package']['action'] = 'remove'
      runner.converge(described_recipe)
    end

    it 'removes the lxc-docker package' do
      expect(chef_run).to remove_package('lxc-docker')
    end
  end

  context 'when upgrade is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['package']['action'] = 'upgrade'
      runner.converge(described_recipe)
    end

    it 'upgrades the lxc-docker package' do
      expect(chef_run).to upgrade_package('lxc-docker')
    end
  end
end
