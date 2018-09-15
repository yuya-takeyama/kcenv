#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$KCENV_TEST_DIR"
  cd "$KCENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${KCENV_ROOT}/version" ]
  run kcenv-version-origin
  assert_success "${KCENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$KCENV_ROOT"
  touch "${KCENV_ROOT}/version"
  run kcenv-version-origin
  assert_success "${KCENV_ROOT}/version"
}

@test "detects KCENV_VERSION" {
  KCENV_VERSION=1 run kcenv-version-origin
  assert_success "KCENV_VERSION environment variable"
}

@test "detects local file" {
  echo "system" > .kubectl-version
  run kcenv-version-origin
  assert_success "${PWD}/.kubectl-version"
}

@test "doesn't inherit KCENV_VERSION_ORIGIN from environment" {
  KCENV_VERSION_ORIGIN=ignored run kcenv-version-origin
  assert_success "${KCENV_ROOT}/version"
}
