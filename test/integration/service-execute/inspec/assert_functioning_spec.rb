
describe processes('docker') do
  its('users') { should eq ['root'] }
  its('states') { should include 'Sl' }
end

describe command('docker ps') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^CONTAINER/) }
end

# Test for /var/log/docker.log for all non-systemd platforms
systemd = true
systemd = false if os[:family] == 'redhat' && os[:release].nil? # amazon?
systemd = false if os[:family] == 'redhat' && os[:release].to_i < 7
systemd = false if os[:family] == 'ubuntu' && os[:release].to_f < 15.04

unless systemd
  describe file('/var/log/docker.log') do
    it { should be_file }
    it { should be_mode 644 }
  end
end

describe kernel_parameter('net.ipv4.ip_forward') do
  its(:value) { should eq 1 }
end

describe kernel_parameter('net.ipv6.conf.all.forwarding') do
  its(:value) { should eq 1 }
end
