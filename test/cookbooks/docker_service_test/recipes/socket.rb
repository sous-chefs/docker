# comments!

service_def = proc do
  tls false
  action [:create, :start]
end

if node['docker']['service_manager'] == 'execute'
  docker_service_execute('default', &service_def)
else
  docker_service('default', &service_def)
end
