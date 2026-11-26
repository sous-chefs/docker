# frozen_string_literal: true

docker_service 'legacy-cluster' do
  cluster_store 'etcd://127.0.0.1:4001'
  cluster_advertise '127.0.0.1:4001'
  cluster_store_opts 'kv.cacertfile=/ca.pem'
  service_manager 'systemd'
  action :start
end
