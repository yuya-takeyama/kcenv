#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${KCENV_TEST_DIR}/myproject"
  cd "${KCENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.kubectl-version" ]
  run kcenv-local
  assert_failure "kcenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .kubectl-version
  run kcenv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .kubectl-version
  mkdir -p "subdir" && cd "subdir"
  run kcenv-local
  assert_success "1.2.3"
}

@test "ignores KCENV_DIR" {
  echo "1.2.3" > .kubectl-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.kubectl-version"
  KCENV_DIR="$HOME" run kcenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${KCENV_ROOT}/versions/1.2.3"
  run kcenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .kubectl-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .kubectl-version
  mkdir -p "${KCENV_ROOT}/versions/1.2.3"
  run kcenv-local
  assert_success "1.0-pre"
  run kcenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .kubectl-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .kubectl-version
  run kcenv-local --unset
  assert_success ""
  assert [ ! -e .kubectl-version ]
}
