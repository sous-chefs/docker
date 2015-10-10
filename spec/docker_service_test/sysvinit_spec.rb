# require 'spec_helper'

# describe 'docker_service with Centos' do
#   let(:chef_run) do
#     ChefSpec::SoloRunner.new(
#       platform: 'centos',
#       version: '7.0',
#       step_into: 'docker_service_sysvinit'
#     ).converge('docker_service_test::sysvinit')
#   end

#   before do
#     stub_command('/usr/bin/docker  ps | head -n 1 | grep ^CONTAINER').and_return(true)
#   end

#   it 'creates docker_service_sysvinit[default]' do
#     expect(chef_run).to create_docker_service_sysvinit('default')
#   end

#   it 'creates the sysvinit file' do
#     expect(chef_run).to create_template('/etc/init.d/docker')
#   end
# end
