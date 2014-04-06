require 'spec_helper'

describe 'docker::lxc' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end
end
