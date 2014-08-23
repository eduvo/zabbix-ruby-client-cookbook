#
# Cookbook Name:: zabbix-ruby-client
# Recipe:: default
#

case node.platform_family
when 'rhel'
  remote_file "#{Chef::Config[:file_cache_path]}/zabbix-release-2.2-1.el#{node.platform_version[0]}.noarch.rpm" do
    source "http://repo.zabbix.com/zabbix/2.2/rhel/#{node.platform_version[0]}/x86_64/zabbix-release-2.2-1.el#{node.platform_version[0]}.noarch.rpm"
    backup false
    action :create_if_missing
  end

  rpm_package "zabbix-release-2.2-1.el#{node.platform_version[0]}.noarch.rpm" do
    source "#{Chef::Config[:file_cache_path]}/zabbix-release-2.2-1.el#{node.platform_version[0]}.noarch.rpm"
    options "-ivh"
    action :install
  end

when 'debian'
  remote_file "#{Chef::Config[:file_cache_path]}/zabbix-release_2.2-1+#{node.lsb.codename}_all.deb" do
    source "http://repo.zabbix.com/zabbix/2.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.2-1+#{node.lsb.codename}_all.deb"
    backup false
    action :create_if_missing
  end

  dpkg_package "zabbix-release_2.2-1+#{node.lsb.codename}_all.deb" do
    source "#{Chef::Config[:file_cache_path]}/zabbix-release_2.2-1+#{node.lsb.codename}_all.deb"
    action :install
    notifies :run, "execute[apt-get-update]", :immediately
    not_if { ::File.exist? '/etc/apt/sources.list.d/zabbix.list' }
  end

  execute "apt-get-update" do
    user "root"
    command "apt-get update"
    action :nothing
  end
end

package "zabbix-sender"
