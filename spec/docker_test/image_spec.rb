require 'spec_helper'

describe 'docker_test::image' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge('docker_test::image') }

  before do
    stub_command('/usr/bin/test -f /tmp/registry/tls/ca-key.pem').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/server-key.pem').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/server.csr').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/server.pem').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/key.pem').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/client.csr').and_return(true)
    stub_command('/usr/bin/test -f /tmp/registry/tls/cert.pem').and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=registry_service$'` ]").and_return(true)
    stub_command("[ ! -z `docker ps -qaf 'name=registry_proxy$'` ]").and_return(true)
  end

  context 'when compiling the recipe' do
    it 'pulls docker_image[hello-world]' do
      expect(chef_run).to pull_docker_image('hello-world').with(
        api_retries:  3,
        destination: nil,
        force: false,
        host: nil,
        nocache: false,
        noprune:  false,
        read_timeout: 120,
        repo: 'hello-world',
        rm: true,
        source: nil,
        tag: 'latest',
        write_timeout: nil
        )
    end

    it 'includes the "docker_test::registry" recipe' do
      expect(chef_run).to include_recipe('docker_test::registry')
    end
  end
end
