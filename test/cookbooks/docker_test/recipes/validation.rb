# a list of things you should not be able to do.
# tested with rspec

docker_service 'script_and_version' do
  install_method 'script'
  version '1.2.3'
end
