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
      expect(chef_run).to create_docker_container('hello-world')
    end
    
  end
end
