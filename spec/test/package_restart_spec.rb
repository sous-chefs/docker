# frozen_string_literal: true

require 'spec_helper'

describe 'test::package_restart' do
  platform 'ubuntu', '24.04'
  step_into :docker_service, :docker_installation_package

  it 'restarts the service when the Docker package changes' do
    expect(chef_run.package('docker-ce')).to notify('docker_service[default]').to(:restart).immediately
  end
end
