# require 'spec_helper'

# describe 'docker_service_test::socket on centos-7.0' do
#   cached(:default) do
#     ChefSpec::SoloRunner.new(
#       platform: 'centos',
#       version: '7.0',
#       step_into: 'docker_service'
#     ) do |node|
#       node.set['docker']['version'] = nil
#     end.converge('docker_service_test::socket')
#   end

#   before do
#     stub_command('/usr/bin/docker  ps | head -n 1 | grep ^CONTAINER').and_return(true)
#   end

#   # Resource in docker_service_test::socket
#   context 'compiling the test recipe' do
#     it 'creates docker_service[default]' do
#       expect(default).to create_docker_service('default')
#     end
#   end

#   context 'stepping into docker_service[default] resource' do
#     it 'creates remote_file[/usr/bin/docker]' do
#       expect(default).to create_remote_file('/usr/bin/docker')
#         .with(
#           source: 'https://get.docker.com/builds/Linux/x86_64/docker-1.8.2',
#           checksum: '97a3f5924b0b831a310efa8bf0a4c91956cd6387c4a8667d27e2b2dd3da67e4d',
#           owner: 'root',
#           group: 'root',
#           mode: '0755'
#         )
#     end
#   end
# end
