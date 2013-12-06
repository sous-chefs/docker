# TODO: Platforms handled here should be fixed in control_groups cookbook
# Possibly: https://github.com/hw-cookbooks/control_groups/
case node['platform']
when 'oracle'
  package 'libcgroup'

  service 'cgconfig' do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
end
