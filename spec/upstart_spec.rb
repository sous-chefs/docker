require 'spec_helper'

describe 'docker::upstart' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'creates the docker Upstart template' do
    expect(chef_run).to create_template('/etc/init/docker.conf')
    expect(chef_run).to render_file('/etc/init/docker.conf').with_content(
      /exec "\$DOCKER" -d \$DOCKER_OPTS/)
  end

  context 'when running on debian/ubuntu' do
    it 'creates the docker sysconfig template in /etc/default' do
      expect(chef_run).to create_template('/etc/default/docker')
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER="/usr/bin/docker"$})
      resource = chef_run.template('/etc/default/docker')
      expect(resource).to notify('service[docker]').to(:stop).immediately
      expect(resource).to notify('service[docker]').to(:start).immediately
    end
  end

  context 'when running on non debian/ubuntu' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: '6.5').converge(described_recipe)
    end

    it 'creates the docker sysconfig template in /etc/sysconfig' do
      expect(chef_run).to create_template('/etc/sysconfig/docker')
    end
  end

  context 'when api_enable_cors is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['api_enable_cors'] = true
      runner.converge(described_recipe)
    end

    it 'adds api-enable-cors flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --api-enable-cors=true.*'$/)
    end
  end

  # DEPRECATED: will be removed in chef-docker 1.0
  context 'when bind_socket is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['bind_socket'] = 'unix:///var/run/docker.sock'
      runner.converge(described_recipe)
    end

    it 'adds host flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --host=unix:///var/run/docker\.sock.*'$})
    end
  end

  # DEPRECATED: will be removed in chef-docker 1.0
  context 'when bind_uri is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['bind_uri'] = 'tcp://127.0.0.1:4243'
      runner.converge(described_recipe)
    end

    it 'adds host flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --host=tcp://127\.0\.0\.1:4243.*'$})
    end
  end

  context 'when bip is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['bip'] = '10.0.0.2'
      runner.converge(described_recipe)
    end

    it 'adds bip flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --bip=10\.0\.0\.2.*'$/)
    end
  end

  context 'when bridge is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['bridge'] = 'br0'
      runner.converge(described_recipe)
    end

    it 'adds bridge flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --bridge=br0.*'$/)
    end
  end

  context 'when container_init_type is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['container_init_type'] = 'upstart'
      runner.converge(described_recipe)
    end

    it 'adds restart flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --restart=false.*'$/)
    end
  end

  context 'when debug is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['debug'] = true
      runner.converge(described_recipe)
    end

    it 'adds debug flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --debug=true.*'$/)
    end
  end

  context 'when dns is set with String' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['dns'] = '8.8.8.8'
      runner.converge(described_recipe)
    end

    it 'adds dns flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --dns=8.8.8.8.*'$/)
    end
  end

  context 'when dns is set with Array' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['dns'] = %w(8.8.8.8 8.8.4.4)
      runner.converge(described_recipe)
    end

    it 'adds dns flags to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --dns=8.8.8.8 --dns=8.8.4.4.*'$/)
    end
  end

  context 'when dns_search is set with String' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['dns_search'] = 'example.com'
      runner.converge(described_recipe)
    end

    it 'adds dns-search flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --dns-search=example.com.*'$/)
    end
  end

  context 'when dns_search is set with Array' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['dns_search'] = %w(foo.example.com bar.example.com)
      runner.converge(described_recipe)
    end

    it 'adds dns-search flags to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --dns-search=foo.example.com --dns-search=bar.example.com.*'$/)
    end
  end

  context 'when exec_driver is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['exec_driver'] = 'lxc'
      runner.converge(described_recipe)
    end

    it 'adds exec driver flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --exec-driver=lxc.*'$/)
    end
  end

  context 'when graph is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['graph'] = '/tmp/docker'
      runner.converge(described_recipe)
    end

    it 'adds graph flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --graph=/tmp/docker.*'$})
    end
  end

  context 'when group is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['group'] = 'vagrant'
      runner.converge(described_recipe)
    end

    it 'adds group flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --group=vagrant.*'$/)
    end
  end

  context 'when host is set with String' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['host'] = 'unix:///var/run/docker.sock'
      runner.converge(described_recipe)
    end

    it 'adds host flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --host=unix:///var/run/docker\.sock.*'$})
    end
  end

  context 'when host is set with Array' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['host'] = %w(unix:///var/run/docker.sock tcp://127.0.0.1:4243)
      runner.converge(described_recipe)
    end

    it 'adds host flags to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --host=unix:///var/run/docker\.sock --host=tcp://127\.0\.0\.1:4243.*'$})
    end
  end

  context 'when http_proxy is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['http_proxy'] = 'http://username:password@proxy.example.com:8080'
      runner.converge(described_recipe)
    end

    it 'sets HTTP_PROXY environment variable in docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^export HTTP_PROXY=http://username:password@proxy.example.com:8080$})
    end
  end

  context 'when no_proxy is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['no_proxy'] = 'host1.example.com,111.111.111.0/24'
      runner.converge(described_recipe)
    end

    it 'sets NO_PROXY environment variable in docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^export NO_PROXY=host1.example.com,111.111.111.0\/24$/)
    end
  end

  context 'when icc is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['icc'] = false
      runner.converge(described_recipe)
    end

    it 'adds icc flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --icc=false.*'$/)
    end
  end

  context 'when ip is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['ip'] = '127.0.0.1'
      runner.converge(described_recipe)
    end

    it 'adds ip flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --ip=127\.0\.0\.1.*'$/)
    end
  end

  context 'when iptables is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['iptables'] = false
      runner.converge(described_recipe)
    end

    it 'adds iptables flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --iptables=false.*'$/)
    end
  end

  context 'when logfile is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['logfile'] = '/var/log/docker.log'
      runner.converge(described_recipe)
    end

    it 'sets DOCKER_LOGFILE environment variable in docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_LOGFILE=/var/log/docker.log$})
    end
  end

  context 'when mtu is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['mtu'] = 1492
      runner.converge(described_recipe)
    end

    it 'adds mtu flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --mtu=1492.*'$/)
    end
  end

  context 'when options is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['options'] = '--debug'
      runner.converge(described_recipe)
    end

    it 'adds options to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --debug.*'$/)
    end
  end

  context 'when pidfile is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['pidfile'] = '/tmp/docker.pid'
      runner.converge(described_recipe)
    end

    it 'sets DOCKER_PIDFILE environment variable in docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_PIDFILE=/tmp/docker.pid$})
    end

    it 'adds pidfile flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --pidfile=/tmp/docker.pid.*'$})
    end
  end

  context 'when ramdisk is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['ramdisk'] = '/dev/shm'
      runner.converge(described_recipe)
    end

    it 'sets DOCKER_RAMDISK environment variable in docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_RAMDISK=/dev/shm$})
    end
  end

  context 'when storage_driver is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['storage_driver'] = 'brtfs'
      runner.converge(described_recipe)
    end

    it 'adds storage driver flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --storage-driver=brtfs.*'$/)
    end
  end

  context 'when tls is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['tls'] = true
      runner.converge(described_recipe)
    end

    it 'adds tls flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --tls=true.*'$/)
    end
  end

  context 'when tlscacert is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['tlscacert'] = '/tmp/ca.pem'
      runner.converge(described_recipe)
    end

    it 'adds tlscacert flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --tlscacert=/tmp/ca.pem.*'$})
    end
  end

  context 'when tlscert is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['tlscert'] = '/tmp/cert.pem'
      runner.converge(described_recipe)
    end

    it 'adds tlscert flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --tlscert=/tmp/cert.pem.*'$})
    end
  end

  context 'when tlskey is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['tlskey'] = '/tmp/key.pem'
      runner.converge(described_recipe)
    end

    it 'adds tlskey flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS='.* --tlskey=/tmp/key.pem.*'$})
    end
  end

  context 'when tlsverify is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['tlsverify'] = true
      runner.converge(described_recipe)
    end

    it 'adds tlsverify flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS='.* --tlsverify=true.*'$/)
    end
  end

  context 'when tmpdir is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['tmpdir'] = '/tmp'
      runner.converge(described_recipe)
    end

    it 'sets TMPDIR environment variable in docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^export TMPDIR="\/tmp"$/)
    end
  end

  it 'starts the docker service' do
    expect(chef_run).to start_service('docker')
  end
end
