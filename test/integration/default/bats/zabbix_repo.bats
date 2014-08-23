#!/usr/bin/env bats

@test "zabbix_sender is installed" {
  command -v zabbix_sender
}

@test "zabbix_sender is version 2.2.x" {
  run zabbix_sender -V
  [ -z "${output##* v2.2.*}" ]
}
