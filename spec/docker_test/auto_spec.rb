# require 'spec_helper'

# describe 'docker_test::auto' do

#   cached(:chef_run) do
#     ChefSpec::SoloRunner.new(
#       platform: 'centos',
#       version: '7.0',
#       step_into: 'docker_service'
#       ).converge('docker_test::auto')
#   end

#   context 'testing default action, default properties' do
#     it 'creates docker_service[default]' do
#       expect(chef_run).to create_docker_service('default')
#     end

#     it 'starts docker_service[default]' do
#       expect(chef_run).to start_docker_service('default')
#     end

#     it 'creates docker_installation_script[default]' do
#       expect(chef_run).to create_docker_installation_script('default')
#     end

#     it 'creates docker_service_manager_systemd[default]' do
#       expect(chef_run).to start_docker_service_manager_systemd('default')
#     end
#   end
# end
