# frozen_string_literal: true

control 'docker-registry-01' do
  impact 1.0
  title 'Private registry containers are running'

  describe command('docker ps --format "{{.Names}}"') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/^registry_service$/) }
    its(:stdout) { should match(/^registry_proxy$/) }
  end

  describe port(5043) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
  end

  describe command('curl --silent --show-error --fail --insecure --user testuser:testpassword https://127.0.0.1:5043/v2/') do
    its(:exit_status) { should eq 0 }
  end
end
