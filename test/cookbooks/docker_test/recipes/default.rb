docker_service 'default' do
  action [:create, :start]
  notifies :reload, 'ohai[reload]'
end

# pick up docker0 interface
ohai "reload" do
  action :nothing
end
