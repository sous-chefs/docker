
describe docker.version do
  its('Server.Version') { should eq '17.09.1-ce' }
end
