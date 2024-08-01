unified_mode true
use 'partial/_base'
use 'partial/_service_base'

resource_name :docker_service

# register with the resource resolution system
provides :docker_service

# installation type and service_manager
property :install_method, %w(script package tarball none auto), default: lazy { docker_install_method }, desired_state: false
property :service_manager, %w(execute systemd none auto), default: 'auto', desired_state: false

# docker_installation_script
property :repo, String, desired_state: false
property :script_url, String, desired_state: false

# docker_installation_tarball
property :checksum, String, desired_state: false
property :docker_bin, String, desired_state: false
property :source, String, desired_state: false

# docker_installation_package
property :package_version, String, desired_state: false
property :package_name, String, desired_state: false
property :setup_docker_repo, [true, false], desired_state: false

# package and tarball
property :version, String, desired_state: false
property :package_options, String, desired_state: false

action_class do
  def validate_install_method
    if new_resource.property_is_set?(:version) &&
       new_resource.install_method != 'package' &&
       new_resource.install_method != 'tarball'
      raise Chef::Exceptions::ValidationFailed, 'Version property only supported for package and tarball installation methods'
    end
  end

  def property_intersection(src, dest)
    src.class.properties.keys.intersection(dest.class.properties.keys)
  end

  def installation(&block)
    b = proc {
      copy_properties_from(new_resource, *property_intersection(new_resource, self), exclude: [:install_method])
      instance_exec(&block)
    }

    case new_resource.install_method
    when 'auto'
      install = docker_installation(new_resource.name, &b)
    when 'script'
      install = docker_installation_script(new_resource.name, &b)
    when 'package'
      install = docker_installation_package(new_resource.name, &b)
    when 'tarball'
      install = docker_installation_tarball(new_resource.name, &b)
    when 'none'
      Chef::Log.info('Skipping Docker installation. Assuming it was handled previously.')
      return
    end
    install
  end

  def svc_manager(&block)
    b = proc {
      copy_properties_from(new_resource, *property_intersection(new_resource, self),
                           exclude: [:service_manager, :install_method])
      instance_exec(&block)
    }

    case new_resource.service_manager
    when 'auto'
      svc = docker_service_manager(new_resource.name, &b)
    when 'execute'
      svc = docker_service_manager_execute(new_resource.name, &b)
    when 'systemd'
      svc = docker_service_manager_systemd(new_resource.name, &b)
    when 'none'
      Chef::Log.info('Skipping Docker Server Manager. Assuming it was handled previously.')
      return
    end
    svc
  end
end

#########
# Actions
#########

action :create do
  validate_install_method

  installation do
    action :create
    notifies :restart, new_resource, :immediately
  end
end

action :delete do
  installation do
    action :delete
  end
end

action :start do
  svc_manager do
    action :start
  end
end

action :stop do
  svc_manager do
    action :stop
  end
end

action :restart do
  svc_manager do
    action :restart
  end
end
