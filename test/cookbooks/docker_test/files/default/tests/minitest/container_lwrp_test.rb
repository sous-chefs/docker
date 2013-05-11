require File.expand_path('../support/helpers', __FILE__)

describe_recipe "docker_test::container_lwrp_test" do
  include Helpers::DockerTest

  it "has busybox sleep 1111 container running" do
    assert container_exists?("busybox","sleep 1111")
    assert container_running?("busybox","sleep 1111")
  end

  it "has busybox sleep 2222 container restarted" do
    assert container_exists?("busybox","sleep 2222")
    assert container_running?("busybox","sleep 2222")
  end

  it "has busybox sleep 3333 container stopped" do
    assert container_exists?("busybox","sleep 3333")
    refute container_running?("busybox","sleep 3333")
  end

  it "has busybox sleep 4444 container stopped and started" do
    assert container_exists?("busybox","sleep 4444")
    assert container_running?("busybox","sleep 4444")
  end

  it "has busybox sleep 5555 container removed" do
    refute container_exists?("busybox","sleep 5555")
    refute container_running?("busybox","sleep 5555")
  end

end
