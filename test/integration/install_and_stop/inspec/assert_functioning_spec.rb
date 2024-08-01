describe command('/usr/bin/docker --version') do
  its(:exit_status) { should eq 0 }
  its('stdout') { should match(/2[0-9].[0-9]/) }
end

# NOTE: See https://github.com/sous-chefs/docker/pull/1194
describe service('docker.service') do
  it { should be_installed }
  it { should_not be_running }
  it { should_not be_enabled }
end

describe service('docker.socket') do
  it { should be_installed }
  it { should_not be_running }
  it { should_not be_enabled }
end
