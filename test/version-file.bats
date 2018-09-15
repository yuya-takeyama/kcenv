#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$KCENV_TEST_DIR"
  cd "$KCENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  echo "system" > "$1"
}

@test "detects global 'version' file" {
  create_file "${KCENV_ROOT}/version"
  run kcenv-version-file
  assert_success "${KCENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${KCENV_ROOT}/version" ]
  assert [ ! -e ".kubectl-version" ]
  run kcenv-version-file
  assert_success "${KCENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".kubectl-version"
  run kcenv-version-file
  assert_success "${KCENV_TEST_DIR}/.kubectl-version"
}

@test "in parent directory" {
  create_file ".kubectl-version"
  mkdir -p project
  cd project
  run kcenv-version-file
  assert_success "${KCENV_TEST_DIR}/.kubectl-version"
}

@test "topmost file has precedence" {
  create_file ".kubectl-version"
  create_file "project/.kubectl-version"
  cd project
  run kcenv-version-file
  assert_success "${KCENV_TEST_DIR}/project/.kubectl-version"
}

@test "KCENV_DIR has precedence over PWD" {
  create_file "widget/.kubectl-version"
  create_file "project/.kubectl-version"
  cd project
  KCENV_DIR="${KCENV_TEST_DIR}/widget" run kcenv-version-file
  assert_success "${KCENV_TEST_DIR}/widget/.kubectl-version"
}

@test "PWD is searched if KCENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.kubectl-version"
  cd project
  KCENV_DIR="${KCENV_TEST_DIR}/widget/blank" run kcenv-version-file
  assert_success "${KCENV_TEST_DIR}/project/.kubectl-version"
}

@test "finds version file in target directory" {
  create_file "project/.kubectl-version"
  run kcenv-version-file "${PWD}/project"
  assert_success "${KCENV_TEST_DIR}/project/.kubectl-version"
}

@test "fails when no version file in target directory" {
  run kcenv-version-file "$PWD"
  assert_failure ""
}
