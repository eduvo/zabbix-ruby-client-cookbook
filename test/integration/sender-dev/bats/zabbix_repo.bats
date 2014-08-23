#!/usr/bin/env bats

RUBY=/opt/chef/embedded/bin/ruby
GEM=/opt/chef/embedded/bin/gem
ZRC=/opt/chef/embedded/bin/zrc

@test "zrc default exists" {
  [ -f /etc/default/zrc ]
}

@test "zrc default contains ZRC_SEND to 0" {
  run grep -c 'ZRC_SEND="0"' /etc/default/zrc
  [ "$status" -eq 0 ]
}

@test "zrc is installed from gem" {
  run $GEM check zabbix-ruby-client
  [ "$status" -eq 0 ]
}

@test "/etc/zrc exists" {
  [ -d /etc/zrc ]
}

@test "/var/cache/zrc exists" {
  [ -d /var/cache/zrc ]
}

@test "/var/log/zrc exists" {
  [ -d /var/log/zrc ]
}

@test "/etc/zrc/config.yml exists" {
  [ -f /etc/zrc/config.yml ]
}

@test "/etc/zrc/config.yml has host param set to localhost" {
  run grep -c '  host: localhost' /etc/zrc/config.yml
  [ "$status" -eq 0 ]
}

@test "zrc binary is in /opt/chef/embedded/bin/zrc" {
  [ -f /opt/chef/embedded/bin/zrc ]
}

@test "zrc binary is executable" {
  [ -x /opt/chef/embedded/bin/zrc ]
}

@test "zrc binary runs without exception" {
  run sudo -u zrc /opt/chef/embedded/bin/zrc show -c /etc/zrc/config.yml -t /etc/zrc/minutely.yml
  [ "$status" -eq 0 ]
}

@test "zrc show displays cpu total" {
  result="$(sudo -u zrc /opt/chef/embedded/bin/zrc show -c /etc/zrc/config.yml -t /etc/zrc/minutely.yml | grep -c 'cpu\[total\]')"
  [ "$result" -eq 1 ]
}

@test "zrc show outputs 23 lines" {
  result="$(sudo -u zrc /opt/chef/embedded/bin/zrc show -c /etc/zrc/config.yml -t /etc/zrc/minutely.yml | wc -l)"
  [ "$result" -eq 23 ]
}

@test "zrc_send is executable" {
  [ -x /usr/bin/zrc_send ]
}

@test "zrc_send runs fine" {
  run sudo -u zrc zrc_send
  [ "$status" -eq 0 ]
}

@test "zrc_send show outputs 23 lines" {
  result="$(sudo -u zrc zrc_send minutely | wc -l)"
  [ "$result" -eq 23 ]
}

@test "zrc logrotate is ready" {
  [ -f /etc/logrotate.d/zrc ]
}

@test "zabbix cronfile is ready" {
  [ -f /etc/cron.d/zabbix ]
}

@test "zrc cronfile has a proper minutely programmed" {
  result="$(grep minutely /etc/cron.d/zabbix)"
  [ "$result" == "* * * * * zrc /usr/bin/zrc_send minutely" ]
}

@test "zrc cronfile has a proper monthly programmed" {
  result="$(grep monthly /etc/cron.d/zabbix)"
  [ "$result" == "0 0 1 * * zrc /usr/bin/zrc_send monthly" ]
}

@test "zrc home has a .forward set to root by default" {
  result="$(cat /var/lib/zrc/.forward)"
  [ "$result" == "root" ]
}
