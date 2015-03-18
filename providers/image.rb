include Docker::Helpers

def load_current_resource
  wait_until_ready!
  @current_resource = Chef::Resource::DockerImage.new(new_resource.name)
  dimages = docker_cmd('images -a --no-trunc')
  if dimages.stdout.include?(new_resource.image_name)
    dimages.stdout.each_line do |di_line|
      image = di(di_line)
      next unless image_name_matches?(image['repository'])
      next unless image_tag_matches_if_exists?(image['tag'])
      Chef::Log.debug('Matched docker image: ' + di_line.squeeze(' '))
      @current_resource.created(image['created'])
      @current_resource.repository(image['repository'])
      @current_resource.tag(image['tag'])
      @current_resource.id(image['id'])
      @current_resource.virtual_size(image['virtual_size'])
      break
    end
  end
  @current_resource
end

action :build do
  build
  new_resource.updated_by_last_action(true)
end

action :build_if_missing do
  unless installed?
    build
    new_resource.updated_by_last_action(true)
  end
end

action :import do
  unless installed?
    import
    new_resource.updated_by_last_action(true)
  end
end

# DEPRECATED: Deprecated as of Docker 0.10.0
action :insert do
  Chef::Log.warn('Using DEPRECATED (as of Docker 0.10.0) insert action in docker_image. Please update your workflow and cookbook.')
  if installed?
    insert
    new_resource.updated_by_last_action(true)
  end
end

action :load do
  unless installed?
    load
    new_resource.updated_by_last_action(true)
  end
end

action :pull_if_missing do
  unless installed?
    pull
    new_resource.updated_by_last_action(true)
  end
end

action :pull do
  old_hash = docker_inspect_id(registry_image_and_tag_arg)
  pull
  new_hash = docker_inspect_id(registry_image_and_tag_arg)
  new_resource.updated_by_last_action(new_hash != old_hash)
end

action :push do
  if installed?
    push
    new_resource.updated_by_last_action(true)
  end
end

action :remove do
  if installed?
    remove
    new_resource.updated_by_last_action(true)
  end
end

action :save do
  if installed?
    save
    new_resource.updated_by_last_action(true)
  end
end

action :tag do
  if installed?
    tag
    new_resource.updated_by_last_action(true)
  end
end

def build
  full_image_name = new_resource.image_name
  full_image_name += ":#{new_resource.tag}" if new_resource.tag

  build_args = cli_args(
    'no-cache' => new_resource.no_cache,
    'rm' => new_resource.rm,
    'tag' => full_image_name
  )

  # DEPRECATED: support for dockerfile, image_url, and path attributes
  if new_resource.dockerfile
    Chef::Log.warn('Using DEPRECATED dockerfile attribute in docker_image. Please use source attribute instead.')
    command = "- < #{new_resource.dockerfile}"
  elsif new_resource.path
    Chef::Log.warn('Using DEPRECATED path attribute in docker_image. Please use source attribute instead.')
    command = new_resource.path
  elsif new_resource.image_url
    Chef::Log.warn('Using DEPRECATED image_url attribute in docker_image. Please use source attribute instead.')
    command = new_resource.image_url
  elsif ::File.file?(new_resource.source)
    command = "- < #{new_resource.source}"
  else
    command = new_resource.source
  end

  docker_cmd!("build #{build_args} #{command}")
end

def di(di_line)
  split_line = di_line.split(/\s\s+/)
  image = {}
  image['repository'] = split_line[0]
  image['tag'] = split_line[1]
  image['id'] = split_line[2]
  image['created'] = split_line[3]
  image['virtual_size'] = split_line[4]
  image
end

def command_timeout_error_message(cmd)
  <<-EOM

Command timed out:
#{cmd}

Please adjust node image_cmd_timeout attribute or this docker_image cmd_timeout attribute if necessary.
EOM
end

def image_and_tag_arg
  docker_cmd_args = new_resource.image_name
  docker_cmd_args += ":#{new_resource.tag}" if new_resource.tag
  docker_cmd_args
end

def image_id_matches?(id)
  return false unless id && new_resource.id
  id.start_with?(new_resource.id)
end

def image_name_matches?(name)
  return false unless name && new_resource.image_name
  name.include?(new_resource.image_name)
end

def image_tag_matches_if_exists?(tag)
  return false if new_resource.tag && new_resource.tag != tag
  true
end

def import
  if ::File.file?(new_resource.source)
    execute_cmd("cat #{new_resource.source} | docker import - #{repository_and_tag_args}")
  elsif ::File.directory?(new_resource.source)
    execute_cmd("tar -c #{new_resource.source} | docker import - #{repository_and_tag_args}")
  else
    import_args = ''
    if new_resource.image_url
      Chef::Log.warn('Using DEPRECATED image_url attribute in docker_image. Please use source attribute instead.')
      import_args += new_resource.image_url
      import_args += " #{new_resource.image_name}"
    elsif new_resource.source
      import_args += new_resource.source
      import_args += " #{new_resource.image_name}"
    end
    docker_cmd!("import #{import_args} #{repository_and_tag_args}")
  end
end

# DEPRECATED: Deprecated as of Docker 0.10.0
def insert
  Chef::Log.warn('Using DEPRECATED (as of Docker 0.10.0) insert command in docker_image. Please update your workflow and cookbook.')
  docker_cmd!("insert #{new_resource.image_name} #{new_resource.source} #{new_resource.destination}")
end

def installed?
  @current_resource.id
end

def load
  if new_resource.input
    load_args = cli_args(
      'input' => new_resource.input
    )
    docker_cmd!("load #{load_args}")
  else
    docker_cmd!("load < #{new_resource.source}")
  end
end

def pull
  docker_cmd!("pull #{registry_image_and_tag_arg}")
end

def push
  docker_cmd!("push #{registry_image_and_tag_arg}")
end

def registry_image_and_tag_arg
  docker_cmd_args = ''
  docker_cmd_args += "#{new_resource.registry}/" if new_resource.registry
  docker_cmd_args += image_and_tag_arg
  docker_cmd_args
end

def remove
  remove_args = cli_args(
    'force' => new_resource.force,
    'no-prune' => new_resource.no_prune
  )
  image_name = new_resource.image_name
  image_name = "#{image_name}:#{new_resource.tag}" if new_resource.tag
  docker_cmd!("rmi #{remove_args} #{image_name}")
end

def repository_and_tag_args
  docker_cmd_args = ''
  if new_resource.repository
    docker_cmd_args = new_resource.repository
    docker_cmd_args += ":#{new_resource.tag}" if new_resource.tag
  end
  docker_cmd_args
end

def save
  image_name = new_resource.image_name
  image_name = "#{image_name}:#{new_resource.tag}" if new_resource.tag
  if new_resource.output
    save_args = cli_args(
      'output' => new_resource.output
    )
    docker_cmd!("save #{save_args} #{image_name}")
  else
    docker_cmd!("save #{image_name} > #{new_resource.destination}")
  end
end

def tag
  tag_args = cli_args(
    'force' => new_resource.force
  )
  docker_cmd!("tag #{tag_args} #{new_resource.image_name} #{repository_and_tag_args}")
end
