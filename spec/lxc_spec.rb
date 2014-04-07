require 'spec_helper'

describe 'docker::lxc' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'includes the lxc recipe' do
    expect(chef_run).to include_recipe('lxc')
  end
end
