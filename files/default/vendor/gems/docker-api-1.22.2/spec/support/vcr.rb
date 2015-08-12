require 'vcr'
require 'webmock'
require 'docker'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.filter_sensitive_data('<DOCKER_HOST>') { Docker.url }
  c.filter_sensitive_data('<USERNAME>') { ENV['DOCKER_API_USER'] }
  c.filter_sensitive_data('<PASSWORD>') { ENV['DOCKER_API_PASS'] }
  c.filter_sensitive_data('<EMAIL>') { ENV['DOCKER_API_EMAIL'] }
  c.hook_into :excon, :webmock
  c.cassette_library_dir = File.join(File.dirname(__FILE__), '..', 'vcr')
  c.configure_rspec_metadata!
end
