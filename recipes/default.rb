if Chef::Resource::ChefGem.instance_methods(false).include?(:compile_time)
  chef_gem 'docker-api' do
    version '1.24.1'
    compile_time true
  end
else
  chef_gem 'docker-api' do
    version '1.24.1'
    action :nothing
  end.run_action(:install)
end

require 'docker'
