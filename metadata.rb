name             'zabbix-ruby-client'
maintainer       'nose'
maintainer_email 'mose@mose.com'
license          'MIT'
description      'Installs/Configures Zabbix-ruby-client'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          IO.read(File.expand_path('../CHANGELOG.md', __FILE__))[/([0-9]+\.[0-9]+\.[0-9]+)/]

depends 'logrotate',   '~> 1.6.0'  # https://supermarket.getchef.com/cookbooks/logrotate
depends 'git',         '~> 4.0.2'  # https://supermarket.getchef.com/cookbooks/git

supports 'debian'
supports 'ubuntu'
supports 'centos'
supports 'redhat'
supports 'oracle'
