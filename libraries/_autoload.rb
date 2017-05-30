begin
  gem 'docker-api', '= 1.33.2'
rescue LoadError
  unless defined?(ChefSpec)
    run_context = Chef::RunContext.new(Chef::Node.new, {}, Chef::EventDispatch::Dispatcher.new)

    require 'chef/resource/chef_gem'

    vendored_gems = *Dir[File.expand_path('../../files/default/vendor/cache/*.gem', __FILE__)]
    gems = vendored_gems.join('" "')
    docker = Chef::Resource::ChefGem.new(gems, run_context)
    docker.options '--local'
    docker.run_action(:install)
  end
end
