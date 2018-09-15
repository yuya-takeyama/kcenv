unset KCENV_VERSION
unset KCENV_DIR

# guard against executing this block twice due to bats internals
if [ -z "$KCENV_TEST_DIR" ]; then
  KCENV_TEST_DIR="${BATS_TMPDIR}/kcenv"
  export KCENV_TEST_DIR="$(mktemp -d "${KCENV_TEST_DIR}.XXX" 2>/dev/null || echo "$KCENV_TEST_DIR")"

  if enable -f "${BATS_TEST_DIRNAME}"/../libexec/kcenv-realpath.dylib realpath 2>/dev/null; then
    export KCENV_TEST_DIR="$(realpath "$KCENV_TEST_DIR")"
  else
    if [ -n "$KCENV_NATIVE_EXT" ]; then
      echo "kcenv: failed to load \`realpath' builtin" >&2
      exit 1
    fi
  fi

  export KCENV_ROOT="${KCENV_TEST_DIR}/root"
  export HOME="${KCENV_TEST_DIR}/home"
  export KCENV_HOOK_PATH="${KCENV_ROOT}/kcenv.d"

  PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
  PATH="${KCENV_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
  PATH="${KCENV_ROOT}/shims:$PATH"
  export PATH

  for xdg_var in `env 2>/dev/null | grep ^XDG_ | cut -d= -f1`; do unset "$xdg_var"; done
  unset xdg_var
fi

teardown() {
  rm -rf "$KCENV_TEST_DIR"
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${KCENV_TEST_DIR}:TEST_DIR:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    flunk "expected line \`$1'"
  fi
}

refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      flunk "output has $num_lines lines"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        flunk "expected to not find line \`$line'"
      fi
    done
  fi
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

create_version() {
  mkdir -p "${KCENV_ROOT}/versions/$1"
}
