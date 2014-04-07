require 'spec_helper'

describe 'docker::cgroups' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'installs the cgroup-bin package' do
    expect(chef_run).to install_package('cgroup-bin')
  end

  it 'starts the cgconfig service' do
    expect(chef_run).to start_service('cgconfig')
  end

  it 'starts the cgred service' do
    expect(chef_run).to start_service('cgred')
  end
end
