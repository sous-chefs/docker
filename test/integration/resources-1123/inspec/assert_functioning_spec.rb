#
docker_version_string = command('docker -v').stdout
docker_version = docker_version_string.split(/\s/)[2].split(',')[0]

puts "docker_version: #{docker_version}"

case docker_version
when '1.6', '1.7'
  volumes_filter = '{{ .Volumes }}'
  mounts_filter = '{{ .Volumes }}'
else
  volumes_filter = '{{ .Config.Volumes }}'
  mounts_filter = '{{ .Mounts }}'
end

# overrides_volumes_value

overrides_volumes_value = docker_version == '1.6' ? %r{map\[\/home:map\[\]\]} : %r{map\[/home:{}\]}
uber_options_network_mode = docker_version == '1.7' ? 'bridge' : 'default'

nil_string = '<no value>' if docker_version =~ /1.6/
nil_string = '<nil>' if docker_version =~ /1.7/
nil_string = '<nil>' if docker_version =~ /1.8/

##################################################
#  test/cookbooks/docker_test/recipes/default.rb
##################################################

# docker_service[default]

unless docker_version =~ /1.6/
  describe command('docker info') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/environment=/) }
    its(:stdout) { should match(/foo=/) }
  end
end

##############################################
#  test/cookbooks/docker_test/recipes/image.rb
##############################################

# test/cookbooks/docker_test/recipes/image.rb

# docker_image[hello-world]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^hello-world\s.*latest/) }
end

# docker_image[Tom's container]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{^tduffield\/testcontainerd\s.*latest}) }
end

# docker_image[busybox]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^busybox\s.*latest/) }
end

# docker_image[alpine]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^alpine\s.*3.1/) }
end

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^alpine\s.*2.7/) }
end

# docker_image[vbatts/slackware]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/^slackware\s.*latest/) }
end

# docker_image[save cirros]

describe file('/cirros.tar') do
  it { should be_file }
  it { should be_mode 0644 }
end

# docker_image[load cirros]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^cirros\s.*latest/) }
end

# docker_image[image-1]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/^image-1\s.*v1.0.1/) }
end

# docker_image[image.2]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/^image.2\s.*v1.0.1/) }
end

# docker_image[image_3]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/^image_3\s.*v1.0.1/) }
end

# docker_image[name-w-dashes]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{^localhost\:5043/someara/name-w-dashes\s.*latest}) }
end

# docker_tag[private repo tag for name.w.dots:latest]

describe command('docker images') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{^localhost\:5043/someara/name\.w\.dots\s.*latest}) }
end

# FIXME: We need to test the "docker_registry" stuff...
# I can't figure out how to search the local registry to see if the
# authentication and :push actions in the test recipe actually worked.
#
# Skipping for now.

##################################################
#  test/cookbooks/docker_test/recipes/container.rb
##################################################

# docker_container[hello-world]

describe command("docker ps -qaf 'name=hello-world$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

# docker_container[busybox_ls]

describe command("docker ps -qaf 'name=busybox_ls$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

# docker_container[alpine_ls]

describe command("docker ps -qaf 'name=alpine_ls$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

# docker_container[an_echo_server]

describe command("docker ps -qaf 'name=an_echo_server$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker inspect --format '{{ range $port, $_ := .HostConfig.PortBindings }}{{ $port }}{{ end }}' an_echo_server") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include('7/tcp') }
end

# docker_container[another_echo_server]

describe command("docker ps -qaf 'name=another_echo_server$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker inspect --format '{{ range $port, $_ := .HostConfig.PortBindings }}{{ $port }}{{ end }}' another_echo_server") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include('7/tcp') }
end

# docker_container[an_udp_echo_server]

describe command("docker ps -qaf 'name=an_udp_echo_server$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker inspect --format '{{ range $port, $_ := .HostConfig.PortBindings }}{{ $port }}{{ end }}' an_udp_echo_server") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include('7/udp') }
end

# docker_container[multi_ip_port]

describe command("docker ps -qaf 'name=multi_ip_port$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker inspect -f '{{ .HostConfig.PortBindings }}' multi_ip_port") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include('8301/tcp:[{ }]') }
  its(:stdout) { should include('8301/udp:[{0.0.0.0 8301}]') }
  its(:stdout) { should match(%r(8500/tcp:\[{127.0.[0-1].1 8500} {127.0.[0-1].1 8500}\])) }
end

# docker_container[port_range]

describe command("docker ps -qaf 'name=port_range$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker inspect -f '{{ .HostConfig.PortBindings }}' port_range") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include('2000/tcp:[{ }]') }
  its(:stdout) { should include('2001/tcp:[{ }]') }
  its(:stdout) { should include('2000/udp:[{ }]') }
  its(:stdout) { should include('2001/udp:[{ }]') }
  its(:stdout) { should include('3000/tcp:[{ }]') }
  its(:stdout) { should include('3001/tcp:[{ }]') }
end

# docker_container[bill]

describe command("docker ps -qaf 'name=bil$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should be_empty }
end

# docker_container[hammer_time]

describe command("docker ps -qaf 'name=hammer_time$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker ps -af 'name=hammer_time$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
  its(:stdout) { should_not be_empty }
end

# docker_container[red_light]

describe command("docker ps -qaf 'name=red_light$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker ps -af 'name=red_light$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Paused/) }
end

# docker_container[green_light]

describe command("docker ps -qaf 'name=green_light$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker ps -af 'name=green_light$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Paused/) }
end

# docker_container[quitter]

describe command("docker ps -qaf 'name=quitter$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker ps -af 'name=quitter$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container[restarter]

describe command("docker ps -qaf 'name=restarter$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

describe command("docker ps -af 'name=restarter$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container[deleteme]

describe command("docker ps -qaf 'name=deleteme$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should be_empty }
end

# docker_container[redeployer]

describe command("docker ps -af 'name=redeployer$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container[unstarted_redeployer]

describe command("docker ps -af 'name=unstarted_redeployer$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Up/) }
  its(:stdout) { should match(/Created/) } if docker_version.to_f >= 1.8
end

# docker_container[bind_mounter]

describe command("docker ps -af 'name=bind_mounter$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker inspect -f "{{ .HostConfig.Binds }}" bind_mounter') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\/hostbits\:\/bits}) }
  its(:stdout) { should match(%r{\/more-hostbits\:\/more-bits}) }
  its(:stdout) { should match(%r{\/winter\:\/spring\:ro}) }
end

# docker_container[binds_alias]

describe command("docker ps -af 'name=binds_alias$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker inspect -f "{{ .HostConfig.Binds }}" binds_alias') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\/fall\:\/sun}) }
  its(:stdout) { should match(%r{\/winter\:\/spring\:ro}) }
end

describe command('docker inspect -f "{{ .Config.Volumes }}" binds_alias') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\/snow\:\{\}}) }
  its(:stdout) { should match(%r{\/summer\:\{\}}) }
end

# docker_container[chef_container]

describe command("docker ps -af 'name=chef_container$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
  its(:stdout) { should_not match(/Up/) }
end

describe command("docker inspect -f \"#{volumes_filter}\" chef_container") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\/opt\/chef\:}) }
end

# docker_container[ohai_debian]
describe command("docker ps -af 'name=ohai_debian$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs ohai_debian') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/debian/) }
end

describe command("docker inspect -f \"#{mounts_filter}\" ohai_debian") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\/opt\/chef}) }
end

# docker_container[env]

describe command("docker ps -af 'name=env$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker inspect -f "{{ .Config.Env }}" env') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{\[PATH=\/usr\/bin FOO=bar\]}) }
end

# docker_container[ohai_again]
describe command("docker ps -af 'name=ohai_again$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs ohai_again') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/ohai_time/) }
end

# docker_container[cmd_test]

describe command("docker ps -af 'name=cmd_test$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs cmd_test') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/.dockerenv/) }
end

# docker_container[sean_was_here]
describe command("docker ps -aqf 'name=sean_was_here$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should be_empty }
end

describe command('docker run --rm --volumes-from chef_container debian ls -la /opt/chef/') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/sean_was_here-/) }
end

# docker_container[cap_add_net_admin]

describe command("docker ps -af 'name=cap_add_net_admin$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs cap_add_net_admin') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should_not match(/RTNETLINK answers: Operation not permitted/) }
end

# docker_container[cap_add_net_admin_error]

describe command("docker ps -af 'name=cap_add_net_admin_error$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs cap_add_net_admin_error') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match(/RTNETLINK answers: Operation not permitted/) }
end

# docker_container[cap_drop_mknod]

describe command("docker ps -af 'name=cap_drop_mknod$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs cap_drop_mknod') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match(%r{mknod: '/dev/urandom2': Operation not permitted}) }
end

# docker_container[cap_drop_mknod_error]

describe command("docker ps -af 'name=cap_drop_mknod_error$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs cap_drop_mknod_error') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should_not match(%r{mknod: '/dev/urandom2': Operation not permitted}) }
end

# docker_container[fqdn]

describe command("docker ps -af 'name=fqdn$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs fqdn') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/computers.biz/) }
end

# docker_container[dns]

describe command("docker ps -af 'name=dns$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker inspect -f "{{ .HostConfig.Dns }}" dns') do
  its(:stdout) { should match(/\[4.3.2.1 1.2.3.4\]/) }
end

# docker_container[extra_hosts]

describe command("docker ps -af 'name=extra_hosts$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker inspect -f "{{ .HostConfig.ExtraHosts }}" extra_hosts') do
  its(:stdout) { should match(/\[east:4.3.2.1 west:1.2.3.4\]/) }
end

# docker_container[devices_sans_cap_sys_admin]

# describe command("docker ps -af 'name=devices_sans_cap_sys_admin$'") do
#   its(:exit_status) { should eq 0 }
#   its(:stdout) { should match(/Exited/) }
# end

# FIXME: find a method to test this that works across all platforms in test-kitchen
# Is this test invalid?
# describe command("md5sum /root/disk1") do
#   its(:exit_status) { should eq 0 }
#   its(:stdout) { should match(/0f343b0931126a20f133d67c2b018a3b/) }
# end

# docker_container[devices_with_cap_sys_admin]

# describe command("docker ps -af 'name=devices_with_cap_sys_admin$'") do
#   its(:exit_status) { should eq 0 }
#   its(:stdout) { should match(/Exited/) }
# end

# describe command('md5sum /root/disk1') do
#   its(:exit_status) { should eq 0 }
#   its(:stdout) { should_not match(/0f343b0931126a20f133d67c2b018a3b/) }
# end

# docker_container[cpu_shares]

describe command("docker ps -af 'name=cpu_shares$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command("docker inspect -f '{{ .HostConfig.CpuShares }}' cpu_shares") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/512/) }
end

# docker_container[cpuset_cpus]

describe command("docker ps -af 'name=cpuset_cpus$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command("docker inspect -f '{{ .HostConfig.CpusetCpus }}' cpuset_cpus") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/0,1/) }
end

# docker_container[try_try_again]

# FIXME: Find better tests
describe command("docker ps -af 'name=try_try_again$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

# docker_container[reboot_survivor]

describe command("docker ps -af 'name=reboot_survivor$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container[reboot_survivor_retry]

describe command("docker ps -af 'name=reboot_survivor_retry$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container[link_source]

describe command("docker ps -af 'name=link_source$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container[link_source_2]

describe command("docker ps -af 'name=link_source_2$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

# docker_container[link_target_1]

describe command("docker ps -af 'name=link_target_1$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs link_target_1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/ping: bad address 'hello'/) }
end

# docker_container[link_target_2]

describe command("docker ps -af 'name=link_target_2$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs link_target_2') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{HELLO_NAME=/link_target_2/hello}) }
end

# docker_container[link_target_3]

describe command("docker ps -af 'name=link_target_3$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs link_target_3') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/ping: bad address 'hello_again'/) }
end

describe command("docker inspect -f '{{ .HostConfig.Links }}' link_target_3") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{[/link_source:/link_target_3/hello /link_source_2:/link_target_3/hello_again]}) }
end

# docker_container[link_target_4]

describe command("docker ps -af 'name=link_target_4$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited/) }
end

describe command('docker logs link_target_4') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{HELLO_NAME=/link_target_4/hello}) }
  its(:stdout) { should match(%r{HELLO_AGAIN_NAME=/link_target_4/hello_again}) }
end

describe command("docker inspect -f '{{ .HostConfig.Links }}' link_target_4") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{[/link_source:/link_target_4/hello /link_source_2:/link_target_4/hello_again]}) }
end

# docker_container[dangler]

# describe command('ls -la `cat /dangler_volpath`') do
#   its(:exit_status) { should_not eq 0 }
# end

# FIXME: this changed with 1.8.x. Find a way to sanely test across various platforms
# docker_container[mutator]

describe command('ls -la /mutator.tar') do
  its(:exit_status) { should eq 0 }
end

# docker_container[network_mode]

describe command("docker ps -af 'name=network_mode$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

describe command("docker inspect -f '{{ .HostConfig.NetworkMode }}' network_mode") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/host/) }
end

if docker_version.to_f > 1.6
  # docker_container[ulimit]
  describe command("docker ps -af 'name=ulimit$'") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should_not match(/Exited/) }
  end

  describe command("docker inspect -f '{{ .HostConfig.Ulimits }}' ulimits") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/nofile=40960:40960 core=100000000:100000000 memlock=100000000:100000000/) }
  end
end

if docker_version.to_f > 1.6
  # docker_container[uber_options]
  describe command("docker ps -af 'name=uber_options$'") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should_not match(/Exited/) }
  end

  describe command("docker inspect -f '{{ .Config.Domainname }}' uber_options") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/computers.biz/) }
  end

  describe command("docker inspect -f '{{ .Config.MacAddress }}' uber_options") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/00:00:DE:AD:BE:EF/) }
  end

  describe command("docker inspect -f '{{ .HostConfig.Ulimits }}' uber_options") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/nofile=40960:40960 core=100000000:100000000 memlock=100000000:100000000/) }
  end

  describe command("docker inspect -f '{{ .HostConfig.NetworkMode }}' uber_options") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/#{uber_options_network_mode}/) }
  end

  # docker inspect returns the labels unsorted
  describe command("docker inspect -f '{{ .Config.Labels }}' uber_options") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/foo:bar/) }
    its(:stdout) { should match(/hello:world/) }
  end
end

# docker_container[overrides-1]

describe command("docker ps -af 'name=overrides-1$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

describe command('docker inspect -f "{{ .Config.User }}" overrides-1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/bob/) }
end

describe command('docker inspect -f "{{ .Config.Env }}" overrides-1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{[PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin FOO=foo BAR=bar BIZ=biz BAZ=baz]}) }
end

describe command('docker inspect -f "{{ .Config.Entrypoint }}" overrides-1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/#{nil_string}/) }
end

describe command('docker inspect -f "{{ .Config.Cmd }}" overrides-1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{[ls -la /]}) }
end

describe command('docker inspect -f "{{ .Config.WorkingDir }}" overrides-1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{/var}) }
end

describe command('docker inspect -f "{{ .Config.Volumes }}" overrides-1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(overrides_volumes_value) }
end

# docker_container[overrides-2]

describe command("docker ps -af 'name=overrides-2$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

describe command('docker inspect -f "{{ .Config.User }}" overrides-2') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/operator/) }
end

describe command('docker inspect -f "{{ .Config.Env }}" overrides-2') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{[FOO=biz PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin BAR=bar BIZ=biz BAZ=baz]}) }
end

describe command('docker inspect -f "{{ .Config.Entrypoint }}" overrides-2') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{[/bin/sh -c]}) }
end

describe command('docker inspect -f "{{ .Config.Cmd }}" overrides-2') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{[ls -laR /]}) }
end

describe command('docker inspect -f "{{ .Config.WorkingDir }}" overrides-2') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{/tmp}) }
end

# docker_container[syslogger]

describe command("docker ps -af 'name=syslogger$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not match(/Exited/) }
end

describe command("docker inspect -f '{{ .HostConfig.LogConfig.Type }}' syslogger") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/syslog/) }
end

describe command("docker inspect -f '{{ .HostConfig.LogConfig.Config }}' syslogger") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/tag:container-syslogger/) }
end

# docker_container[host_override]

describe command("docker ps -af 'name=host_override$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should_not be_empty }
end

# docker_container[kill_after]

describe command("docker ps -af 'name=kill_after$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited \(137\)/) }
end

kill_after_start = command("docker inspect -f '{{.State.StartedAt}}' kill_after").stdout
kill_after_start = DateTime.parse(kill_after_start).to_time.to_i

kill_after_finish = command("docker inspect -f '{{.State.FinishedAt}}' kill_after").stdout
kill_after_finish = DateTime.parse(kill_after_finish).to_time.to_i

kill_after_run_time = kill_after_finish - kill_after_start

describe kill_after_run_time do
  it { should be_within(5).of(1) }
end

# docker_container[pid_mode]

describe command("docker ps -af 'name=pid_mode$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited \(0\)/) }
end

describe command("docker inspect --format '{{ .HostConfig.PidMode }}' pid_mode") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { eq 'host' }
end

# docker_container[ipc_mode]

describe command("docker ps -af 'name=ipc_mode$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited \(0\)/) }
end

describe command("docker inspect --format '{{ .HostConfig.IpcMode }}' ipc_mode") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { eq 'host' }
end

# docker_container[uts_mode]

describe command("docker ps -af 'name=uts_mode$'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Exited \(0\)/) }
end

describe command("docker inspect --format '{{ .HostConfig.UTSMode }}' uts_mode") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { eq 'host' }
end

# containers shouldnt be killed, validating only one was force killed
describe command("docker ps -qaf 'exited=137' | wc -l") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/1/) }
end

describe command("docker ps -af 'exited=137'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/kill_after/) }
end

describe command("docker inspect --format '{{ .HostConfig.ReadonlyRootfs }}' ro_rootfs") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { eq 'true' }
end

# sysctls
describe command("docker inspect --format '{{ .HostConfig.Sysctls }}' sysctls") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/net.core.somaxconn:65535/) }
  its(:stdout) { should match(/net.core.xfrm_acq_expires:42/) }
end
