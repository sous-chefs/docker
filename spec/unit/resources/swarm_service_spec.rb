require 'spec_helper'

describe 'docker_swarm_service' do
  step_into :docker_swarm_service
  platform 'ubuntu'

  context 'when creating a service' do
    recipe do
      docker_swarm_service 'nginx' do
        image 'nginx:latest'
        replicas 2
        ports %w(80:80)
      end
    end

    before do
      # Mock swarm member check
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker info --format "{{ .Swarm.LocalNodeState }}"').and_return(
        double(error?: false, stdout: "active\n")
      )

      # Mock swarm manager check
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker info --format "{{ .Swarm.ControlAvailable }}"').and_return(
        double(error?: false, stdout: "true\n")
      )

      # Mock service inspection
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker service inspect nginx').and_return(
        double(error?: true, stdout: '', stderr: 'Error: no such service: nginx')
      )

      # Stub provider shell_out commands
      stubs_for_provider('docker_swarm_service[nginx]') do |provider|
        allow(provider).to receive(:shell_out!).with('docker service create --name nginx --replicas 2 --publish 80:80 --restart-condition any nginx:latest')
      end
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates the service' do
      stubs_for_provider('docker_swarm_service[nginx]') do |provider|
        expect(provider).to receive(:shell_out!).with('docker service create --name nginx --replicas 2 --publish 80:80 --restart-condition any nginx:latest')
      end
      chef_run
    end
  end

  context 'when updating a service' do
    recipe do
      docker_swarm_service 'nginx' do
        image 'nginx:1.19'
        replicas 3
        action :update
      end
    end

    before do
      # Mock swarm member check
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker info --format "{{ .Swarm.LocalNodeState }}"').and_return(
        double(error?: false, stdout: "active\n")
      )

      # Mock swarm manager check
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker info --format "{{ .Swarm.ControlAvailable }}"').and_return(
        double(error?: false, stdout: "true\n")
      )

      # Mock service inspection with more detailed response
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker service inspect nginx').and_return(
        double(
          error?: false,
          stdout: '[{"ID":"abcd1234","Version":{"Index":1234},"CreatedAt":"2024-01-01T00:00:00Z","UpdatedAt":"2024-01-01T00:00:00Z","Spec":{"Name":"nginx","TaskTemplate":{"ContainerSpec":{"Image":"nginx:latest","Command":null,"Args":null,"Env":null},"Resources":{},"RestartPolicy":{"Condition":"any"},"Placement":{}},"Mode":{"Replicated":{"Replicas":2}},"UpdateConfig":{"Parallelism":1,"FailureAction":"pause"},"EndpointSpec":{"Mode":"vip","Ports":[{"Protocol":"tcp","TargetPort":80,"PublishedPort":80}]}}}]'
        )
      )

      # Stub provider shell_out commands
      stubs_for_provider('docker_swarm_service[nginx]') do |provider|
        allow(provider).to receive(:shell_out!).with('docker service update --image nginx:1.19 --replicas 3 nginx')
      end
    end

    it 'updates the service' do
      stubs_for_provider('docker_swarm_service[nginx]') do |provider|
        expect(provider).to receive(:shell_out!).with('docker service update --image nginx:1.19 --replicas 3 nginx')
      end
      chef_run
    end
  end

  context 'when not a swarm manager' do
    recipe do
      docker_swarm_service 'nginx' do
        image 'nginx:latest'
      end
    end

    before do
      # Mock swarm member check
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker info --format "{{ .Swarm.LocalNodeState }}"').and_return(
        double(error?: false, stdout: "active\n")
      )

      # Mock swarm manager check
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker info --format "{{ .Swarm.ControlAvailable }}"').and_return(
        double(error?: false, stdout: "false\n")
      )

      # Mock service inspection
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('docker service inspect nginx').and_return(
        double(error?: true, stdout: '', stderr: 'Error: no such service: nginx')
      )
    end

    it 'does not create the service' do
      stubs_for_provider('docker_swarm_service[nginx]') do |provider|
        expect(provider).not_to receive(:shell_out!).with(/docker service create/)
      end
      chef_run
    end
  end
end
