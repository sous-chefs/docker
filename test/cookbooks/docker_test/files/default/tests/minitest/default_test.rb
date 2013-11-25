require File.expand_path('../support/helpers', __FILE__)

describe_recipe "docker_test::default" do
  include Helpers::DockerTest
end
