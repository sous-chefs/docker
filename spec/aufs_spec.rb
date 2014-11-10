require 'spec_helper'
require_relative 'support/matchers'

describe 'docker::aufs' do
  before(:each) do
    # TODO: Add to aufs cookbook
    shellout = double
    apt_cache = double('apt-cache')
    uname = double

    allow(Mixlib::ShellOut).to receive(:new).and_return(shellout)
    allow(shellout).to receive(:run_command).and_return(apt_cache)
    allow(apt_cache).to receive(:stdout).and_return('linux-image-extra-3.')
    allow(shellout).to receive(:run_command).and_return(uname)
    allow(uname).to receive(:stdout).and_return('3.')

    stub_command('modprobe -n -v aufs').and_return('')
  end

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'includes the aufs recipe' do
    expect(chef_run).to include_recipe('aufs')
  end
end
