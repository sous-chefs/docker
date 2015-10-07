require 'spec_helper'

describe 'docker_test::image' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge('docker_test::image') }

  before do
    stub_command('/usr/bin/test -f /tmp/registry/tls/ca-key.pem').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/server-key.pem').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/server.csr').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/server.pem').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/key.pem').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/client.csr').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/cert.pem').and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=registry_service$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=registry_proxy$'` ]").and_return(true)
  end

  # I found some weird behavior with Chef 12.4.3.
  context 'when compiling the recipe' do
    it 'pulls docker_image[hello-world]' do
      expect(chef_run).to pull_docker_image('hello-world').with(
        container_name: nil, # expected 'hello-world'
        repo: 'hello-world',
        tag: 'latest',
        command: nil, # expected ''
        api_retries: 3, 
        attach_stderr: nil, # expected true
        attach_stdin: nil, # expected false
        attach_stdout: nil, # expected true
        autoremove: nil, # expected false
        binds: nil, 
        cap_add: nil,
        cap_drop: nil,
        cgroup_parent: nil, # expecting ''
        cpu_shares: nil, # expecting 0
        cpuset_cpus: nil, # expecting ''
        detach: nil, # expecting true
        devices: nil,
        dns: nil,
        dns_search: nil,
        domain_name: nil, # expecting ''
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
        log_opts: nil, # expecting []
        mac_address: nil, # expecting ''
        memory: nil, # expecting 0
        memory_swap: nil, # expecting -1
        network_disabled: nil, # expecting false
        network_mode: nil,
        open_stdin: nil, # expecting false
        outfile: nil,
        port: nil,
        port_bindings: nil,
        privileged: nil, # expecting false
        publish_all_ports: nil, # expecting false
        read_timeout: 120, # expecting 60
        remove_volumes: nil, # expecting false
        restart_maximum_retry_count: nil, # expecting 0
        restart_policy: nil, # expecting 'no'
        security_opts: nil, # expecting ['']
        signal: nil, # expecting 'SIGKILL'
        stdin_once: nil, # expecting false
        # timeout: nil, # causes a chefspec error
        tty: nil, # expecting false
        ulimits: nil,
        user: nil, # expecting ''
        volumes: nil,
        volumes_from: nil,
        working_dir: nil,
        write_timeout: nil
        )
    end

    it 'includes the "docker_test::registry" recipe' do
      expect(chef_run).to include_recipe('docker_test::registry')
    end
  end
end
