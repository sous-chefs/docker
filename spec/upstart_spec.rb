require 'spec_helper'

describe 'docker::upstart' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end
end
