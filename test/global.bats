#!/usr/bin/env bats

load test_helper

@test "default" {
  run kcenv-global
  assert_success
  assert_output "system"
}

@test "read KCENV_ROOT/version" {
  mkdir -p "$KCENV_ROOT"
  echo "1.2.3" > "$KCENV_ROOT/version"
  run kcenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set KCENV_ROOT/version" {
  mkdir -p "$KCENV_ROOT/versions/1.2.3"
  run kcenv-global "1.2.3"
  assert_success
  run kcenv-global
  assert_success "1.2.3"
}

@test "fail setting invalid KCENV_ROOT/version" {
  mkdir -p "$KCENV_ROOT"
  run kcenv-global "1.2.3"
  assert_failure "kcenv: version \`1.2.3' is not installed"
}
