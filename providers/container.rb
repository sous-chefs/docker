require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include Helpers::Docker

class CommandTimeout < RuntimeError; end

def load_current_resource
  @current_resource = Chef::Resource::DockerContainer.new(new_resource)
  dps = docker_cmd('ps -a -notrunc')
  dps.stdout.each_line do |dps_line|
    next unless dps_line.include?(new_resource.image)
    next if new_resource.command && !dps_line.include?(new_resource.command)
    Chef::Log.debug('Matched docker container: ' + dps_line.squeeze(' '))
    ps = dps_line.split(/\s\s+/)
    name = ps[6] || ps[5]
    @current_resource.container_name(name)
    @current_resource.id(ps[0])
    @current_resource.running(true) if ps[4].include?('Up')
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
    if exists?
      start
    else
      run
    end
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

def cidfile
  if service?
    new_resource.cidfile || "/var/run/#{service_name}.cid"
  else
    new_resource.cidfile
  end
end

def container_name
  if service?
    new_resource.container_name || new_resource.image.gsub(/^.*\//, '')
  else
    new_resource.container_name
  end
end

def docker_cmd(cmd, timeout = new_resource.cmd_timeout)
  Chef::Log.debug('Executing: docker ' + cmd)
  begin
    shell_out('docker ' + cmd, :timeout => timeout)
  rescue Mixlib::ShellOut::CommandTimeout
    raise CommandTimeout, <<-EOM

Docker command timed out:
docker #{cmd}

Please adjust node container_cmd_timeout attribute or this docker_container cmd_timeout attribute if necessary.
EOM
  end
end

def exists?
  @current_resource.id
end

def port
  # DEPRECATED support for public_port attribute and Fixnum port
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
  service_remove if service?
end

def restart
  if service?
    service_restart
  else
    shell_out("docker restart #{current_resource.id}", :timeout => new_resource.cmd_timeout)
  end
end

def run
  run_args = cli_args(
    'c' => new_resource.cpu_shares,
    'cidfile' => cidfile,
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
    'name' => container_name,
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
  dr = docker_cmd("run #{run_args} #{new_resource.image} #{new_resource.command}")
  dr.error!
  new_resource.id(dr.stdout.chomp)
  service_create if service?
end

def running?
  @current_resource.running
end

def service?
  new_resource.init_type
end

def service_action(actions)
  service service_name do
    case new_resource.init_type
    when 'systemd'
      provider Chef::Provider::Service::Systemd
    when 'upstart'
      provider Chef::Provider::Service::Upstart
    end
    supports :status => true, :restart => true, :reload => true
    action actions
  end
end

def service_create
  case new_resource.init_type
  when 'systemd'
    service_create_systemd
  when 'sysv'
    service_create_sysv
  when 'upstart'
    service_create_upstart
  end
end

def service_create_systemd
  template "/usr/lib/systemd/system/#{service_name}.socket" do
    if new_resource.socket_template.nil?
      source 'docker-container.socket.erb'
    else
      source new_resource.socket_template
    end
    cookbook new_resource.cookbook
    mode '0644'
    owner 'root'
    group 'root'
    variables(
      :service_name => service_name,
      :sockets => sockets
    )
    not_if port.empty?
  end

  template "/usr/lib/systemd/system/#{service_name}.service" do
    source service_template
    cookbook new_resource.cookbook
    mode '0644'
    owner 'root'
    group 'root'
    variables(
      :cmd_timeout => new_resource.cmd_timeout,
      :service_name => service_name
    )
  end

  service_action([:start, :enable])
end

def service_create_sysv
  template "/etc/init.d/#{service_name}" do
    source service_template
    cookbook new_resource.cookbook
    mode '0755'
    owner 'root'
    group 'root'
    variables(
      :cmd_timeout => new_resource.cmd_timeout,
      :service_name => service_name
    )
  end

  service_action([:start, :enable])
end

def service_create_upstart
  # The upstart init script requires inotifywait, which is in inotify-tools
  package 'inotify-tools'

  template "/etc/init/#{service_name}.conf" do
    source service_template
    cookbook new_resource.cookbook
    mode '0600'
    owner 'root'
    group 'root'
    variables(
      :cmd_timeout => new_resource.cmd_timeout,
      :service_name => service_name
    )
  end

  service_action([:start, :enable])
end

def service_name
  container_name
end

def service_remove
  case new_resource.init_type
  when 'systemd'
    service_remove_systemd
  when 'sysv'
    service_remove_sysv
  when 'upstart'
    service_remove_upstart
  end
end

def service_remove_systemd
  service_action([:stop, :disable])

  %w{service socket}.each do |f|
    file "/usr/lib/systemd/system/#{service_name}.#{f}" do
      action :delete
    end
  end
end

def service_remove_sysv
  service_action([:stop, :disable])

  file "/etc/init.d/#{service_name}" do
    action :delete
  end
end

def service_remove_upstart
  service_action([:stop, :disable])

  file "/etc/init/#{service_name}" do
    action :delete
  end
end

def service_restart
  service_action([:restart])
end

def service_start
  service_action([:start])
end

def service_stop
  service_action([:stop])
end

def service_template
  return new_resource.init_template unless new_resource.init_template.nil?
  case new_resource.init_type
  when 'systemd'
    'docker-container.service.erb'
  when 'upstart'
    'docker-container.conf.erb'
  when 'sysv'
    'docker-container.sysv.erb'
  end
end

def sockets
  return [] if port.empty?
  [*port].map { |p| p.gsub!(/.*:/, '') }
end

def start
  start_args = cli_args(
    'a' => new_resource.attach,
    'i' => new_resource.stdin
  )
  if service?
    service_create
  else
    docker_cmd("start #{start_args} #{current_resource.id}")
  end
end

def stop
  stop_args = cli_args(
    't' => new_resource.cmd_timeout
  )
  if service?
    service_stop
  else
    docker_cmd("stop #{stop_args} #{current_resource.id}", (new_resource.cmd_timeout + 15))
  end
end

def wait
  docker_cmd("wait #{current_resource.id}")
end
