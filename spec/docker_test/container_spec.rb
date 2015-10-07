require 'spec_helper'

describe 'docker_test::container' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge('docker_test::container') }

  before do
    stub_command("[ ! -z `docker ps -qaf 'name=busybox_ls$'` ]").and_return(false)
    stub_command("[ ! -z `docker ps -qaf 'name=bill$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=hammer_time$'` ]").and_return(true)
    stub_command('docker ps -a | grep red_light | grep Exited').and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=red_light$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=green_light$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=quitter$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=restarter$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=uber_options$'` ]").and_return(true)
  end

  context 'testing create action' do
    # action create
    it 'create docker_container[hello-world]' do
      expect(chef_run).to create_docker_container('hello-world').with(
        container_name: 'hello-world',
        repo: nil,
        tag: 'latest',
        command: '/hello',
        api_retries: 0, # expecting 3
        attach_stderr: true,
        attach_stdin: false,
        attach_stdout: true,
        autoremove: false,
        binds: nil,
        cap_add: nil,
        cap_drop: nil,
        cgroup_parent: '',
        cpu_shares: 0,
        cpuset_cpus: '',
        detach: true,
        devices: nil,
        dns: nil,
        dns_search: nil,
        domain_name: '',
        entrypoint: nil,
        env: nil,
        extra_hosts: nil,
        exposed_ports: nil,
        force: false,
        host: nil,
        host_name: nil,
        labels: nil,
        links: nil,
        log_config: nil,
        log_driver: nil,
        log_opts: [],
        mac_address: '',
        memory: 0,
        memory_swap: -1,
        network_disabled: false,
        network_mode: nil,
        open_stdin: false,
        outfile: nil,
        port: nil,
        port_bindings: nil,
        privileged: false,
        publish_all_ports: false,
        read_timeout: 60,
        remove_volumes: false,
        restart_maximum_retry_count: 0,
        restart_policy: 'no',
        security_opts: [''],
        signal: 'SIGKILL',
        stdin_once: false,
        timeout: nil,
        tty: false,
        ulimits: nil,
        user: '',
        volumes: nil,
        volumes_from: nil,
        working_dir: nil,
        write_timeout: nil
      )
    end
  end

  context 'testing run action' do
    it 'run docker_container[hello-world]' do
      expect(chef_run).to run_docker_container('busybox_ls').with(
        repo: 'busybox',
        command: 'ls -la /'
      )
    end
  end

  context 'testing ports property' do
    it 'run_if_missing docker_container[alpine_ls]'
    it 'run docker_container[an_echo_server]'
    it 'run docker_container[another_echo_server]'
    it 'run docker_container[an_udp_echo_server]'
  end

  context 'testing action :kill' do
    it 'run execute[bill]'
    it 'kill docker_container[bill]'
  end

  context 'testing action :stop' do
    it 'run execute[hammer_time]'
    it 'stop docker_container[hammer_time]'
  end

  context 'testing action :pause' do
    it 'run execute[rm stale red_light]'
    it 'run execute[red_light]'
    it 'pause docker_container[red_light]'
  end

  context 'testing action :unpause' do
    it 'run bash[green_light]'
    it 'unpause docker_container[green_light]'
  end

  context 'testing action :restart' do
    it 'run bash[quitter]'
    it 'restart docker_container[quitter]'
    it 'create file[/marker_container_quitter_restarter]'
    it 'run execute[restarter]'
    it 'restart docker_container[restarter]'
    it 'create file[/marker_container_restarter]'
  end

  context 'testing action :delete' do
    it 'run execute[deleteme]'
    it 'create file[/marker_container_deleteme'
    it 'delete docker_container[deleteme]'
  end

  context 'testing action :redeploy' do
    it 'runs docker_container[redeployer]'
    it 'creates docker_container[unstarted_redeployer]'
    it 'runs execute[redeploy redeployers]'
  end

  context 'testing bind_mounts' do
    it 'creates directory[/hostbits]'
    it 'creates file[/hostbits/hello.txt]'
    it 'creates directory[/more-hostbits]'
    it 'creates file[/more-hostbits/hello.txt]'
    it 'run_if_missings docker_container[bind_mounter]'
  end

  context 'testing volumes_from' do
    it 'creates directory[/chefbuilder]'
    it 'runs execute[copy chef to chefbuilder]'
    it 'creates file[/chefbuilder/Dockerfile]'
    it 'builds_if_missing docker_image[chef_container]'
    it 'creates docker_container[chef_container]'
    it 'runs docker_container[ohai_debian]'
  end

  context 'testing env' do
    it 'runs_if_missing docker_container[env]'
  end

  context 'testing entrypoint' do
    it 'runs_if_missing docker_container[env]'
    it 'runs_if_missing docker_container[ohai_again]'
    it 'runs_if_missing docker_container[ohai_again_debian]'
  end

  context 'testing Dockefile CMD directive' do
    it 'creates directory[/cmd_test]'
    it 'creates file[/cmd_test/Dockerfile]'
    it 'build_if_missing docker_image[cmd_test]'
    it 'runs_if_missing docker_container[cmd_test]'
  end

  context 'testing autoremove' do
    it 'runs docker_container[sean_was_here]'
    it 'creates file[/marker_container_sean_was_here]'
  end

  context 'testing cap_add' do
    it 'runs_if_missing docker_container[cap_add_net_admin]'
    it 'runs_if_missing docker_container[cap_add_net_admin_error]'
  end

  context 'testing cap_drop' do
    it 'runs_if_missing docker_container[cap_drop_mknod]'
    it 'runs_if_missing docker_container[cap_drop_mknod_error]'
  end

  context 'testing host_name and domain_name' do
    it 'runs_if_missing docker_container[fqdn]'
  end

  context 'testing dns' do
    it 'runs_if_missing docker_container[dns]'
  end

  context 'testing extra_hosts' do
    it 'runs_if_missing docker_container[extra_hosts]'
  end

  context 'testing cpu_shares' do
    it 'runs_if_missing docker_container[cpu_shares]'
  end

  context 'testing cpuset_cpus' do
    it 'runs_if_missing docker_container[cpuset_cpus]'
  end

  context 'testing restart_policy' do
    it 'runs_if_missing docker_container[try_try_again]'
    it 'runs_if_missing docker_container[reboot_survivor]'
    it 'runs_if_missing docker_container[reboot_survivor_retry]'
  end

  context 'testing links' do
    it 'runs docker_container[link_source]'
    it 'runs docker_container[link_source_2]'
    it 'runs_if_missing docker_container[link_target_1]'
    it 'runs_if_missing docker_container[link_target_2]'
    it 'runs_if_missing docker_container[link_target_3]'
    it 'runs_if_missing docker_container[link_target_4]'
    it 'runs execute[redeploy_link_source]'
  end

  context 'testing link removal' do
    it 'runs_if_missing docker_container[another_link_source]'
    it 'runs_if_missing docker_container[another_link_target]'
    it 'creates file[/marker_container_remover]'
  end

  context 'testing volume removal' do
    it 'creates directory[/dangler]'
    it 'creates file[/dangler/Dockerfile]'
    it 'builds_if_missing docker_image[dangler]'
    it 'creates docker_container[dangler]'
    it 'creates file[/marker_container_dangler]'
    it 'deletes docker_container[dangler_volume_remover]'
  end

  context 'testing mutator' do
    it 'tags docker_tag[mutator_from_busybox]'
    it 'runs_if_missing docker_container[mutator]'
    it 'runs execute[commit mutator]'
  end

  context 'testing network_mode' do
    it 'runs docker_container[network_mode]'
  end

  context 'testing ulimits' do
    it 'runs docker_container[ulimits]'
  end

  context 'testing api_timeouts' do
    it 'runs docker_container[api_timeouts]'
  end

  context 'testing uber_options' do
    it 'runs execute[uber_options]'
    it 'runs docker_container[uber_options]'
  end

  context 'testing overrides' do
    it 'creates directory[/overrides]'
    it 'creates file[/overrides/Dockerfile]'
    it 'build_if_missing docker_image[overrides]'
    it 'runs_if_missing docker_container[overrides-1]'
    it 'runs_if_missing docker_container[overrides-2]'
  end

  context 'testing host overrides' do
    it 'creates docker_container[host_override]'
  end

  context 'testing logging drivers' do
    it 'runs docker_container[syslogger]'
  end
end
