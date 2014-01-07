require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include Helpers::Docker

class CommandTimeout < RuntimeError; end

def load_current_resource
  @current_resource = Chef::Resource::DockerImage.new(new_resource)
  di = docker_cmd('images -a')
  if di.stdout.include?(new_resource.image_name)
    di.stdout.each_line do |di_line|
      next unless di_line.include?(new_resource.image_name)
      image_info = di_line.split(/\s\s+/)
      @current_resource.installed(true)
      @current_resource.repository(image_info[0])
      @current_resource.installed_tag(image_info[1])
      @current_resource.id(image_info[2])
      break
    end
  end
  @current_resource
end

action :build do
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

action :insert do
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

action :pull do
  unless installed?
    pull
    new_resource.updated_by_last_action(true)
  end
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
  elsif File.file?(new_resource.source)
    command = "- < #{new_resource.source}"
  else
    command = new_resource.source
  end

  docker_cmd("build -t #{full_image_name} #{command}")
end

def docker_cmd(cmd, timeout = new_resource.cmd_timeout)
  execute_cmd('docker ' + cmd, timeout)
end

def execute_cmd(cmd, timeout = new_resource.cmd_timeout)
  Chef::Log.debug('Executing: ' + cmd)
  begin
    shell_out(cmd, :timeout => timeout)
  rescue Mixlib::ShellOut::CommandTimeout
    raise CommandTimeout, <<-EOM

Command timed out:
#{cmd}

Please adjust node image_cmd_timeout attribute or this docker_image cmd_timeout attribute if necessary.
EOM
  end
end

def import
  if File.file?(new_resource.source)
    execute_cmd("cat #{new_resource.source} | docker import - #{repository_and_tag_args}")
  elsif File.directory?(new_resource.source)
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
    docker_cmd("import #{import_args} #{repository_and_tag_args}")
  end
end

def insert
  docker_cmd("insert #{new_resource.image_name} #{new_resource.source} #{new_resource.destination}")
end

def installed?
  @current_resource.installed && tag_match
end

def load
  docker_cmd("load < #{new_resource.source}")
end

def pull
  pull_args = cli_args(
    'registry' => new_resource.registry,
    't' => new_resource.tag
  )
  docker_cmd("pull #{new_resource.image_name} #{pull_args}")
end

def push
  docker_cmd("push #{new_resource.image_name}")
end

def remove
  docker_cmd("rmi #{new_resource.image_name}")
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
  docker_cmd("save #{new_resource.image_name} > #{new_resource.destination}")
end

def tag
  tag_args = cli_args(
    'f' => new_resource.force
  )
  docker_cmd("tag #{tag_args} #{new_resource.image_name} #{repository_and_tag_args}")
end

def tag_match
  # if the tag is specified, we need to check if it matches what
  # is installed already
  if new_resource.tag
    @current_resource.installed_tag == new_resource.tag
  else
    # the tag matches otherwise because it's installed
    true
  end
end
