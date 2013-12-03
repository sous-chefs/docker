require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include Helpers::Docker

def load_current_resource
  @current_resource = Chef::Resource::DockerContainer.new(new_resource)
  dps = shell_out('docker ps -a -notrunc', :timeout => new_resource.cmd_timeout)
  dps.stdout.each_line do |dps_line|
    next unless dps_line.include?(new_resource.image)
    next if new_resource.command && !dps_line.include?(new_resource.command)
    container_ps = dps_line.split(/\s\s+/)
    container_name = container_ps[6] || container_ps[5]
    @current_resource.container_name(container_name)
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
  dr = shell_out("docker run #{run_args} #{new_resource.image} #{new_resource.command}", :timeout => new_resource.cmd_timeout)
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
    source 'docker-container.socket.erb'
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
    source 'docker-container.service.erb'
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
    source 'docker-container.sysv.erb'
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
  template "/etc/init/#{service_name}.conf" do
    source 'docker-container.conf.erb'
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
    shell_out("docker start #{start_args} #{current_resource.id}", :timeout => new_resource.cmd_timeout)
  end
end

def stop
  stop_args = cli_args(
    't' => new_resource.cmd_timeout
  )
  if service?
    service_stop
  else
    shell_out("docker stop #{stop_args} #{current_resource.id}", :timeout => (new_resource.cmd_timeout + 15))
  end
end

def wait
  shell_out("docker wait #{current_resource.id}", :timeout => new_resource.cmd_timeout)
end
