require 'spec_helper'
require_relative 'support/matchers'

describe 'docker::source' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'creates the docker source directory' do
    expect(chef_run).to create_directory('/opt/go/src/github.com/dotcloud')
  end

  it 'checks out the docker source' do
    expect(chef_run).to checkout_git('/opt/go/src/github.com/dotcloud/docker')
  end

  it 'installs the docker golang package' do
    expect(chef_run).to install_golang_package('github.com/dotcloud/docker')
  end
end
