###########
# network_a
###########

describe command("docker network ls -qf 'name=network_a$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command('docker network inspect -f "{{ .Driver }}" network_a') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "bridge\n" }
end

describe command('docker network inspect -f "{{ .Containers }}" network_a') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match "echo-station-network_a" }
end

describe command('docker network inspect -f "{{ .Containers }}" network_a') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match "echo-base-network_a" }
end

###########
# network_b
###########

describe command("docker network ls -qf 'name=network_b$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command('docker network inspect -f "{{ .Driver }}" network_b') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "bridge\n" }
end

describe command('docker network inspect -f "{{ .IPAM.Config }}" network_b') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match "192.168.88.0/24" }
  its(:stdout) { should match "192.168.88.1" }
end

describe command('docker network inspect -f "{{ .Containers }}" network_b') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match "echo-station-network_b" }
end

describe command('docker network inspect -f "{{ .Containers }}" network_b') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match "echo-base-network_b" }
end

###########
# network_c
###########

describe command("docker network ls -qf 'name=network_c$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command('docker network inspect -f "{{ .Driver }}" network_c') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "bridge\n" }
end

describe command('docker network inspect -f "{{ .IPAM.Config }}" network_c') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match "a:192.168.89.2" }
  its(:stdout) { should match "b:192.168.89.3" }
end

###########
# network_d
###########

describe command("docker network ls -qf 'name=network_d$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command('docker network inspect -f "{{ .Driver }}" network_d') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "overlay\n" }
end
