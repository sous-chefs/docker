case node['platform']
when 'ubuntu'
  apt_repository 'docker' do
    uri node['docker']['package']['repo_url']
    distribution node['docker']['package']['distribution']
    components ['main']
    key node['docker']['package']['repo_key']
  end
end

package 'lxc-docker' do
  options '--force-yes'
end
