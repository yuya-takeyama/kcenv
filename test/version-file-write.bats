#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$KCENV_TEST_DIR"
  cd "$KCENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run kcenv-version-file-write
  assert_failure "Usage: kcenv version-file-write <file> <version>"
  run kcenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".kubectl-version" ]
  run kcenv-version-file-write ".kubectl-version" "1.11.3"
  assert_failure "kcenv: version \`1.11.3' is not installed"
  assert [ ! -e ".kubectl-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${KCENV_ROOT}/versions/1.10.8"
  assert [ ! -e "my-version" ]
  run kcenv-version-file-write "${PWD}/my-version" "1.10.8"
  assert_success ""
  assert [ "$(cat my-version)" = "1.10.8" ]
}
