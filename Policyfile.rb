# frozen_string_literal: true

name 'docker'

run_list 'recipe[test::default]'

cookbook 'docker', path: '.'
cookbook 'test', path: './test/cookbooks/test'

Dir.children('./test/cookbooks/test/recipes').grep(/\.rb\z/).sort.each do |recipe|
  recipe_name = File.basename(recipe, '.rb')

  named_run_list recipe_name.to_sym, 'recipe[test::' + recipe_name + ']'
end

named_run_list :resources,
               'recipe[test::default]',
               'recipe[test::image]',
               'recipe[test::container]',
               'recipe[test::exec]',
               'recipe[test::plugin]',
               'recipe[test::image_prune]',
               'recipe[test::volume_prune]'
named_run_list :network, 'recipe[test::default]', 'recipe[test::network]'
named_run_list :volume, 'recipe[test::default]', 'recipe[test::volume]', 'recipe[test::volume_prune]'
named_run_list :registry, 'recipe[test::default]', 'recipe[test::registry]'
named_run_list :swarm, 'recipe[test::swarm]', 'recipe[test::swarm_service]'
