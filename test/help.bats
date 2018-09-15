#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run kcenv-help
  assert_success
  assert_line "Usage: kcenv <command> [<args>]"
  assert_line "Some useful kcenv commands are:"
}

@test "invalid command" {
  run kcenv-help hello
  assert_failure "kcenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${KCENV_TEST_DIR}/bin"
  cat > "${KCENV_TEST_DIR}/bin/kcenv-hello" <<SH
#!shebang
# Usage: kcenv hello <world>
# Summary: Says "hello" to you, from kcenv
# This command is useful for saying hello.
echo hello
SH

  run kcenv-help hello
  assert_success
  assert_output <<SH
Usage: kcenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${KCENV_TEST_DIR}/bin"
  cat > "${KCENV_TEST_DIR}/bin/kcenv-hello" <<SH
#!shebang
# Usage: kcenv hello <world>
# Summary: Says "hello" to you, from kcenv
echo hello
SH

  run kcenv-help hello
  assert_success
  assert_output <<SH
Usage: kcenv hello <world>

Says "hello" to you, from kcenv
SH
}

@test "extracts only usage" {
  mkdir -p "${KCENV_TEST_DIR}/bin"
  cat > "${KCENV_TEST_DIR}/bin/kcenv-hello" <<SH
#!shebang
# Usage: kcenv hello <world>
# Summary: Says "hello" to you, from kcenv
# This extended help won't be shown.
echo hello
SH

  run kcenv-help --usage hello
  assert_success "Usage: kcenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${KCENV_TEST_DIR}/bin"
  cat > "${KCENV_TEST_DIR}/bin/kcenv-hello" <<SH
#!shebang
# Usage: kcenv hello <world>
#        kcenv hi [everybody]
#        kcenv hola --translate
# Summary: Says "hello" to you, from kcenv
# Help text.
echo hello
SH

  run kcenv-help hello
  assert_success
  assert_output <<SH
Usage: kcenv hello <world>
       kcenv hi [everybody]
       kcenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${KCENV_TEST_DIR}/bin"
  cat > "${KCENV_TEST_DIR}/bin/kcenv-hello" <<SH
#!shebang
# Usage: kcenv hello <world>
# Summary: Says "hello" to you, from kcenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run kcenv-help hello
  assert_success
  assert_output <<SH
Usage: kcenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
