if os.name == 'debian'
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/27\.0\./) }
  end
elsif os.name == 'amazon' && %w(2 2023).include?(os.release)
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/20\.10\./) }
  end
elsif os.family == 'redhat' && os.release.to_i == 8
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/26\.1\./) }
  end
else
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/27\.0\./) }
  end
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
