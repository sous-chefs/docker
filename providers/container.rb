require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include Helpers::Docker

def load_current_resource
  @current_resource = Chef::Resource::DockerContainer.new(new_resource)
  dps = shell_out('docker ps -a -notrunc', :timeout => new_resource.cmd_timeout)
  dps.stdout.each_line do |dps_line|
    next unless dps_line.include?(new_resource.image) && dps_line.include?(new_resource.command)
    container_ps = dps_line.split(/\s\s+/)
    @current_resource.id(container_ps[0])
    @current_resource.running(true) if container_ps[4].include?('Up')
    break
  end
  @current_resource
end

action :remove do
  if running?
    stop
    new_resource.updated_by_last_action(true)
  end
  if exists?
    remove
    new_resource.updated_by_last_action(true)
  end
end

action :restart do
  if exists?
    restart
    new_resource.updated_by_last_action(true)
  end
end

action :run do
  unless running?
    run
    new_resource.updated_by_last_action(true)
  end
end

action :start do
  unless running?
    start
    new_resource.updated_by_last_action(true)
  end
end

action :stop do
  if running?
    stop
    new_resource.updated_by_last_action(true)
  end
end

action :wait do
  if running?
    wait
    new_resource.updated_by_last_action(true)
  end
end

def exists?
  @current_resource.id
end

def port
  # DEPRACATED support for public_port attribute and Fixnum port
  if new_resource.public_port && new_resource.port.is_a?(Fixnum)
    "#{new_resource.public_port}:#{new_resource.port}"
  elsif new_resource.port && new_resource.port.is_a?(Fixnum)
    ":#{new_resource.port}"
  else
    new_resource.port
  end
end

def remove
  rm_args = cli_args(
    'link' => new_resource.link
  )
  shell_out("docker rm #{rm_args} #{current_resource.id}", :timeout => new_resource.cmd_timeout)
end

def restart
  shell_out("docker restart #{current_resource.id}", :timeout => new_resource.cmd_timeout)
end

def run
  run_args = cli_args(
    'c' => new_resource.cpu_shares,
    'cidfile' => new_resource.cidfile,
    'd' => new_resource.detach,
    'dns' => [*new_resource.dns],
    'e' => [*new_resource.env],
    'entrypoint' => new_resource.entrypoint,
    'expose' => [*new_resource.expose],
    'h' => new_resource.hostname,
    'i' => new_resource.stdin,
    'link' => new_resource.link,
    'lxc-conf' => [*new_resource.lxc_conf],
    'm' => new_resource.memory,
    'name' => new_resource.container_name,
    'p' => [*port],
    'P' => new_resource.publish_exposed_ports,
    'privileged' => new_resource.privileged,
    'rm' => new_resource.remove_automatically,
    't' => new_resource.tty,
    'u' => new_resource.user,
    'v' => [*new_resource.volume],
    'volumes-from' => new_resource.volumes_from,
    'w' => new_resource.working_directory
  )
  dr = shell_out("docker run #{run_args} #{new_resource.image} #{new_resource.command}", :timeout => new_resource.cmd_timeout)
  new_resource.id(dr.stdout.chomp)
end

def running?
  @current_resource.running
end

def start
  start_args = cli_args(
    'a' => new_resource.attach,
    'i' => new_resource.stdin
  )
  shell_out("docker start #{start_args} #{current_resource.id}", :timeout => new_resource.cmd_timeout)
end

def stop
  stop_args = cli_args(
    't' => new_resource.cmd_timeout
  )
  shell_out("docker stop #{stop_args} #{current_resource.id}", :timeout => (new_resource.cmd_timeout + 1))
end

def wait
  shell_out("docker wait #{current_resource.id}", :timeout => new_resource.cmd_timeout)
end
