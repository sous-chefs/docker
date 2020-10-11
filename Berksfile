source 'https://supermarket.chef.io'

metadata

# XXX: Temporary for testing
cookbook 'etcd', github: 'sous-chefs/etcd', branch: 'sous-chefs-adoption'

group :integration do
  cookbook 'docker_test', path: 'test/cookbooks/docker_test'
end
