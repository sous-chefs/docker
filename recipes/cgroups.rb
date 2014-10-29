# TODO: Platforms handled here should be fixed in control_groups cookbook
# Possibly: https://github.com/hw-cookbooks/control_groups/
case node['platform']
when 'oracle'
  package 'libcgroup'

  service 'cgconfig' do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
when 'ubuntu'
  package 'cgroup-bin'

  if node['platform_version'] == '12.04'
    service 'cgconfig' do
      action :start
    end

    service 'cgred' do
      action :start
    end
  else
    service 'cgroup-lite' do
      action :start
      # WORKAROUND: CHEF-5276, fixed in Chef 11.14
      provider Chef::Provider::Service::Upstart if %w(14.04 14.10).include?(node['platform_version'])
    end
  end
end
