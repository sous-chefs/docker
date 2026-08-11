# frozen_string_literal: true

docker_service 'default' do
  install_method 'package'
  service_manager 'none'
  setup_docker_repo false
  action :create
end
