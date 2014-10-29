require 'spec_helper'

describe 'docker::devicemapper' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'includes the device-mapper recipe' do
    expect(chef_run).to include_recipe('device-mapper')
  end
end
