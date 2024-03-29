#  service named 'default'
describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/busybox/) }
end

describe command('docker ps -a') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/an_echo_server/) }
end

# service one
describe command('docker --host=unix:///var/run/docker-one.sock images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^hello-world/) }
  its(:stdout) { should_not match(/^alpine/) }
end

describe command('docker --host=unix:///var/run/docker-one.sock ps -a') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/hello-world/) }
  its(:stdout) { should_not match(/an_echo_server/) }
end

if os.family == 'redhat' && os.release.to_i < 8
  # verify if docker-ce install was not changed
  describe command("rpm -V docker-ce | grep '^..5'") do
    its(:exit_status) { should eq 1 }
    its(:stdout) { should eq '' }
  end
end
