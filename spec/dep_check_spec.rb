require 'spec_helper'

describe 'docker::dep_check' do

  context 'when running on darwin' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'mac_os_x', version: '10.9.2').converge(described_recipe)
    end

    before do
      allow_any_instance_of(Chef::Recipe).to receive(:binary_installed?).with('VboxManage').and_return(false)
      allow_any_instance_of(Chef::Recipe).to receive(:binary_installed?).with('boot2docker').and_return(false)
    end

    it 'should fail if it can\'t find VirtualBox or if VirtualBox is not in the run_list' do
      expect { chef_run }.to raise_error(DockerCookbook::Exceptions::MissingDependency)
    end

    it 'should fail if it can\'t find boot2docker or if boot2docker is not in the run_list' do
      expect { chef_run }.to raise_error(DockerCookbook::Exceptions::MissingDependency)
    end
  end

  context 'when running debian' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.automatic['kernel']['release'] = '3.2.0-26-generic'
      end.converge(described_recipe)
    end

    it 'should fail if kernel < 3.8' do
      expect { chef_run }.to raise_error(DockerCookbook::Exceptions::InvalidKernelVersion)
    end
  end

  context 'when running on redhat' do
    context 'with 32bit archtiecture' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'redhat', version: '6.5') do |node|
          node.automatic['kernel']['machine'] = 'i386'
        end.converge(described_recipe)
      end

      it 'should fail' do
        expect { chef_run }.to raise_error(DockerCookbook::Exceptions::InvalidArchitecture)
      end
    end

    context 'with platform < 6.5' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'redhat', version: '5.8').converge(described_recipe)
      end

      it 'should fail' do
        expect { chef_run }.to raise_error(DockerCookbook::Exceptions::InvalidPlatformVersion)
      end
    end

    context 'installing as binary on kernel < 3.8' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'redhat', version: '6.5') do |node|
          node.set['docker']['install_type'] = 'binary'
          node.automatic['kernel']['release'] = '2.6.32-431'
        end.converge(described_recipe)
      end

      it 'should fail' do
        expect { chef_run }.to raise_error(DockerCookbook::Exceptions::InvalidKernelVersion)
      end

    end

    context 'with kernel version < 2.6.32' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'redhat', version: '6.5') do |node|
          node.automatic['kernel']['release'] = '2.6.18-308.1.1.el5'
        end.converge(described_recipe)
      end

      it 'should fail' do
        expect { chef_run }.to raise_error(DockerCookbook::Exceptions::InvalidKernelVersion)
      end
    end
  end

  context 'when running on suse' do
    context 'on 32bit arch' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'opensuse', version: '12.3') do |node|
          node.automatic['kernel']['machine'] = 'i386'
        end.converge(described_recipe)
      end

      it 'should fail' do
        expect { chef_run }.to raise_error(DockerCookbook::Exceptions::InvalidArchitecture)
      end
    end
  end
end
