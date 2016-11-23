
describe command('/usr/bin/docker --version') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/1.12.3/) }
end
