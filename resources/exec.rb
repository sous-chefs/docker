unified_mode true
use 'partial/_base'

property :host, [String, nil], default: lazy { ENV['DOCKER_HOST'] }, desired_state: false
property :command, Array
property :container, String
property :timeout, Numeric, default: 60, desired_state: false
property :container_obj, Docker::Container, desired_state: false
property :returns, [ Integer, Array ], coerce: proc { |v| Array(v) }, default: [0],
  description: 'The return value for a command. This may be an array of accepted values. An exception is raised when the return value(s) do not match.'

alias_method :cmd, :command

action :run do
  converge_by "executing #{new_resource.command} on #{new_resource.container}" do
    with_retries { new_resource.container_obj Docker::Container.get(new_resource.container, {}, connection) }
    stdout, stderr, exit_code = new_resource.container_obj.exec(new_resource.command, wait: new_resource.timeout)
    Chef::Log.trace(stdout)
    Chef::Log.trace(stderr)
    unless new_resource.returns.include?(exit_code)
      raise "Expected process to exit with 0, but received #{exit_code}"
    end
  end
end
