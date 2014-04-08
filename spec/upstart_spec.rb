require 'spec_helper'

describe 'docker::upstart' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'creates the docker Upstart template' do
    expect(chef_run).to create_template('/etc/init/docker.conf')
    expect(chef_run).to render_file('/etc/init/docker.conf').with_content(
      /"\$DOCKER" -d \$DOCKER_OPTS/)
  end

  it 'creates the docker sysconfig template' do
    expect(chef_run).to create_template('/etc/default/docker')
    expect(chef_run).to render_file('/etc/default/docker').with_content(
      %r{^DOCKER="/usr/bin/docker"$})
    resource = chef_run.template('/etc/default/docker')
    expect(resource).to notify('service[docker]').to(:stop).immediately
    expect(resource).to notify('service[docker]').to(:start).immediately
  end

  context 'when bind_socket is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['bind_socket'] = 'unix:///var/run/docker.sock'
      runner.converge(described_recipe)
    end

    it 'adds host flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS="\$DOCKER_OPTS -H unix:///var/run/docker\.sock"$})
    end
  end

  context 'when bind_uri is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['bind_uri'] = 'tcp://127.0.0.1:4243'
      runner.converge(described_recipe)
    end

    it 'adds host flag to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_OPTS="\$DOCKER_OPTS -H tcp://127\.0\.0\.1:4243"$})
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
        /^DOCKER_OPTS="\$DOCKER_OPTS -r=false"$/)
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
        /^DOCKER_OPTS="\$DOCKER_OPTS -e lxc"$/)
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
        /^DOCKER_OPTS="\$DOCKER_OPTS -G vagrant"$/)
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

  context 'when options is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['options'] = '--debug'
      runner.converge(described_recipe)
    end

    it 'adds options to docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        /^DOCKER_OPTS="\$DOCKER_OPTS --debug"$/)
    end
  end

  context 'when pidfile is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['pidfile'] = '/var/run/docker.pid'
      runner.converge(described_recipe)
    end

    it 'sets DOCKER_PIDFILE environment variable in docker service' do
      expect(chef_run).to render_file('/etc/default/docker').with_content(
        %r{^DOCKER_PIDFILE=/var/run/docker.pid$})
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
        /^DOCKER_OPTS="\$DOCKER_OPTS -s brtfs"$/)
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
