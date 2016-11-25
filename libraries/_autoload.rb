begin
  gem 'docker-api', '= 1.32.1'
rescue LoadError
  unless defined?(ChefSpec)
    run_context = Chef::RunContext.new(Chef::Node.new, {}, Chef::EventDispatch::Dispatcher.new)

    require 'chef/resource/chef_gem'

    docker = Chef::Resource::ChefGem.new('docker-api', run_context)
    docker.version '= 1.32.1'
    docker.run_action(:install)
  end
end
