# frozen_string_literal: true

require 'spec_helper'
require 'docker'

describe 'Docker registry credentials' do
  step_into :docker_registry, :docker_image
  platform 'ubuntu', '24.04'

  let(:connection) { Docker::Connection.new('unix:///unused-docker.sock', {}) }
  let(:requests) { [] }

  before do
    allow(Docker::Connection).to receive(:new).and_return(connection)
    allow(connection).to receive(:get).with(%r{\A/images/.+/json\z}, {}).and_return('{"Id":"sha256:test"}')
    allow(connection).to receive(:post) do |path, query, options|
      requests << [path, query, options]
      '{}'
    end
  end

  def auth_config(path, query)
    options = requests.find { |url, params, _| url == path && params == query }.fetch(2)
    JSON.parse(Base64.urlsafe_decode64(options.fetch(:headers).fetch('X-Registry-Auth')))
  end

  context 'with several credentials on a registry with a port' do
    recipe do
      docker_registry 'https://registry.example.test:5443/' do
        username 'default-user'
      end

      docker_registry 'team login' do
        serveraddress 'https://registry.example.test:5443/'
        repository_prefix 'team'
        username 'team-user'
      end

      docker_registry 'nested team login' do
        serveraddress 'https://registry.example.test:5443/'
        repository_prefix 'team/production'
        username 'production-user'
      end

      docker_image 'registry.example.test:5443/team/production/application' do
        action [:pull, :push]
      end

      docker_image 'registry.example.test:5443/team/production-preview/application'
      docker_image 'registry.example.test:5443/teammate/application'

      docker_image 'override production credentials' do
        repo 'registry.example.test:5443/team/production/override'
        repo_credential_override 'team'
        action [:pull, :push]
      end
    end

    it 'sends the registry host to /auth and selects credentials for pulls and pushes' do
      chef_run

      logins = requests.select { |path, _, _| path == '/auth' }.map { |_, _, options| JSON.parse(options.fetch(:body)) }
      expect(logins.map { |login| login.fetch('serveraddress') }).to eq(['registry.example.test:5443'] * 3)
      expect(logins.map { |login| login.fetch('username') }).to eq(%w(default-user team-user production-user))

      host = 'registry.example.test:5443'
      expect(auth_config('/images/create', 'fromImage' => "#{host}/team/production/application:latest")).to eq(logins.fetch(2))
      expect(auth_config("/images/#{host}/team/production/application/push", tag: 'latest')).to eq(logins.fetch(2))
      expect(auth_config('/images/create', 'fromImage' => "#{host}/team/production-preview/application:latest")).to eq(logins.fetch(1))
      expect(auth_config('/images/create', 'fromImage' => "#{host}/teammate/application:latest")).to eq(logins.fetch(0))
      expect(auth_config('/images/create', 'fromImage' => "#{host}/team/production/override:latest")).to eq(logins.fetch(1))
      expect(auth_config("/images/#{host}/team/production/override/push", tag: 'latest')).to eq(logins.fetch(1))
    end
  end

  context 'with legacy Docker Hub and anonymous images' do
    recipe do
      docker_image 'busybox'

      docker_registry 'https://index.docker.io/v1/' do
        username 'hub-user'
      end

      docker_image 'org/release.v1' do
        action [:pull, :push]
      end

      docker_image 'localhost/org/release.v1'
    end

    it 'keeps legacy host credentials and uses an empty auth hash without a login' do
      chef_run

      expect(auth_config('/images/create', 'fromImage' => 'busybox:latest')).to eq({})
      expect(auth_config('/images/create', 'fromImage' => 'localhost/org/release.v1:latest')).to eq({})
      expect(auth_config('/images/create', 'fromImage' => 'org/release.v1:latest')).to include('username' => 'hub-user', 'serveraddress' => 'index.docker.io')
      expect(auth_config('/images/org/release.v1/push', tag: 'latest')).to include('username' => 'hub-user', 'serveraddress' => 'index.docker.io')
    end
  end

  context 'with equivalent Docker Hub names' do
    recipe do
      docker_registry 'https://index.docker.io/v1/' do
        username 'index-default'
      end

      docker_registry 'https://docker.io/' do
        username 'docker-default'
      end

      docker_registry 'Docker Hub official images' do
        serveraddress 'https://index.docker.io/v1/'
        repository_prefix 'library'
        username 'official-user'
      end

      docker_registry 'Docker Hub team images' do
        serveraddress 'https://docker.io/'
        repository_prefix 'team'
        username 'team-user'
      end

      %w(alpine library/alpine docker.io/alpine docker.io/library/alpine index.docker.io/alpine index.docker.io/library/alpine).each do |name|
        docker_image name do
          action [:pull, :push]
        end
      end

      docker_image 'index.docker.io/team/application'
      docker_image 'team/application'
      docker_image 'index.docker.io/library/override' do
        repo_credential_override 'team'
      end
      docker_image 'other/application'
      docker_image 'docker.io/other/application'
      docker_image 'registry-1.docker.io/library/alpine'
    end

    it 'shares scoped credentials across image names and preserves login and fallback hosts' do
      chef_run

      logins = requests.select { |path, _, _| path == '/auth' }.map { |_, _, options| JSON.parse(options.fetch(:body)) }
      expect(logins.map { |login| login.fetch('serveraddress') }).to eq(%w(index.docker.io docker.io index.docker.io docker.io))

      %w(alpine library/alpine docker.io/alpine docker.io/library/alpine index.docker.io/alpine index.docker.io/library/alpine).each do |name|
        expect(auth_config('/images/create', 'fromImage' => "#{name}:latest")).to eq(logins.fetch(2))
        expect(auth_config("/images/#{name}/push", tag: 'latest')).to eq(logins.fetch(2))
      end

      expect(auth_config('/images/create', 'fromImage' => 'index.docker.io/team/application:latest')).to eq(logins.fetch(3))
      expect(auth_config('/images/create', 'fromImage' => 'team/application:latest')).to eq(logins.fetch(3))
      expect(auth_config('/images/create', 'fromImage' => 'index.docker.io/library/override:latest')).to eq(logins.fetch(3))
      expect(auth_config('/images/create', 'fromImage' => 'other/application:latest')).to eq(logins.fetch(0))
      expect(auth_config('/images/create', 'fromImage' => 'docker.io/other/application:latest')).to eq(logins.fetch(1))
      expect(auth_config('/images/create', 'fromImage' => 'registry-1.docker.io/library/alpine:latest')).to eq({})
    end
  end

  context 'with an override registered on a different registry' do
    recipe do
      docker_registry 'elsewhere team login' do
        serveraddress 'https://elsewhere.example.test/'
        repository_prefix 'team'
        username 'elsewhere-user'
      end

      docker_image 'registry.example.test/team/application' do
        repo_credential_override 'team'
      end
    end

    it 'rejects the override before sending an image request' do
      expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed, /No Docker registry credentials registered/)
      expect(requests.map(&:first)).to eq(['/auth'])
    end
  end

  context 'with an ambiguous single-label registry address' do
    recipe do
      docker_registry 'private registry' do
        serveraddress 'https://REGISTRY/'
        repository_prefix 'team'
        username 'private-user'
      end

      docker_image 'team/application'
    end

    it 'rejects the scoped login before its credentials are sent to Docker Hub' do
      expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed, /repository_prefix requires an explicit registry address/)
      expect(requests).to be_empty
    end
  end

  context 'with a single-label private image authority' do
    recipe do
      docker_registry 'https://index.docker.io/v1/' do
        username 'hub-default'
      end

      docker_registry 'Docker Hub team login' do
        serveraddress 'https://index.docker.io/v1/'
        repository_prefix 'team'
        username 'hub-user'
      end

      docker_image 'REGISTRY/team/application' do
        action [:pull, :push]
      end

      docker_image 'other/application'
    end

    it 'sends private image requests without repository or default credentials from Docker Hub' do
      chef_run

      expect(auth_config('/images/create', 'fromImage' => 'REGISTRY/team/application:latest')).to eq({})
      expect(auth_config('/images/REGISTRY/team/application/push', tag: 'latest')).to eq({})
      expect(auth_config('/images/create', 'fromImage' => 'other/application:latest')).to include('username' => 'hub-default', 'serveraddress' => 'index.docker.io')
    end
  end
end
