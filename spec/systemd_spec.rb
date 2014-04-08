require 'spec_helper'

describe 'docker::systemd' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end
end
