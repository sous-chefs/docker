directory "#{node['go']['gopath']}/src/github.com/dotcloud" do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

git "#{node['go']['gopath']}/src/github.com/dotcloud/docker" do
  repository node['docker']['source']['url']
  reference node['docker']['source']['ref']
  action :checkout
end

golang_package 'github.com/dotcloud/docker' do
  action :install
end
