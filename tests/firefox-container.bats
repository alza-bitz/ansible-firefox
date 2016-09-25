#!/usr/bin/env bats

# dependencies of this test: bats, ansible, docker, grep
# control machine requirements for playbook under test: ???

load 'bats-ansible/load'

setup() {
  container=$(container_startup fedora)
  hosts=$(tmp_file $(container_inventory $container))
  container_dnf_conf $container keepcache 1
  container_dnf_conf $container metadata_timer_sync 0
  container_exec_sudo $container dnf -q -y install xorg-x11-server-Xvfb daemonize
  container_exec_sudo $container daemonize /usr/bin/Xvfb :1
  mkdir -p ${BATS_TEST_DIRNAME}/roles
  ansible-galaxy install -p ${BATS_TEST_DIRNAME}/roles alzadude.firefox-addon
}

@test "Role with addon can be applied to container" {
  ansible-playbook -i $hosts ${BATS_TEST_DIRNAME}/test-addon.yml
  container_exec $container test -d "~/.mozilla/firefox/*.default/extensions/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}"
}

@test "Role with addon is idempotent" {
  ansible-playbook -i $hosts ${BATS_TEST_DIRNAME}/test-addon.yml
  run ansible-playbook -i $hosts ${BATS_TEST_DIRNAME}/test-addon.yml
  [[ $output =~ changed=0.*unreachable=0.*failed=0 ]]
}

@test "Role with prefs can be applied to container" {
  ansible-playbook -i $hosts ${BATS_TEST_DIRNAME}/test-prefs.yml
  container_exec $container cat "~/.mozilla/firefox/*.default/user.js" | {
    readarray -t _prefs
    [[ ${#_prefs[@]} == 1 ]]
    [[ ${_prefs[0]} =~ ^user_pref\(\"some.string.pref\",\ \"some-string-pref-value\"\)\;$ ]]
  }
}

@test "Role with ui customisation can be applied to container" {
  ansible-playbook -i $hosts ${BATS_TEST_DIRNAME}/test-ui-customisation.yml
  container_exec $container cat "~/.mozilla/firefox/*.default/user.js" | {
    readarray -t _prefs
    [[ ${#_prefs[@]} == 1 ]]
    [[ ${_prefs[0]} =~ ^user_pref\(\"browser.uiCustomization.state\",\ \".*\"\)\;$ ]]
    [[ ! ${_prefs[0]} =~ ^user_pref\(\"browser.uiCustomization.state\",\ \".*loop-button.*\"\)\;$ ]]
  }
}

teardown() {
  container_cleanup
  rm -rf ${BATS_TEST_DIRNAME}/roles
}
