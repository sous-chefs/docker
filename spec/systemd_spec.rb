require 'spec_helper'

describe 'docker::systemd' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'creates the docker socket template' do
    expect(chef_run).to create_template('/usr/lib/systemd/system/docker.socket')
    expect(chef_run).to render_file('/usr/lib/systemd/system/docker.socket').with_content(
      /^ListenStream=.+/)
  end

  it 'creates the docker service template' do
    expect(chef_run).to create_template('/usr/lib/systemd/system/docker.service')
    expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
      %r{^ExecStart=/usr/bin/docker -d.*})
    resource = chef_run.template('/usr/lib/systemd/system/docker.service')
    expect(resource).to notify('execute[systemctl-daemon-reload]').to(:run).immediately
    expect(resource).to notify('service[docker]').to(:restart).immediately
  end

  context 'when bind_socket is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['bind_socket'] = 'unix:///var/run/docker.sock'
      runner.converge(described_recipe)
    end

    it 'adds host flag to docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^ExecStart=/usr/bin/docker -d.* -H unix:///var/run/docker\.sock.*})
    end
  end

  context 'when bind_uri is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['bind_uri'] = 'tcp://127.0.0.1:4243'
      runner.converge(described_recipe)
    end

    it 'adds host flag to docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^ExecStart=/usr/bin/docker -d.* -H tcp://127\.0\.0\.1:4243.*})
    end
  end

  context 'when container_init_type is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['container_init_type'] = 'upstart'
      runner.converge(described_recipe)
    end

    it 'adds restart flag to docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^ExecStart=/usr/bin/docker -d.* -r=false.*})
    end
  end

  context 'when exec_driver is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['exec_driver'] = 'lxc'
      runner.converge(described_recipe)
    end

    it 'adds exec driver flag to docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^ExecStart=/usr/bin/docker -d.* -e lxc.*})
    end
  end

  context 'when group is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['group'] = 'vagrant'
      runner.converge(described_recipe)
    end

    it 'adds group flag to docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^ExecStart=/usr/bin/docker -d.* -G vagrant.*})
    end
  end

  context 'when http_proxy is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['http_proxy'] = 'http://username:password@proxy.example.com:8080'
      runner.converge(described_recipe)
    end

    it 'sets HTTP_PROXY environment variable in docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^Environment="HTTP_PROXY=http://username:password@proxy.example.com:8080"$})
    end
  end

  context 'when options is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['options'] = '--debug'
      runner.converge(described_recipe)
    end

    it 'adds options to docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^ExecStart=/usr/bin/docker -d.* --debug.*})
    end
  end

  context 'when ramdisk is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['ramdisk'] = '/dev/shm'
      runner.converge(described_recipe)
    end

    it 'sets DOCKER_RAMDISK environment variable in docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^Environment="DOCKER_RAMDISK=/dev/shm"})
    end
  end

  context 'when storage_driver is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['storage_driver'] = 'brtfs'
      runner.converge(described_recipe)
    end

    it 'adds storage driver flag to docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        %r{^ExecStart=/usr/bin/docker -d.* -s brtfs.*})
    end
  end

  context 'when tmpdir is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['tmpdir'] = '/tmp'
      runner.converge(described_recipe)
    end

    it 'sets TMPDIR environment variable in docker service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/docker.service').with_content(
        /^Environment="TMPDIR=\/tmp"$/)
    end
  end

  it 'starts the docker service' do
    expect(chef_run).to start_service('docker')
  end

  it 'enables the docker service' do
    expect(chef_run).to enable_service('docker')
  end
end
