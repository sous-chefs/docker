require 'spec_helper'

shared_examples_for 'a non-ubuntu platform' do
  it 'installs the lxc package' do
    expect(chef_run).to install_package('lxc')
  end
end

describe 'docker::lxc' do
  context 'when running on debian' do
    it_behaves_like 'a non-ubuntu platform' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'debian', version: '7.4').converge(described_recipe)
      end
    end
  end

  context 'when running on oracle' do
    it_behaves_like 'a non-ubuntu platform' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'oracle', version: '6.5').converge(described_recipe)
      end
    end
  end

  context 'when running on ubuntu' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'includes the lxc recipe' do
      expect(chef_run).to include_recipe('lxc')
    end
  end
end
