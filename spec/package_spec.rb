require 'spec_helper'

shared_examples_for 'a yum-based system' do
  it 'should include the yum-epel recipe' do
    expect(chef_run).to include_recipe('yum-epel')
  end

  it 'should install the docker-io package' do
    expect(chef_run).to install_package('docker-io')
  end
end

shared_examples_for 'an apt-based system' do
  it 'should setup docker apt-repo' do
    expect(chef_run).to add_apt_repository('docker').with(
      uri: 'https://get.docker.io/ubuntu',
      distribution: 'docker',
      components: ['main'],
      keyserver: 'keyserver.ubuntu.com',
      key: 'A88D21E9'
    )
  end

  it 'installs the lxc-docker package' do
    expect(chef_run).to install_package('lxc-docker').with(
      options: '--force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    )
    expect(chef_run2).to install_package('lxc-docker-0.9.1').with(
      options: '--force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    )
  end
end

describe 'docker::package' do
  context 'when running on centos' do
    it_behaves_like 'a yum-based system' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'centos', version: '6.5').converge(described_recipe)
      end
    end
  end

  context 'when running on redhat' do
    it_behaves_like 'a yum-based system' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'redhat', version: '6.5').converge(described_recipe)
      end
    end
  end

  context 'when running on debian' do
    it_behaves_like 'an apt-based system' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'debian', version: '7.4').converge(described_recipe)
      end
      let(:chef_run2) do
        runner = ChefSpec::Runner.new(platform: 'debian', version: '7.4')
        runner.node.set['docker']['version'] = '0.9.1'
        runner.converge(described_recipe)
      end
    end
  end

  context 'when running on ubuntu' do
    it_behaves_like 'an apt-based system' do
      let(:chef_run) do
        ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04').converge(described_recipe)
      end
      let(:chef_run2) do
        runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
        runner.node.set['docker']['version'] = '0.9.1'
        runner.converge(described_recipe)
      end
    end
  end

  context 'when running on fedora' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'fedora', version: '19').converge(described_recipe)
    end

    it 'should install the docker-io package' do
      expect(chef_run).to install_package('docker-io')
    end
  end

  context 'when running on mac_os_x' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'mac_os_x', version: '10.9.2').converge(described_recipe)
    end

    it 'should tap the homebrew/binary cask' do
      expect(chef_run).to tap_homebrew_tap('homebrew/binary')
    end

    it 'should install the docker binary' do
      expect(chef_run).to install_package('homebrew/binary/docker')
    end
  end
end
