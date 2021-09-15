# Debian 9 does not include 20.10
if os.name == 'debian' && os.release.to_i == 9
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/19\.03\./) }
  end
else
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/20\.10\./) }
  end
end
