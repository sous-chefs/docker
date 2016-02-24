run_context = Chef::RunContext.new(Chef::Node.new, {}, Chef::EventDispatch::Dispatcher.new)

require 'chef/resource/chef_gem'

excon = Chef::Resource::ChefGem.new('excon', run_context)
excon.version '=0.45.4'
excon.run_action(:install)
docker = Chef::Resource::ChefGem.new('docker-api', run_context)
docker.version '=1.26'
docker.run_action(:install)
json = Chef::Resource::ChefGem.new('json', run_context)
json.version '=1.8.3'
json.run_action(:install)
