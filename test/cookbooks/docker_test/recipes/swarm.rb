docker_swarm_manager 'test' do
  first_manager true
end

docker_overlay_network 'test_network' do
end
