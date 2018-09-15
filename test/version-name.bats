#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$KCENV_TEST_DIR"
  cd "$KCENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${KCENV_ROOT}/versions" ]
  run kcenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  KCENV_VERSION=system run kcenv-version-name
  assert_success "system"
}

@test "KCENV_VERSION has precedence over local" {
  create_version "1.10.8"
  create_version "1.11.3"

  cat > ".kubectl-version" <<<"1.10.8"
  run kcenv-version-name
  assert_success "1.10.8"

  KCENV_VERSION=1.11.3 run kcenv-version-name
  assert_success "1.11.3"
}

@test "local file has precedence over global" {
  create_version "1.10.8"
  create_version "1.11.3"

  cat > "${KCENV_ROOT}/version" <<<"1.10.8"
  run kcenv-version-name
  assert_success "1.10.8"

  cat > ".kubectl-version" <<<"1.11.3"
  run kcenv-version-name
  assert_success "1.11.3"
}

@test "missing version" {
  KCENV_VERSION=1.2 run kcenv-version-name
  assert_failure "kcenv: version \`1.2' is not installed (set by KCENV_VERSION environment variable)"
}
