require 'spec_helper'

describe 'docker::cgroups' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end
end
