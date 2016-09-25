#!/usr/bin/env bats

load 'bats-ansible/load'

setup() {
  mkdir -p ${BATS_TEST_DIRNAME}/roles
  ansible-galaxy install -p ${BATS_TEST_DIRNAME}/roles alzadude.firefox-addon
}

@test "Role with addon syntax" {
  ansible-playbook ${BATS_TEST_DIRNAME}/test-addon.yml --syntax-check
}

teardown() {
  rm -rf ${BATS_TEST_DIRNAME}/roles  
}
