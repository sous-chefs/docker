require 'spec_helper'

describe 'docker_test::image' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new
      .converge('docker_test::image')
  end

  # before do
  #   stub_command('/usr/bin/test -f /tmp/registry/tls/ca-key.pem').and_return(true)
  #   stub_command('/usr/bin/test -f /tmp/registry/tls/server-key.pem').and_return(true)
  #   stub_command('/usr/bin/test -f /tmp/registry/tls/server.csr').and_return(true)
  #   stub_command('/usr/bin/test -f /tmp/registry/tls/server.pem').and_return(true)
  #   stub_command('/usr/bin/test -f /tmp/registry/tls/key.pem').and_return(true)
  #   stub_command('/usr/bin/test -f /tmp/registry/tls/client.csr').and_return(true)
  #   stub_command('/usr/bin/test -f /tmp/registry/tls/cert.pem').and_return(true)
  #   stub_command("[ ! -z `docker ps -qaf 'name=registry_service$'` ]").and_return(true)
  #   stub_command("[ ! -z `docker ps -qaf 'name=registry_proxy$'` ]").and_return(true)

  #   allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
  #   allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('docker_test::default')
  # end

  # it 'includes recipe docker_test::default' do
  #   expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('docker_test::default')
  # end

  context 'when compiling the recipe' do
    # it 'pulls docker_image[hello-world]' do
    #   expect(chef_run).to pull_docker_image('hello-world')
    # end
  end
end
