require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker_test::container_lwrp' do
  include Helpers::DockerTest

  it 'has busybox sleep 1111 container running' do
    assert container_exists?('busybox', 'sleep 1111')
    assert container_running?('busybox', 'sleep 1111')
    service('busybox').wont_be_running
  end

  it 'has busybox sleep 2222 container restarted' do
    assert container_exists?('busybox', 'sleep 2222')
    assert container_running?('busybox', 'sleep 2222')
    service('busybox').wont_be_running
  end

  it 'has busybox sleep 3333 container stopped' do
    assert container_exists?('busybox', 'sleep 3333')
    refute container_running?('busybox', 'sleep 3333')
    service('busybox').wont_be_running
  end

  it 'has busybox sleep 4444 container stopped and started' do
    assert container_exists?('busybox', 'sleep 4444')
    assert container_running?('busybox', 'sleep 4444')
    service('busybox').wont_be_running
  end

  it 'has busybox sleep 5555 container removed' do
    refute container_exists?('busybox', 'sleep 5555')
    refute container_running?('busybox', 'sleep 5555')
    service('busybox').wont_be_running
  end

  it 'has tduffield/testcontainerd container running' do
    assert container_exists?('tduffield/testcontainerd')
    assert container_running?('tduffield/testcontainerd')
    service('testcontainerd').must_be_running
  end

  it 'has a named busybox-container running sleep 8888 and started' do
    cmd = container_info('busybox-container').first['Config']['Cmd']
    assert cmd.grep(/8888/).count > 0
    assert container_running?('busybox-container')
  end

  it 'has busybox sleep 9999 container created and not started' do
    assert container_exists?('busybox', 'sleep 9999')
    refute container_running?('busybox', 'sleep 9999')
    service('busybox').wont_be_running
  end

  it 'has a named busybox2-container running sleep 9888 and not started' do
    cmd = container_info('busybox2-container').first['Config']['Cmd']
    assert cmd.grep(/9888/).count > 0
    refute container_running?('busybox2-container')
  end
end
