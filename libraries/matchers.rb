if defined?(ChefSpec)
  # Docker matchers
  chefspec_version = Gem.loaded_specs['chefspec'].version
  if chefspec_version < Gem::Version.new('4.1.0')
    ChefSpec::Runner.define_runner_method(:docker_container)
    ChefSpec::Runner.define_runner_method(:docker_image)
    ChefSpec::Runner.define_runner_method(:docker_registry)
  else
    ChefSpec.define_matcher(:docker_container)
    ChefSpec.define_matcher(:docker_image)
    ChefSpec.define_matcher(:docker_registry)
  end

  # Docker Service
  def create_docker_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_service, :create, resource_name)
  end

  # Docker registry
  def login_docker_registry(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_registry, :login, resource_name)
  end

  # Docker containers
  def commit_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :commit, resource_name)
  end

  def cp_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :cp, resource_name)
  end

  def export_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :export, resource_name)
  end

  def kill_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :kill, resource_name)
  end

  def redeploy_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :redeploy, resource_name)
  end

  def remove_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :remove, resource_name)
  end

  def restart_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :restart, resource_name)
  end

  def run_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :run, resource_name)
  end

  def start_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :start, resource_name)
  end

  def stop_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :stop, resource_name)
  end

  def wait_docker_container(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_container, :wait, resource_name)
  end

  # Docker images
  def build_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :build, resource_name)
  end

  def build_if_missing_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :build_if_missing, resource_name)
  end

  def import_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :import, resource_name)
  end

  def insert_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :insert, resource_name)
  end

  def load_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :load, resource_name)
  end

  def pull_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :pull, resource_name)
  end

  def pull_if_missing_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :pull_if_missing, resource_name)
  end

  def push_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :push, resource_name)
  end

  def remove_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :remove, resource_name)
  end

  def save_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :save, resource_name)
  end

  def tag_docker_image(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:docker_image, :tag, resource_name)
  end
end
