require 'spec_helper'

describe 'docker::binary' do
  context 'by default' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.automatic['kernel']['release'] = '3.8.0'
      end.converge(described_recipe)
    end

    it 'downloads docker binary' do
      expect(chef_run).to create_remote_file_if_missing('/usr/bin/docker')
    end
  end

  context 'when install_dir is set' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.normal['docker']['install_dir'] = '/tmp'
        node.automatic['kernel']['release'] = '3.8.0'
      end.converge(described_recipe)
    end

    it 'downloads docker binary to install_dir' do
      expect(chef_run).to create_remote_file_if_missing('/tmp/docker')
    end
  end

  context 'when install_type is binary' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.normal['docker']['install_type'] = 'binary'
        node.automatic['kernel']['release'] = '3.8.0'
      end.converge(described_recipe)
    end

    it 'downloads docker binary to install_dir' do
      expect(chef_run).to create_remote_file_if_missing('/usr/local/bin/docker')
    end
  end
end
