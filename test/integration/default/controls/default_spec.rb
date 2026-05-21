# frozen_string_literal: true

control 'docker-default-01' do
  impact 1.0
  title 'Docker service is installed and responsive'

  describe docker.version do
    its('Server.Version') { should match(/^\d+\.\d+\.\d+/) }
  end

  describe command('docker info') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/environment=/) }
    its(:stdout) { should match(/foo=/) }
  end
end
