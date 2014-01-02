# TODO: Platforms handled here should be fixed in lxc cookbook
# Currently: https://github.com/hw-cookbooks/lxc/
case node['platform']
when 'debian'
  package 'lxc'
when 'oracle'
  package 'lxc'
when 'ubuntu'
  include_recipe 'lxc'
end
