if defined?(ChefSpec)
  # TODO: Contribute to apt cookbook
  # Apt repository
  def add_apt_repository(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apt_repository, :add, resource_name)
  end

  # TODO: See: https://github.com/NOX73/chef-golang/pull/22/files
  # Golang package
  def install_golang_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:golang_package, :install, resource_name)
  end

  # TODO: Remove once runit >= 1.5.11 is released
  # Runit service
  def enable_runit_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:runit_service, :enable, resource_name)
  end
end
