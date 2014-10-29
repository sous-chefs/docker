require 'spec_helper'
require_relative 'support/matchers'

describe 'docker::source' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  before(:each) do
    stub_command('/usr/local/go/bin/go version | grep "go1.2 "').and_return('1.2')
  end

  it 'creates the docker source directory' do
    expect(chef_run).to create_directory('/opt/go/src/github.com/dotcloud').with(
      owner: 'root',
      group: 'root',
      mode: 00755,
      recursive: true
    )
  end

  it 'checks out the docker source' do
    expect(chef_run).to checkout_git('/opt/go/src/github.com/dotcloud/docker').with(
      repository: 'https://github.com/dotcloud/docker.git',
      reference: 'master'
    )
  end

  it 'installs the docker golang package' do
    expect(chef_run).to install_golang_package('github.com/dotcloud/docker')
  end
end
