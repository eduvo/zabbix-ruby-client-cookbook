#
# Cookbook Name:: zabbix-ruby-client
# Attributes:: default
#

default.zrc.version     = "0.1.0"
default.zrc.enabled     = true
default.zrc.admin_email = "root"
default.zrc.bundle_bin  = '/opt/chef/embedded/bin/bundle'
default.zrc.ruby_bin    = '/opt/chef/embedded/bin/ruby'
default.zrc.gem_bin     = '/opt/chef/embedded/bin/gem'
default.zrc.binpath     = '/opt/chef/embedded/bin/zrc'
default.zrc.zrc_send    = '1'
default.zrc.development = false
default.zrc.gitrepo_url = 'https://github.com/eduvo/zabbix-ruby-client.git'
default.zrc.server.host = 'localhost'
default.zrc.server.port = '10051'
default.zrc.schedule    = {
  minutely: {
    cron: "* * * * *",
    tasks: [
      { name: 'load' },
      { name: 'memory' },
      { name: 'cpu' }
    ]
  },
  hourly: {
    cron: "0 * * * *",
    tasks: [
      { name: 'apt' }
    ]
  },
  monthly: {
    cron: "0 0 1 * *",
    tasks: [
      { name: 'sysinfo' }
    ]
  }
}
