
docker_service 'default' do
  storage_driver 'overlay2'
  bip '10.10.10.0/16'
  service_manager 'systemd'
  action [:create, :start]
end
