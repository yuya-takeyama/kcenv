#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$KCENV_TEST_DIR"
  cd "$KCENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${KCENV_ROOT}/versions" ]
  run kcenv-version
  assert_success "system (set by ${KCENV_ROOT}/version)"
}

@test "set by KCENV_VERSION" {
  create_version "1.11.3"
  KCENV_VERSION=1.11.3 run kcenv-version
  assert_success "1.11.3 (set by KCENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "1.11.3"
  cat > ".kubectl-version" <<<"1.11.3"
  run kcenv-version
  assert_success "1.11.3 (set by ${PWD}/.kubectl-version)"
}

@test "set by global file" {
  create_version "1.11.3"
  cat > "${KCENV_ROOT}/version" <<<"1.11.3"
  run kcenv-version
  assert_success "1.11.3 (set by ${KCENV_ROOT}/version)"
}
