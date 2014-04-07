require 'spec_helper'

describe 'docker::binary' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'downloads docker binary' do
    expect(chef_run).to create_remote_file_if_missing('/usr/bin/docker')
  end

  context 'when install_dir is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['install_dir'] = '/tmp'
      runner.converge(described_recipe)
    end

    it 'downloads docker binary to install_dir' do
      expect(chef_run).to create_remote_file_if_missing('/tmp/docker')
    end
  end

  context 'when install_type is binary' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['install_type'] = 'binary'
      runner.converge(described_recipe)
    end

    it 'downloads docker binary to install_dir' do
      expect(chef_run).to create_remote_file_if_missing('/usr/local/bin/docker')
    end
  end
end
