require 'spec_helper'

describe 'docker_test::container' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge('docker_test::container') }

  before do
    stub_command("[ ! -z `docker ps -qaf 'name=busybox_ls$'`]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=busybox_ls$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=bill$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=hammer_time$'` ]").and_return(true)
    stub_command("docker ps -a | grep red_light | grep Exited").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=red_light$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=green_light$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=quitter$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=restarter$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=uber_options$'` ]").and_return(true)
  end

  context 'when compiling the recipe' do

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
end
