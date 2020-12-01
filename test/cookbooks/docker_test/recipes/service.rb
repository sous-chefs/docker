docker_service 'default' do
  storage_driver 'overlay2'
  bip '10.10.10.0/24'
  default_ip_address_pool 'base=10.10.10.0/16,size=24'
  service_manager 'systemd'
  action [:create, :start]
end

docker_service 'one-mirror' do
  graph '/var/lib/docker-one'
  host 'unix:///var/run/docker-one.sock'
  registry_mirror 'https://mirror.gcr.io'
  service_manager 'systemd'
  action [:create, :start]
end

docker_service 'two-mirrors' do
  graph '/var/lib/docker-two'
  host 'unix:///var/run/docker-two.sock'
  registry_mirror ['https://mirror.gcr.io', 'https://another.mirror.io']
  service_manager 'systemd'
  action [:create, :start]
end
