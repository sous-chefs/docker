
describe docker.version do
  its('Server.Version') { should eq '17.12.0-ce' }
end
