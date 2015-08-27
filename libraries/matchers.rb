if defined?(ChefSpec)
  libraries = File.expand_path('..', __FILE__)
  Dir["#{libraries}/resource_*.rb"].each { |f| require File.expand_path(f) }

  %w(DockerContainer DockerImage DockerRegistry DockerService DockerTag).each do |const|
    resource = Chef::Resource.const_get(const)
    name = resource.resource_name

    if Gem.loaded_specs['chefspec'].version < Gem::Version.new('4.1.0')
      ChefSpec::Runner.define_runner_method(name)
    else
      ChefSpec.define_matcher(name)
    end

    resource.allowed_actions.each do |action|
      define_method("#{action}_#{name}") do |resource_name|
        ChefSpec::Matchers::ResourceMatcher.new(name, action, resource_name)
      end
    end
  end
end
