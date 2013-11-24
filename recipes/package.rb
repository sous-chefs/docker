case node['platform']
when 'fedora'
  yum_repository 'docker-goldmann' do
    repo_name 'docker'
    description 'Intermediate repository for Docker RPMS for Fedora'
    url node['docker']['package']['repo_url']
    action :add
  end

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
