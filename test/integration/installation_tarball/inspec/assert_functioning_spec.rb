describe command '/usr/bin/docker --version' do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/19.03.13/) }
end

describe group 'docker' do
  it { should exist }
  its('gid') { should < 1000 }
end
