#
# Cookbook Name:: zabbix-ruby-client
# Recipe:: sender
#

include_recipe "zabbix-ruby-client::default"

package 'cron' do
  package_name case node.platform_family
               when 'rhel', 'fedora'
                 node.platform_version.to_f >= 6.0 ? 'cronie' : 'vixie-cron'
               when 'solaris2'
                 'core-os'
               when 'gentoo'
                 'vixie-cron'
               end
end

group 'zrc' do
  system true
end

user 'zrc' do
  supports manage_home: true
  home '/var/lib/zrc'
  gid 'zrc'
  shell '/bin/false'
  system true
end

file "/var/lib/zrc/.forward" do
  content node.zrc.admin_email
  owner 'zrc'
  group 'zrc'
  mode '0644'
end

if node.zrc.development
  include_recipe 'git'
  git "#{Chef::Config[:file_cache_path]}/zrc" do
    repository node.zrc.repo_url
    reference node.zrc.repo_branch
    action :sync
  end
  execute "zrc bundle" do
    cwd "#{Chef::Config[:file_cache_path]}/zrc"
    user "root"
    command "/opt/chef/embedded/bin/bundle install"
  end
  execute "zrc build" do
    cwd "#{Chef::Config[:file_cache_path]}/zrc"
    command "#{node.zrc.gem_bin} build zabbix-ruby-client.gemspec"
  end
  execute "zrc install" do
    cwd "#{Chef::Config[:file_cache_path]}/zrc"
    user "root"
    command "#{node.zrc.gem_bin} install --no-rdoc --no-ri --local zabbix-ruby-client-*.gem"
  end
else
  chef_gem "zabbix-ruby-client" do
    version node.zrc.version
  end
end

template '/etc/default/zrc' do
  source 'zrc.default.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

directory "/etc/zrc" do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/zrc/config.yml' do
  source 'config.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

node.zrc.schedule.each do |name, t|
  template "/etc/zrc/#{name}.yml" do
    source 'tasks.yml.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables({ tasks: t[:tasks] })
  end
end

template "/etc/cron.d/zabbix" do
  source "zabbix.cron.erb"
  owner 'root'
  group 'root'
  mode '0644'
  if !node.zrc.enabled
    action :delete
  end
end

%w(/var/cache/zrc /var/log/zrc).each do |dir|
  directory dir do
    owner 'zrc'
    group 'zrc'
    mode '0755'
  end
end

cookbook_file "/usr/bin/zrc_send" do
  source 'zrc_send'
  owner 'root'
  group 'root'
  mode '0755'
end

logrotate_app "zrc" do
  cookbook  'logrotate'
  path      "/var/log/zrc/*.log"
  options   ['missingok', 'delaycompress', 'notifempty', 'dateext', 'sharedscripts' ]
  frequency 'weekly'
  rotate    30
  create    '644 zrc zrc'
end



