# frozen_string_literal: true

control 'docker-swarm-worker-01' do
  impact 1.0
  title 'Docker Swarm worker joined the cluster'

  describe command('docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/Docker version/) }
  end

  describe command('docker info --format "{{ .Swarm.LocalNodeState }}"') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/active/) }
  end

  describe command('docker info --format "{{ .Swarm.ControlAvailable }}"') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/false/) }
  end
end
