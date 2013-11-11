remote_file "#{node['docker']['install_dir']}/docker" do
  source node['docker']['binary']['url']
  owner 'root'
  group 'root'
  mode 00755
  action :create_if_missing
end
