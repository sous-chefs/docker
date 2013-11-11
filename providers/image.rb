require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include Helpers::Docker

def load_current_resource
  @current_resource = Chef::Resource::DockerImage.new(new_resource)
  di = shell_out('docker images -a', :timeout => new_resource.cmd_timeout)
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

action :pull do
  unless installed?
    pull
    new_resource.updated_by_last_action(true)
  end
end

action :remove do
  if installed?
    remove
    new_resource.updated_by_last_action(true)
  end
end

def build
  full_image_name = new_resource.image_name
  full_image_name += ":#{new_resource.tag}" if new_resource.tag

  if new_resource.dockerfile
    command = "- < #{new_resource.dockerfile}"
  elsif new_resource.path
    command = new_resource.path
  elsif new_resource.image_url
    command = new_resource.image_url
  end

  shell_out("docker build -t #{full_image_name} #{command}", :timeout => new_resource.cmd_timeout)
end

def import
  import_args = ''
  if new_resource.image_url
    import_args += new_resource.image_url
    import_args += " #{new_resource.image_name}"
  elsif new_resource.repository
    import_args += " - #{new_resource.repository}"
    import_args += " #{new_resource.tag}" if new_resource.tag
  end

  shell_out("docker import #{import_args}", :timeout => new_resource.cmd_timeout)
end

def installed?
  @current_resource.installed && tag_match
end

def pull
  pull_args = cli_args(
    'registry' => new_resource.registry,
    't' => new_resource.tag
  )
  shell_out("docker pull #{new_resource.image_name} #{pull_args}", :timeout => new_resource.cmd_timeout)
end

def remove
  shell_out("docker rmi #{new_resource.image_name}", :timeout => new_resource.cmd_timeout)
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
