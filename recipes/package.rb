case node['platform']
when 'centos', 'redhat'
  include_recipe 'yum::epel'

  package 'docker-io' do
    action node['docker']['package']['action'].intern
  end
when 'fedora'
  package 'docker-io' do
    action node['docker']['package']['action'].intern
  end
when 'ubuntu'
  apt_repository 'docker' do
    uri node['docker']['package']['repo_url']
    distribution node['docker']['package']['distribution']
    components ['main']
    key node['docker']['package']['repo_key']
  end

  package 'lxc-docker' do
    options '--force-yes'
    action node['docker']['package']['action'].intern
  end
end
