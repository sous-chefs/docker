# begin
#   gem 'docker-api', '= 1.33.0'
# rescue LoadError
#   unless defined?(ChefSpec)
#     run_context = Chef::RunContext.new(Chef::Node.new, {}, Chef::EventDispatch::Dispatcher.new)

#     require 'chef/resource/chef_gem'

#     docker = Chef::Resource::ChefGem.new('docker-api', run_context)
#     docker.version '= 1.33.0'
#     docker.run_action(:install)
#   end
# end

# 682 - vendoring
$LOAD_PATH.push *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
$LOAD_PATH.unshift *Dir[File.expand_path('..', __FILE__)]
