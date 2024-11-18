describe command('/usr/bin/docker --version') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/2[0-9]\.[0-9]+\./) }
end
