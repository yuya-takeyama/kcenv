#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$KCENV_TEST_DIR"
  cd "$KCENV_TEST_DIR"
}

stub_system_kubectl() {
  local stub="${KCENV_TEST_DIR}/bin/kubectl"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_kubectl
  assert [ ! -d "${KCENV_ROOT}/versions" ]
  run kcenv-versions
  assert_success "* system (set by ${KCENV_ROOT}/version)"
}


@test "bare output no versions installed" {
  assert [ ! -d "${KCENV_ROOT}/versions" ]
  run kcenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_kubectl
  create_version "1.9"
  run kcenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${KCENV_ROOT}/version)
  1.9
OUT
}

@test "single version bare" {
  create_version "1.9"
  run kcenv-versions --bare
  assert_success "1.9"
}

@test "multiple versions" {
  stub_system_kubectl
  create_version "1.10.8"
  create_version "1.11.3"
  create_version "1.13.0"
  run kcenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${KCENV_ROOT}/version)
  1.10.8
  1.11.3
  1.13.0
OUT
}

@test "indicates current version" {
  stub_system_kubectl
  create_version "1.11.3"
  create_version "1.13.0"
  KCENV_VERSION=1.11.3 run kcenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.11.3 (set by KCENV_VERSION environment variable)
  1.13.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "1.11.3"
  create_version "1.13.0"
  KCENV_VERSION=1.11.3 run kcenv-versions --bare
  assert_success
  assert_output <<OUT
1.11.3
1.13.0
OUT
}

@test "globally selected version" {
  stub_system_kubectl
  create_version "1.11.3"
  create_version "1.13.0"
  cat > "${KCENV_ROOT}/version" <<<"1.11.3"
  run kcenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.11.3 (set by ${KCENV_ROOT}/version)
  1.13.0
OUT
}

@test "per-project version" {
  stub_system_kubectl
  create_version "1.11.3"
  create_version "1.13.0"
  cat > ".kubectl-version" <<<"1.11.3"
  run kcenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.11.3 (set by ${KCENV_TEST_DIR}/.kubectl-version)
  1.13.0
OUT
}

@test "ignores non-directories under versions" {
  create_version "1.9"
  touch "${KCENV_ROOT}/versions/hello"

  run kcenv-versions --bare
  assert_success "1.9"
}

@test "lists symlinks under versions" {
  create_version "1.10.8"
  ln -s "1.10.8" "${KCENV_ROOT}/versions/1.10"

  run kcenv-versions --bare
  assert_success
  assert_output <<OUT
1.10
1.10.8
OUT
}

@test "doesn't list symlink aliases when --skip-aliases" {
  create_version "1.10.8"
  ln -s "1.10.8" "${KCENV_ROOT}/versions/1.10"
  mkdir moo
  ln -s "${PWD}/moo" "${KCENV_ROOT}/versions/1.9"

  run kcenv-versions --bare --skip-aliases
  assert_success

  assert_output <<OUT
1.10.8
1.9
OUT
}
