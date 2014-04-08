require 'spec_helper'
require_relative 'support/matchers'

describe 'docker::default' do
  before(:each) do
    # TODO: Add to aufs cookbook
    shellout = double
    apt_cache = double('apt-cache')
    uname = double

    Mixlib::ShellOut.stub(:new).and_return(shellout)
    allow(shellout).to receive(:run_command).and_return(apt_cache)
    allow(apt_cache).to receive(:stdout).and_return('linux-image-extra-3.')
    allow(shellout).to receive(:run_command).and_return(uname)
    allow(uname).to receive(:stdout).and_return('3.')

    stub_command('modprobe -n -v aufs').and_return('')

    # TODO: Contribute back to golang cookbook
    stub_command('/usr/local/go/bin/go version | grep "go1.2 "').and_return('1.2')
  end

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'includes the apt recipe' do
    expect(chef_run).to include_recipe('apt')
  end

  it 'installs the apt-transport-https package' do
    expect(chef_run).to install_package('apt-transport-https')
  end

  it 'installs the bsdtar package' do
    expect(chef_run).to install_package('bsdtar')
  end

  context 'when exec_driver is lxc' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['exec_driver'] = 'lxc'
      runner.converge(described_recipe)
    end

    it 'includes the docker::cgroups recipe' do
      expect(chef_run).to include_recipe('docker::cgroups')
    end

    it 'includes the docker::lxc recipe' do
      expect(chef_run).to include_recipe('docker::lxc')
    end
  end

  context 'when install_type is binary' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['install_type'] = 'binary'
      runner.converge(described_recipe)
    end

    it 'includes the docker::binary recipe' do
      expect(chef_run).to include_recipe('docker::binary')
    end
  end

  context 'when install_type is binary and storage_driver is aufs' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['install_type'] = 'binary'
      runner.node.set['docker']['storage_driver'] = 'aufs'
      runner.converge(described_recipe)
    end

    it 'includes the docker::aufs recipe' do
      expect(chef_run).to include_recipe('docker::aufs')
    end
  end

  context 'when install_type is source' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['install_type'] = 'source'
      runner.converge(described_recipe)
    end

    it 'includes the git recipe' do
      expect(chef_run).to include_recipe('git')
    end

    it 'includes the golang recipe' do
      expect(chef_run).to include_recipe('golang')
    end

    it 'includes the docker::source recipe' do
      expect(chef_run).to include_recipe('docker::source')
    end
  end

  it 'includes the docker::package recipe' do
    expect(chef_run).to include_recipe('docker::package')
  end

  context 'when group_members is not empty' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['group_members'] = ['vagrant']
      runner.converge(described_recipe)
    end

    it 'includes the docker::group recipe' do
      expect(chef_run).to include_recipe('docker::group')
    end
  end

  it 'includes the docker::upstart recipe' do
    expect(chef_run).to include_recipe('docker::upstart')
  end

  context 'when init_type is runit' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['init_type'] = 'runit'
      runner.converge(described_recipe)
    end

    it 'includes the docker::runit recipe' do
      expect(chef_run).to include_recipe('docker::runit')
    end
  end

  context 'when init_type is systemd' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['init_type'] = 'systemd'
      runner.converge(described_recipe)
    end

    it 'includes the docker::systemd recipe' do
      expect(chef_run).to include_recipe('docker::systemd')
    end
  end

  context 'when init_type is sysv' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['init_type'] = 'sysv'
      runner.converge(described_recipe)
    end

    it 'includes the docker::sysv recipe' do
      expect(chef_run).to include_recipe('docker::sysv')
    end
  end
end
