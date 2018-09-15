#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run kcenv
  assert_failure
  assert_line 0 "$(kcenv---version)"
}

@test "invalid command" {
  run kcenv does-not-exist
  assert_failure
  assert_output "kcenv: no such command \`does-not-exist'"
}

@test "default KCENV_ROOT" {
  KCENV_ROOT="" HOME=/home/mislav run kcenv root
  assert_success
  assert_output "/home/mislav/.kcenv"
}

@test "inherited KCENV_ROOT" {
  KCENV_ROOT=/opt/kcenv run kcenv root
  assert_success
  assert_output "/opt/kcenv"
}
