begin
  gem 'docker-api', '= 1.26.2'
rescue LoadError
  run_context = Chef::RunContext.new(Chef::Node.new, {}, Chef::EventDispatch::Dispatcher.new)

  require 'chef/resource/chef_gem'

  docker = Chef::Resource::ChefGem.new('docker-api', run_context)
  docker.version '= 1.26.2'
  docker.run_action(:install)
end
