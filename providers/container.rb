require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

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
  stop if running?
  remove if exists?
end

action :restart do
  restart if exists?
end

action :run do
  run unless running?
end

action :start do
  start unless running?
end

action :stop do
  stop if running?
end

action :wait do
  wait if running?
end

def exists?
  @current_resource.id
end

def remove
  rm_args = ''
  rm_args += " -link #{new_resource.link}" if new_resource.link
  shell_out("docker rm #{rm_args} #{current_resource.id}", :timeout => new_resource.cmd_timeout)
  new_resource.updated_by_last_action(true)
end

def restart
  shell_out("docker restart #{current_resource.id}", :timeout => new_resource.cmd_timeout)
  new_resource.updated_by_last_action(true)
end

def run
  # DEPRACATED support for public_port attribute and Fixnum port
  if new_resource.public_port && new_resource.port.is_a?(Fixnum)
    port = "#{new_resource.public_port}:#{new_resource.port}"
  elsif new_resource.port && new_resource.port.is_a?(Fixnum)
    port = ":#{new_resource.port}"
  else
    port = new_resource.port
  end

  run_args = ''
  run_args += " -c #{new_resource.cpu_shares}" if new_resource.cpu_shares
  run_args += " -cidfile #{new_resource.cidfile}" if new_resource.cidfile
  run_args += ' -d' if new_resource.detach
  [*new_resource.dns].each do |dns|
    run_args += " -dns #{dns}"
  end
  [*new_resource.env].each do |e|
    run_args += " -e #{e}"
  end
  run_args += " -entrypoint #{new_resource.entrypoint}" if new_resource.entrypoint
  [*new_resource.expose].each do |expose|
    run_args += " -expose #{expose}"
  end
  run_args += " -h #{new_resource.hostname}" if new_resource.hostname
  run_args += ' -i' if new_resource.stdin
  run_args += " -link #{new_resource.link}" if new_resource.link
  [*new_resource.lxc_conf].each do |lxc_conf|
    run_args += " -lxc-conf #{lxc_conf}"
  end
  run_args += " -m #{new_resource.memory}" if new_resource.memory
  run_args += " -name #{new_resource.container_name}" if new_resource.container_name
  [*port].each do |p|
    run_args += " -p #{p}"
  end
  run_args += ' -P' if new_resource.publish_exposed_ports
  run_args += ' -privileged' if new_resource.privileged
  run_args += ' -rm' if new_resource.remove_automatically
  run_args += ' -t' if new_resource.tty
  run_args += " -u #{new_resource.user}" if new_resource.user
  [*new_resource.volume].each do |v|
    run_args += " -v #{v}"
  end
  run_args += " -volumes-from #{new_resource.volumes_from}" if new_resource.volumes_from
  run_args += " -w #{new_resource.working_directory}" if new_resource.working_directory
  dr = shell_out("docker run #{run_args} #{new_resource.image} #{new_resource.command}", :timeout => new_resource.cmd_timeout)
  new_resource.id(dr.stdout.chomp)
  new_resource.updated_by_last_action(true)
end

def running?
  @current_resource.running
end

def start
  start_args = ''
  start_args += ' -a' if new_resource.attach
  start_args += ' -i' if new_resource.stdin
  shell_out("docker start #{start_args} #{current_resource.id}", :timeout => new_resource.cmd_timeout)
  new_resource.updated_by_last_action(true)
end

def stop
  stop_args = ''
  stop_args += " -t #{new_resource.cmd_timeout}"
  shell_out("docker stop #{stop_args} #{current_resource.id}", :timeout => (new_resource.cmd_timeout + 1))
  new_resource.updated_by_last_action(true)
end

def wait
  shell_out("docker wait #{current_resource.id}", :timeout => new_resource.cmd_timeout)
  new_resource.updated_by_last_action(true)
end
