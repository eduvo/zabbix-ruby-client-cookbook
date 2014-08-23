Zabbix Ruby Client Cookbook
============================

This cookbook is designed for installing [zabbix-ruby-client](https://github.com/eduvo/zabbix-ruby-client) on an Ubuntu server, with zabbix-sender v2.2. It's based on the version 0.1.0 of zabbix-ruby-client (called zrc for short).

The principle of it is to use the chef client embedded ruby from `/opt/chef/embedded/bin` so there is no need to install a system or versionned ruby on all servers just for that.

Tested in the kitchen on

- Ubuntu 12.04
- Ubuntu 14.04
- CentOs 5.10
- CentOs 6.5

It should also work on RHEL 5 and 6, Oracle Linux 5 and 6, Debian 6 and 7.

It will install:

- the zabbix source list for ubuntu
- the zabbix-sender package
- the zabbix-ruby-client from rubygems (or from github if node.zrc.development = true) using the chef embedded `gem`command
- a `/etc/default/zrc` with a flag to run it or not
- config.yml and tasks (minutely.yml) in `/etc/zrc/`
- a `zrc` system user with a home in `/var/lib/zrc`
- a data dir at `/var/cache/zrc`
- a log dir at `/var/log/zrc`
- a rotatelog config to rotate the logs every week
- a bash wrapper in `/usr/bin/zrc_send` that launches zrc using the chef embedded ruby version
- a cronfile gathering the triggering of all tasks at `/etc/cron.d/zabbix`

Attributes
==============

Attribute |  Default  | Description
----------|-----------|-------------
`zrc.version`     | "0.1.0"     | Version of the zabbix-ruby-client to install (if `development` is false)
`zrc.admin_email` | "root"      | email or unix account used in the `.forward` in the home of the `zrc` user
`zrc.ruby_bin`    | "/opt/chef/embedded/bin/ruby" | path to the ruby used by zrc
`zrc.gem_bin`     | "/opt/chef/embedded/bin/gem"  | path to the gem command used to install zrc
`zrc.binpath`     | "/opt/chef/embedded/bin/zrc"  | path where the zrc command will be installed
`zrc.zrc_send`    | "1"         | if set to "0" disables the sending of data
`zrc.development` | false       | if set to true, use github master branch rather than the published gem version
`zrc.server.host` | "localhost" | url of the zabbix server
`zrc.server.port` | "10051"     | port of the trapper daemon on the zabbix server
`zrc.schedule`    | __see below__ | schedule object used to build the tasks files and cron file

Default schedule

````json
{
  "minutely": {
    "cron": "* * * * *",
    "tasks": [
      { "name": "load" },
      { "name": "memory" },
      { "name": "cpu" }
    ]
  },
  "hourly": {
    "cron": "0 * * * *",
    "tasks": [
      { "name": "apt" }
    ]
  },
  "monthly": {
    "cron": "0 0 1 * *",
    "tasks": [
      { "name": "sysinfo" }
    ]
  }
}
````

if you want to add values to the schedule, use `default_attribute` in a role file. For example I have a `zrc-linode.json`, which adds disk and network interface to the minutely task role with:

````json
{
  "name": "zrc-linode",
  "chef_type": "role",
  "json_class": "Chef::Role",
  "description": "ZRC linode eth and disks",
  "default_attributes": {
    "zrc": {
      "schedule": {
        "minutely": {
          "tasks": [
            { "name": "disk", "args": "[ xvda, /, xvda ]" },
            { "name": "network", "args": "[ eth0 ]" }
          ]
        }
      }
    }
  }
}
````

If you need to overwrite the default values, you can use `overwrite_attributes`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

* [@mose](https://github.com/mose) - author

## License

Copyright 2013 [Faria Systems](http://faria.co) - MIT license - created by mose at mose.com