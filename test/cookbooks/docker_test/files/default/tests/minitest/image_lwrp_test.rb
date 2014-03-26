require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker_test::image_lwrp_test' do
  include Helpers::DockerTest

  it 'has docker-test-image image not installed' do
    refute image_exists?('docker-test-image')
  end

  it 'has busybox image installed' do
    assert image_exists?('busybox')
  end

  it 'has bflad/testcontainerd image installed' do
    assert image_exists?('bflad/testcontainerd')
  end

  it 'has docker_image_build_1 image not installed' do
    refute image_exists?('docker_image_build_1')
  end

  it 'has docker_image_build_2 image installed' do
    assert image_exists?('docker_image_build_2')
  end
end
