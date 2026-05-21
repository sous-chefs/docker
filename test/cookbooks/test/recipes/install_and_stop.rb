# frozen_string_literal: true

docker_service 'default' do
  action [:create, :stop]
end
