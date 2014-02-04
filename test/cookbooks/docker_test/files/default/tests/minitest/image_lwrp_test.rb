require File.expand_path('../support/helpers', __FILE__)

describe_recipe "docker_test::image_lwrp_test" do
  include Helpers::DockerTest

  it "has base image not installed" do
    refute image_exists?("base")
  end

  it "has busybox image installed" do
    assert image_exists?("busybox")
  end

  it "has bflad/testcontainerd image installed" do
    assert image_exists?("bflad/testcontainerd")
  end

  it "has myImage image not installed" do
    refute image_exists?("myImage")
  end
end
