group 'docker' do
  members node['docker']['group_members']
  action [:create, :manage]
end
