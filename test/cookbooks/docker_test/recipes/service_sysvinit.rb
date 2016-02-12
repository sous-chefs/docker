#
def wheezy?
  return true if node['platform'] == 'debian' && node['platform_version'].to_i == 7
  false
end

if wheezy?
  file '/etc/apt/sources.list.d/wheezy-backports.list' do
    content 'deb http://ftp.de.debian.org/debian wheezy-backports main'
    notifies :run, 'execute[wheezy apt update]', :immediately
    action :create
  end

  execute 'wheezy apt update' do
    command 'apt-get update'
    action :nothing
  end
end

docker_installation_package 'default' do
  action :create
end

docker_service_manager_sysvinit 'default' do
  host 'unix:///var/run/docker.sock'
  action :start
end

docker_image 'hello-world' do
  host 'unix:///var/run/docker.sock'
  tag 'latest'
end

docker_container 'hello-world' do
  host 'unix:///var/run/docker.sock'
  command '/hello'
  action :create
end
