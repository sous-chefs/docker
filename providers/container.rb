include Docker::Helpers

def load_current_resource
  @current_resource = Chef::Resource::DockerContainer.new(new_resource.name)
  wait_until_ready!
  docker_containers.each do |ps|
    next unless container_matches?(ps)
    Chef::Log.debug('Matched docker container: ' + ps['line'].squeeze(' '))
    @current_resource.container_name(ps['names'])
    @current_resource.created(ps['created'])
    @current_resource.id(ps['id'])
    @current_resource.status(ps['status'])
    break
  end
  @current_resource
end

def initialize(new_resource, run_context)
  super
  @service = service_init if service?
end

action :commit do
  if exists?
    commit
    new_resource.updated_by_last_action(true)
  end
end

action :cp do
  if exists?
    cp
    new_resource.updated_by_last_action(true)
  end
end

action :create do
  unless running? || exists?
    create
    new_resource.updated_by_last_action(true)
  end
end

action :export do
  if exists?
    export
    new_resource.updated_by_last_action(true)
  end
end

action :kill do
  if running?
    kill
    new_resource.updated_by_last_action(true)
  end
end

action :redeploy do
  stop if (previously_running = running?)
  remove_container if exists?
  if previously_running
    run
  else
    create
  end
  new_resource.updated_by_last_action(true)
end

action :remove do
  if running?
    stop
    new_resource.updated_by_last_action(true)
    sleep 1
  end
  if exists?
    remove
    new_resource.updated_by_last_action(true)
  end
end

action :remove_link do
  new_resource.updated_by_last_action(remove_link)
end

action :remove_volume do
  new_resource.updated_by_last_action(remove_volume)
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

def commit
  commit_args = cli_args(
    'author' => new_resource.author,
    'message' => new_resource.message,
    'run' => new_resource.run
  )
  commit_end_args = ''
  if new_resource.repository
    commit_end_args = new_resource.repository
    commit_end_args += ":#{new_resource.tag}" if new_resource.tag
  end
  docker_cmd!("commit #{commit_args} #{current_resource.id} #{commit_end_args}")
end

def container_matches?(ps)
  return true if container_id_matches?(ps['id'])
  return true if container_name_matches?(ps['names'])
  return false unless container_image_matches?(ps['image'])
  return false unless container_command_matches_if_exists?(ps['command'])
  return false unless container_name_matches_if_exists?(ps['names'])
  true
end

def container_command_matches_if_exists?(command)
  if new_resource.command
    # try the exact command but also the command with the ' and " stripped out, since docker will
    # sometimes strip out quotes.
    subcommand = new_resource.command.gsub(/['"]/, '')
    command.include?(new_resource.command) || command.include?(subcommand)
  else
    true
  end
end

def container_id_matches?(id)
  return false unless id && new_resource.id
  id.start_with?(new_resource.id)
end

def container_image_matches?(image)
  return false unless image && new_resource.image
  image.include?(new_resource.image)
end

def container_name_matches?(names)
  return false unless names
  new_resource.container_name && names.split(',').include?(new_resource.container_name)
end

def container_name_matches_if_exists?(names)
  return container_name_matches?(names) if new_resource.container_name
  true
end

def container_name
  if service?
    new_resource.container_name || new_resource.image.gsub(%r{^.*/}, '')
  else
    new_resource.container_name
  end
end

def cp
  docker_cmd!("cp #{current_resource.id}:#{new_resource.source} #{new_resource.destination}")
end

def create
  create_args = cli_args(
    run_cli_args.reject { |arg, _| arg == 'detach' }
  )
  dc = docker_cmd!("create #{create_args} #{new_resource.image} #{new_resource.command}")
  dc.error!
  new_resource.id(dc.stdout.chomp)
  service_create if service?
end

# Helper method for `docker_containers` that looks at the position of the headers in the output of
# `docker ps` to figure out the span of the data for each column within a row. This information is
# stored in the `ranges` hash, which is returned at the end.
def get_ranges(header)
  container_id_index = 0
  image_index = header.index('IMAGE')
  command_index = header.index('COMMAND')
  created_index = header.index('CREATED')
  status_index = header.index('STATUS')
  ports_index = header.index('PORTS')
  names_index = header.index('NAMES')

  ranges = {
    id: [container_id_index, image_index],
    image: [image_index, command_index],
    command: [command_index, created_index],
    created: [created_index, status_index]
  }
  if ports_index > 0
    ranges[:status] = [status_index, ports_index]
    ranges[:ports] = [ports_index, names_index]
  else
    ranges[:status] = [status_index, names_index]
  end
  ranges[:names] = [names_index]
  ranges
end

#
# Get a list of all docker containers by parsing the output of `docker ps -a --no-trunc`.
#
# Uses `get_ranges` to determine where column data is within each row. Then, for each line after
# the header, a hash is build up with the values for each of the columns. A special 'line' entry
# is added to the hash for the raw line of the row.
#
# The array of hashes is returned.
def docker_containers
  dps = docker_cmd!('ps -a --no-trunc')

  lines = dps.stdout.lines.to_a
  ranges = get_ranges(lines[0])

  lines[1, lines.length].map do |line|
    ps = { 'line' => line }
    [:id, :image, :command, :created, :status, :ports, :names].each do |name|
      next unless ranges.key?(name)
      start = ranges[name][0]
      if ranges[name].length == 2
        finish = ranges[name][1]
      else
        finish = line.length
      end
      ps[name.to_s] = line[start..finish - 1].strip
    end
    # Filter out technical names (eg. 'my-app/db'), which appear in ps['names']
    # when a container has at least another container linking to it. If these
    # names are not filtered they will pollute current_resource.container_name.
    ps['names'] = ps['names'].split(',').grep(%r{\A[^\/]+\Z}).join(',') # technical names always contain a '/'
    ps
  end
end

def command_timeout_error_message(cmd)
  <<-EOM

Command timed out:
#{cmd}

Please adjust node container_cmd_timeout attribute or this docker_container cmd_timeout attribute if necessary.
EOM
end

def exists?
  @current_resource.id
end

def export
  docker_cmd!("export #{current_resource.id} > #{new_resource.destination}")
end

def kill
  if service?
    service_stop
  else
    kill_args = cli_args(
      'signal' => new_resource.signal
    )
    docker_cmd!("kill #{kill_args} #{current_resource.id}")
  end
end

def port
  # DEPRECATED support for public_port attribute and Fixnum port
  if new_resource.public_port && new_resource.port.is_a?(Fixnum)
    "#{new_resource.public_port}:#{new_resource.port}"
  elsif new_resource.port && new_resource.port.is_a?(Fixnum)
    ":#{new_resource.port}"
  else
    new_resource.port || []
  end
end

def remove
  remove_container
  service_remove if service?
end

def remove_container
  rm_args = cli_args(
    'force' => new_resource.force
  )
  docker_cmd!("rm #{rm_args} #{current_resource.id}")
  remove_cidfile if new_resource.cidfile
end

def remove_cidfile
  # run at compile-time to ensure cidfile is gone before running docker_cmd()
  file new_resource.cidfile do
    action :nothing
  end.run_action(:delete)
end

def remove_link
  return false if new_resource.link.nil? || new_resource.link.empty?
  rm_args = cli_args(
    'link' => true
  )
  link_args = Array(new_resource.link).map do |link|
    container_name + '/' + link
  end
  docker_cmd!("rm #{rm_args} #{link_args.join(' ')}")
end

def remove_volume
  return false if new_resource.volume.nil? || new_resource.volume.empty?
  rm_args = cli_args(
    'volume' => Array(new_resource.volume)
  )
  docker_cmd!("rm #{rm_args} #{current_resource.id}")
end

def restart
  if service?
    service_restart
  else
    docker_cmd!("restart #{current_resource.id}")
  end
end

def run
  run_args = cli_args(run_cli_args)
  dr = docker_cmd!("run #{run_args} #{new_resource.image}:#{new_resource.tag} #{new_resource.command}")
  dr.error!
  new_resource.id(dr.stdout.chomp)
  service_run if service?
end

# rubocop:disable MethodLength
def run_cli_args
  {
    'add-host' => Array(new_resource.additional_host),
    'cap-add' => Array(new_resource.cap_add),
    'cpu-shares' => new_resource.cpu_shares,
    'cidfile' => new_resource.cidfile,
    'detach' => new_resource.detach,
    'device' => Array(new_resource.device),
    'dns' => Array(new_resource.dns),
    'dns-search' => Array(new_resource.dns_search),
    'env' => Array(new_resource.env),
    'env-file' => new_resource.env_file,
    'entrypoint' => new_resource.entrypoint,
    'expose' => Array(new_resource.expose),
    'hostname' => new_resource.hostname,
    'interactive' => new_resource.stdin,
    'label' => new_resource.label,
    'link' => Array(new_resource.link),
    'lxc-conf' => Array(new_resource.lxc_conf),
    'memory' => new_resource.memory,
    'net' => new_resource.net,
    'networking' => new_resource.networking,
    'name' => container_name,
    'opt' => Array(new_resource.opt),
    'publish' => Array(port),
    'publish-all' => new_resource.publish_exposed_ports,
    'privileged' => new_resource.privileged,
    'rm' => new_resource.remove_automatically,
    'restart' => new_resource.restart,
    'tty' => new_resource.tty,
    'ulimit' => Array(new_resource.ulimit),
    'user' => new_resource.user,
    'volume' => Array(new_resource.volume),
    'volumes-from' => new_resource.volumes_from,
    'workdir' => new_resource.working_directory
  }
end
# rubocop:enable MethodLength

def running?
  @current_resource.status.include?('Up') if @current_resource.status
end

def service?
  new_resource.init_type
end

def service_init
  service_create

  if new_resource.init_type == 'runit'
    runit_service service_name do
      run_template_name 'docker-container'
      finish_script_template_name 'docker-container'
      supports restart: true, reload: true, status: true, stop: true
      action :nothing
      finish true
      restart_on_update false
    end
  else
    service service_name do
      case new_resource.init_type
      when 'systemd'
        provider Chef::Provider::Service::Systemd
      when 'upstart'
        provider Chef::Provider::Service::Upstart
      end
      supports restart: true, reload: true, status: true
      action :nothing
    end
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

def service_run
  case new_resource.init_type
  when 'runit'
    service_create_runit
  else
    service_start_and_enable
  end
end

def service_create_runit
  runit_service service_name do
    cookbook new_resource.cookbook
    default_logger true
    options(
      'service_name' => service_name
    )
    run_template_name service_template
    action :nothing
  end.run_action(:enable)
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
      service_name: service_name,
      sockets: sockets
    )
    not_if { port.empty? }
    action :nothing
  end.run_action(:create)

  template "/usr/lib/systemd/system/#{service_name}.service" do
    source service_template
    cookbook new_resource.cookbook
    mode '0644'
    owner 'root'
    group 'root'
    variables(
      cmd_timeout: new_resource.cmd_timeout,
      service_name: service_name
    )
    action :nothing
  end.run_action(:create)
end

def service_create_sysv
  template "/etc/init.d/#{service_name}" do
    source service_template
    cookbook new_resource.cookbook
    mode '0755'
    owner 'root'
    group 'root'
    variables(
      cmd_timeout: new_resource.cmd_timeout,
      service_name: service_name
    )
    action :nothing
  end.run_action(:create)

  # link "/etc/rc.d/init.d/#{service_name}" do
  #   to "/etc/init.d/#{service_name}"
  #   only_if { platform_family?('rhel') }
  #   action :nothing
  # end.run_action(:create)
end

def service_create_upstart
  # The upstart init script requires inotifywait, which is in inotify-tools
  # For clarity, install the package here but do it only once (no CHEF-3694).
  begin
    run_context.resource_collection.find(package: 'inotify-tools')
    # If we get here then we already installed the resource the first time.
  rescue Chef::Exceptions::ResourceNotFound
    package('inotify-tools') do
      action :nothing
    end.run_action(:install)
  end

  template "/etc/init/#{service_name}.conf" do
    source service_template
    cookbook new_resource.cookbook
    mode '0600'
    owner 'root'
    group 'root'
    variables(
      cmd_timeout: new_resource.cmd_timeout,
      service_name: service_name
    )
    action :nothing
  end.run_action(:create)
end

def service_name
  container_name
end

def service_remove
  case new_resource.init_type
  when 'runit'
    service_remove_runit
  when 'systemd'
    service_remove_systemd
  when 'sysv'
    service_remove_sysv
  when 'upstart'
    service_remove_upstart
  end
end

def service_remove_runit
  runit_service service_name do
    action :disable
  end
end

def service_remove_systemd
  service_stop_and_disable

  %w(service socket).each do |f|
    file "/usr/lib/systemd/system/#{service_name}.#{f}" do
      action :delete
    end
  end
end

def service_remove_sysv
  service_stop_and_disable

  file "/etc/init.d/#{service_name}" do
    action :delete
  end
end

def service_remove_upstart
  service_stop_and_disable

  file "/etc/init/#{service_name}.conf" do
    action :delete
  end
end

def service_restart
  @service.run_action(:restart)
end

def service_start
  @service.run_action(:start)
end

def service_stop
  @service.run_action(:stop)
end

def service_start_and_enable
  @service.run_action(:enable)
  @service.run_action(:start)
end

def service_stop_and_disable
  @service.run_action(:stop)
  @service.run_action(:disable)
end

def service_template
  return new_resource.init_template unless new_resource.init_template.nil?
  case new_resource.init_type
  when 'runit'
    'docker-container'
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
  [*port].map { |p| p.gsub(/.*:/, '') }
end

def start
  start_args = cli_args(
    'attach' => new_resource.attach,
    'interactive' => new_resource.stdin
  )
  if service?
    service_create
    service_run
  else
    docker_cmd!("start #{start_args} #{current_resource.id}")
  end
end

def stop
  stop_args = cli_args(
    'time' => new_resource.cmd_timeout
  )
  if service?
    service_stop
  else
    docker_cmd!("stop #{stop_args} #{current_resource.id}", (new_resource.cmd_timeout + 30))
  end
end

def wait
  docker_cmd!("wait #{current_resource.id}")
end
