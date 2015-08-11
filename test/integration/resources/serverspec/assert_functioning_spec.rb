require 'serverspec'

set :backend, :exec
puts "os: #{os}"

##############################################
#  test/cookbooks/docker_test/recipes/image.rb
##############################################

# test/cookbooks/docker_test/recipes/image.rb

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^hello-world\s.*latest/) }
end

# docker_image "Tom's container" do
#  repo 'tduffield/testcontainerd'
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{^tduffield\/testcontainerd\s.*latest}) }
end

# docker_image 'busybox' do
#   action :pull
#   not_if { ::File.exist? '/marker_image_busybox' }
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^busybox\s.*latest/) }
end

# docker_image 'alpine' do
#   tag '3.1'
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^alpine\s.*3.1/) }
end

# docker_image 'vbatts/slackware' do
#   action :remove
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/^slackware\s.*latest/) }
end

# docker_image 'save hello-world' do
#   repo 'hello-world'
#   destination '/hello-world.tar'
#   not_if { ::File.exist? '/hello-world.tar' }
#   action :save
# end

describe file('/hello-world.tar') do
  it { should be_file }
  it { should be_mode 644 }
end

# docker_image 'image_1' do
#   tag 'v0.1.0'
#   source '/usr/local/src/container1/Dockerfile'
#   force true
#   not_if { ::File.exist? '/marker_image_image_1' }
#   action :build
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/^image_1\s.*v1.0.1/) }
end

# docker_image 'image_2' do
#   tag 'v0.1.0'
#   source '/usr/local/src/container2'
#   action :build_if_missing
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/^image_2\s.*v1.0.1/) }
end

# docker_image 'image_3' do
#   tag 'v0.1.0'
#   source '/usr/local/src/image_3.tar'
#   action :build_if_missing
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/^image_3\s.*v1.0.1/) }
end

# docker_image 'hello-again' do
#   tag 'v0.1.0'
#   source '/hello-world.tar'
#   action :import
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^hello-again\s.*v0.1.0/) }
end

# docker_tag 'private repo tag for hello-again:1.0.1' do
#   target_repo 'hello-again'
#   target_tag 'v0.1.0'
#   to_repo 'localhost:5043/someara/hello-again'
#   to_tag 'latest'
#   action :tag
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{^localhost\:5043\/someara\/hello-again\s.*latest}) }
end

# docker_tag 'private repo tag for busybox:latest' do
#   target_repo 'busybox'
#   target_tag 'latest'
#   to_repo 'localhost:5043/someara/busybox'
#   to_tag 'latest'
#   action :tag
# end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{^localhost\:5043\/someara\/busybox\s.*latest}) }
end

# FIXME: We need to test the "docker_registry" stuff...
# I can't figure out how to search the local registry to see if the
# authentication and :push actions in the test recipe actually worked.
#
# Skipping for now.

##################################################
#  test/cookbooks/docker_test/recipes/container.rb
##################################################

# docker_container 'hello-world' do
#   command '/hello'
#   action :create
# end

describe command("docker ps -af 'name=hello-world'") do
  its(:exit_status) { should eq 0 }
end

# docker_container 'busybox_ls' do
#   repo 'busybox'
#   command 'ls -la /'
#   not_if "[ ! -z `docker ps -qaf 'name=busybox_ls$'` ]"
#   action :run
# end

describe command("[ ! -z `docker ps -qaf 'name=busybox_ls$'` ]") do
  its(:exit_status) { should eq 0 }
end

# docker_container 'alpine_ls' do
#   repo 'alpine'
#   tag '3.1'
#   command 'ls -la /'
#   action :run_if_missing
# end

describe command("[ ! -z `docker ps -qaf 'name=alpine_ls$'` ]") do
  its(:exit_status) { should eq 0 }
end

# docker_container 'an_echo_server' do
#   repo 'alpine'
#   tag '3.1'
#   command 'nc -ll -p 7 -e /bin/cat'
#   port '7:7'
#   action :run
# end

describe command("[ ! -z `docker ps -qaf 'name=an_echo_server$'` ]") do
  its(:exit_status) { should eq 0 }
end

# docker_container 'another_echo_server' do
#   repo 'alpine'
#   tag '3.1'
#   command 'nc -ll -p 7 -e /bin/cat'
#   port '7'
#   action :run
# end

describe command("[ ! -z `docker ps -qaf 'name=another_echo_server$'` ]") do
  its(:exit_status) { should eq 0 }
end

# docker_container 'an_udp_echo_server' do
#   repo 'alpine'
#   tag '3.1'
#   command 'nc -ul -p 7 -e /bin/cat'
#   port '5007:7/udp'
#   action :run
# end

describe command("[ ! -z `docker ps -qaf 'name=an_udp_echo_server$'` ]") do
  its(:exit_status) { should eq 0 }
end

# docker_container 'bill' do
#   action :kill
# end

describe command("[ ! -z `docker ps -qaf 'name=bil$'` ]") do
  its(:exit_status) { should eq 1 }
end

# docker_container 'hammer_time' do
#   action :stop
# end

describe command("[ ! -z `docker ps -qaf 'name=hammer_time$'` ]") do
  its(:exit_status) { should eq 0 }
end

describe command("docker ps -af 'name=hammer_time$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited \(137\)/) }
end

# docker_container 'red_light' do
#   action :pause
# end

describe command("[ ! -z `docker ps -qaf 'name=red_light$'` ]") do
  its(:exit_status) { should eq 0 }
end

describe command("docker ps -af 'name=red_light$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Paused/) }
end

# docker_container 'green_light' do
#   action :unpause
# end

describe command("[ ! -z `docker ps -qaf 'name=green_light$'` ]") do
  its(:exit_status) { should eq 0 }
end

describe command("docker ps -af 'name=green_light$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Paused/) }
end

# docker_container 'quitter' do
#   not_if { ::File.exist? '/marker_container_quitter_restarter' }
#   action :restart
# end

describe command("[ ! -z `docker ps -qaf 'name=quitter$'` ]") do
  its(:exit_status) { should eq 0 }
end

describe command("docker ps -af 'name=quitter$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container 'restarter' do
#   not_if { ::File.exist? '/marker_container_restarter_restarter' }
#   action :restart
# end

describe command("[ ! -z `docker ps -qaf 'name=restarter$'` ]") do
  its(:exit_status) { should eq 0 }
end

describe command("docker ps -af 'name=restarter$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container 'deleteme' do
#   action :delete
# end

describe command("[ ! -z `docker ps -qaf 'name=deleteme$'` ]") do
  its(:exit_status) { should eq 1 }
end

# docker_container 'redeployer' do
#   repo 'alpine'
#   tag '3.1'
#   command 'nc -ll -p 7777 -e /bin/cat'
#   port '7'
#   action :run
# end

describe command("docker ps -af 'name=redeployer$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container 'bind_mounter' do
#   repo 'busybox'
#   command 'ls -la /bits /more-bits'
#   binds ['/hostbits:/bits', '/more-hostbits:/more-bits']
#   action :run_if_missing
# end

describe command("docker ps -af 'name=bind_mounter$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command("docker inspect -f \"{{ .HostConfig.Binds }}\" bind_mounter") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\[\/hostbits\:\/bits \/more-hostbits\:\/more-bits\]}) }
end

# docker_container 'chef_container' do
#   command 'true'
#   volumes '/opt/chef'
#   action :create
# end

describe command("docker ps -af 'name=chef_container$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
  its(:stdout) { should_not match(/Up/) }
end

describe command("docker inspect -f \"{{ .Volumes }}\" chef_container") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\/opt\/chef\:\/var\/lib\/docker\/vfs\/dir}) }
end

# docker_container 'ohai_debian' do
#   command '/opt/chef/embedded/bin/ohai platform'
#   repo 'debian'
#   volumes_from 'chef_container'
# end

describe command("docker ps -af 'name=ohai_debian$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command("docker inspect -f \"{{ .Volumes }}\" ohai_debian") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\/opt\/chef\:\/var\/lib\/docker\/vfs\/dir}) }
end

# docker_container 'env' do
#   repo 'debian'
#   env ['PATH=/usr/bin', 'FOO=bar']
#   command 'env'
#   action :run_if_missing
# end

describe command("docker ps -af 'name=env$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command("docker inspect -f \"{{ .Config.Env }}\" env") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\[PATH=\/usr\/bin FOO=bar\]}) }
end

# docker_container 'ohai_again_debian' do
#   repo 'debian'
#   volumes_from 'chef_container'
#   entrypoint '/opt/chef/embedded/bin/ohai'
#   command 'platform'
#   action :run_if_missing
# end

describe command("docker ps -af 'name=ohai_again_debian$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command("docker inspect -f \"{{ .Config.Entrypoint }}\" ohai_again_debian") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\/opt\/chef\/embedded\/bin\/ohai}) }
end

# docker_container 'sean_was_here' do
#   command "touch /opt/chef/sean_was_here-#{Time.new.strftime('%Y%m%d%H%M')}"
#   repo 'debian'
#   volumes_from 'chef_container'
#   autoremove true
#   not_if { ::File.exist? '/marker_container_sean_was_here' }
#   action :run
# end

describe command("[ ! -z `docker ps -aqf 'name=sean_was_here$'` ]") do
  its(:exit_status) { should eq 1 }
end

describe command('docker run --rm --volumes-from chef_container debian ls -la /opt/chef/') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/sean_was_here-/) }
end

# docker_container 'cap_add_net_admin' do
#   repo 'debian'
#   command 'bash -c "ip addr add 10.9.8.7/24 brd + dev eth0 label eth0:0 ; ip addr list"'
#   cap_add 'NET_ADMIN'
#   action :run_if_missing
# end

describe command("docker ps -af 'name=cap_add_net_admin$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs cap_add_net_admin') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should_not match(/RTNETLINK answers: Operation not permitted/) }
end

# docker_container 'cap_drop_mknod' do
#   repo 'debian'
#   command 'bash -c "mknod -m 444 /dev/urandom2 c 1 9 ; ls -la /dev/urandom2"'
#   cap_drop 'MKNOD'
#   action :run_if_missing
# end

describe command("docker ps -af 'name=cap_drop_mknod$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs cap_drop_mknod') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match(%r{mknod: '/dev/urandom2': Operation not permitted}) }
end

# docker_container 'fqdn' do
#   repo 'debian'
#   command 'hostname -f'
#   host_name 'computers'
#   domain_name 'biz'
#   action :run_if_missing
# end

describe command("docker ps -af 'name=fqdn$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs fqdn') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/computers.biz/) }
end

# docker_container 'dns' do
#   repo 'debian'
#   command 'cat /etc/resolv.conf'
#   host_name 'computers'
#   dns ['4.3.2.1', '1.2.3.4']
#   dns_search ['computers.biz', 'chef.io']
#   action :run_if_missing
# end

describe command("docker ps -af 'name=dns$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command("docker inspect -f \"{{ .HostConfig.Dns }}\" dns") do
  its(:stdout) { should match(/\[4.3.2.1 1.2.3.4\]/) }
end

# docker_container 'extra_hosts' do
#   repo 'debian'
#   command 'cat /etc/hosts'
#   extra_hosts ['east:4.3.2.1', 'west:1.2.3.4']
#   action :run_if_missing
# end

describe command("docker ps -af 'name=extra_hosts$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command("docker inspect -f \"{{ .HostConfig.ExtraHosts }}\" extra_hosts") do
  its(:stdout) { should match(/\[east:4.3.2.1 west:1.2.3.4\]/) }
end

# docker_container 'devices' do
#   repo 'debian'
#   command 'sh -c "lsblk ; dd if=/dev/urandom of=/dev/loop1 bs=1024 count=1"'
#   devices [{
#       'PathOnHost' => '/dev/loop1',
#       'PathInContainer' => '/dev/loop1',
#       'CgroupPermissions' => 'rwm'
#     }]
#   cap_add 'SYS_ADMIN'
#   action :run_if_missing
# end
