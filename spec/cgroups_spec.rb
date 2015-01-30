require 'spec_helper'

describe 'docker::cgroups' do
  context 'when running on oracle 6.5' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'oracle', version: '6.5').converge(described_recipe)
    end

    it 'installs the libcgroup package' do
      expect(chef_run).to install_package('libcgroup')
    end

    it 'starts and enables the cgconfig service' do
      expect(chef_run).to enable_service('cgconfig')
      expect(chef_run).to start_service('cgconfig')
    end
  end

  context 'when running on any ubuntu platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'should install the cgroup-bin package' do
      expect(chef_run).to install_package('cgroup-bin')
    end
  end

  context 'when running on ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'should start the cgconfig service' do
      expect(chef_run).to start_service('cgconfig')
    end

    it 'should start the cgred service' do
      expect(chef_run).to start_service('cgred')
    end
  end

  context 'when running on other ubuntu platforms' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04').converge(described_recipe)
    end

    it 'should start the cgroup-lite service' do
      expect(chef_run).to start_service('cgroup-lite')
    end
  end
end
