require 'spec_helper'

describe 'docker::group' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end
end
