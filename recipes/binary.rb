remote_file Docker::Helpers.executable(node) do
  source node['docker']['binary']['url']
  checksum node['docker']['binary']['checksum']
  owner 'root'
  group 'root'
  mode 00755
  action :create_if_missing
end
