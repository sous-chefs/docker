require 'spec_helper'
require_relative 'support/matchers'

describe 'docker::runit' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'stops the lxc-docker service' do
    expect(chef_run).to stop_service('lxc-docker')
  end

  it 'disables the lxc-docker service' do
    expect(chef_run).to disable_service('lxc-docker')
  end

  it 'includes the runit recipe' do
    expect(chef_run).to include_recipe('runit')
  end

  # TODO: Determine why runit assertions do not work
  # it 'creates the docker runit service template' do
  #   expect(chef_run).to create_template('/etc/sv/docker/run')
  #   expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #     %r{^exec /usr/bin/docker -d.*})
  # end

  # context 'when bind_socket is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['bind_socket'] = 'unix:///var/run/docker.sock'
  #     runner.converge(described_recipe)
  #   end

  #   it 'adds host flag to docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^exec /usr/bin/docker -d.* -H unix:///var/run/docker\.sock.*})
  #   end
  # end

  # context 'when bind_uri is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['bind_uri'] = 'tcp://127.0.0.1:4243'
  #     runner.converge(described_recipe)
  #   end

  #   it 'adds host flag to docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^exec /usr/bin/docker -d.* -H tcp://127\.0\.0\.1:4243.*})
  #   end
  # end

  # context 'when container_init_type is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['container_init_type'] = 'upstart'
  #     runner.converge(described_recipe)
  #   end

  #   it 'adds restart flag to docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^exec /usr/bin/docker -d.* -r=false.*})
  #   end
  # end

  # context 'when exec_driver is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['exec_driver'] = 'lxc'
  #     runner.converge(described_recipe)
  #   end

  #   it 'adds exec driver flag to docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^exec /usr/bin/docker -d.* -e lxc.*})
  #   end
  # end

  # context 'when group is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['group'] = 'vagrant'
  #     runner.converge(described_recipe)
  #   end

  #   it 'adds group flag to docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^exec /usr/bin/docker -d.* -G vagrant.*})
  #   end
  # end

  # context 'when http_proxy is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['http_proxy'] = 'http://username:password@proxy.example.com:8080'
  #     runner.converge(described_recipe)
  #   end

  #   it 'sets HTTP_PROXY environment variable in docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^export HTTP_PROXY=http://username:password@proxy.example.com:8080$})
  #   end
  # end

  # context 'when no_proxy is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['no_proxy'] = 'host1.example.com,111.111.111.0/24'
  #     runner.converge(described_recipe)
  #   end

  #   it 'sets NO_PROXY environment variable in docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       /^export NO_PROXY=host1.example.com,111.111.111.0\/24$/)
  #   end
  # end

  # context 'when options is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['options'] = '--debug'
  #     runner.converge(described_recipe)
  #   end

  #   it 'adds options to docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^exec /usr/bin/docker -d.* --debug.*})
  #   end
  # end

  # context 'when ramdisk is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['ramdisk'] = '/dev/shm'
  #     runner.converge(described_recipe)
  #   end

  #   it 'sets DOCKER_RAMDISK environment variable in docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^export DOCKER_RAMDISK=/dev/shm})
  #   end
  # end

  # context 'when storage_driver is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['storage_driver'] = 'brtfs'
  #     runner.converge(described_recipe)
  #   end

  #   it 'adds storage driver flag to docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       %r{^exec /usr/bin/docker -d.* -s brtfs.*})
  #   end
  # end

  # context 'when tmpdir is set' do
  #   let(:chef_run) do
  #     runner = ChefSpec::SoloRunner.new
  #     runner.node.set['docker']['tmpdir'] = '/tmp'
  #     runner.converge(described_recipe)
  #   end

  #   it 'sets TMPDIR environment variable in docker service' do
  #     expect(chef_run).to render_file('/etc/sv/docker/run').with_content(
  #       /^export TMPDIR=\/tmp$/)
  #   end
  # end

  it 'enables the docker runit service' do
    expect(chef_run).to enable_runit_service('docker')
  end
end
