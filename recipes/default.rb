include_recipe 'apt' if node['platform'] == 'ubuntu'

package 'apt-transport-https'
package 'bsdtar'

if node['docker']['install_type'] == 'source'
  node.set['go']['version'] = '1.1'
  include_recipe 'golang'
  include_recipe 'git'
end

include_recipe 'lxc'
include_recipe 'docker::aufs'
include_recipe "docker::#{node['docker']['install_type']}"
include_recipe 'docker::upstart'
