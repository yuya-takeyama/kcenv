#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${KCENV_ROOT}/versions/${KCENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export KCENV_VERSION="0.0.0"
  run kcenv-exec version
  assert_failure "kcenv: version \`0.0.0' is not installed"
}

@test "fails with invalid version set from file" {
  mkdir -p "$KCENV_TEST_DIR"
  cd "$KCENV_TEST_DIR"
  echo 0.0.1 > .kubectl-version
  run kcenv-exec rspec
  assert_failure "kcenv: version \`0.0.1' is not installed (set by $PWD/.kubectl-version)"
}
