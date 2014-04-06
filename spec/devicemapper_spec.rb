require 'spec_helper'

describe 'docker::devicemapper' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end
end
