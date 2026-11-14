#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

verify_standard_fixture() {
  echo "==> Verifying standard Go Taskfile fixture..."
  cd "$SCRIPT_DIR/go-fixture"
  task clean >/dev/null 2>&1 || true

  task all
  test -x bin/sample
  test -f coverage.out

  # Verify default embedded version in compiled binary
  ./bin/sample | grep -q "hello world (dev)"

  # Verify rebuild on VERSION configuration change
  task build VERSION=v1.0.0
  ./bin/sample | grep -q "hello world (v1.0.0)"

  # Verify rebuild on configuration restore
  task build
  ./bin/sample | grep -q "hello world (dev)"

  # Verify LDFLAGS containing embedded quotes are passed as a single argument
  task build 'LDFLAGS=-s -w -X "main.version=v2.0.0"'
  ./bin/sample | grep -q "hello world (v2.0.0)"

  # Verify local replacement module edits are reflected on rebuild
  TMP_DEP=$(mktemp -d)
  cp go.mod go.mod.bak
  cp cmd/sample/main.go cmd/sample/main.go.bak
  cleanup_dep() {
    if [ -f "$SCRIPT_DIR/go-fixture/go.mod.bak" ]; then
      mv "$SCRIPT_DIR/go-fixture/go.mod.bak" "$SCRIPT_DIR/go-fixture/go.mod"
    fi
    if [ -f "$SCRIPT_DIR/go-fixture/cmd/sample/main.go.bak" ]; then
      mv "$SCRIPT_DIR/go-fixture/cmd/sample/main.go.bak" "$SCRIPT_DIR/go-fixture/cmd/sample/main.go"
    fi
    rm -rf "$TMP_DEP"
  }
  trap cleanup_dep EXIT

  cat > "$TMP_DEP/go.mod" <<'EOF'
module example.com/siblingdep

go 1.22
EOF
  cat > "$TMP_DEP/dep.go" <<'EOF'
package siblingdep

func Tag() string { return "sibling-v1" }
EOF
  cat >> go.mod <<EOF

require example.com/siblingdep v0.0.0
replace example.com/siblingdep => $TMP_DEP
EOF
  cat > cmd/sample/main.go <<'EOF'
package main

import (
	"fmt"

	"example.com/siblingdep"
	"example.com/testfixture/pkg/greet"
)

var version = "dev"

func main() {
	fmt.Printf("%s (%s) [%s]\n", greet.Hello(), version, siblingdep.Tag())
}
EOF

  task build
  ./bin/sample | grep -q "hello world (dev) \[sibling-v1\]"

  cat > "$TMP_DEP/dep.go" <<'EOF'
package siblingdep

func Tag() string { return "sibling-v2" }
EOF
  task build
  ./bin/sample | grep -q "hello world (dev) \[sibling-v2\]"

  cleanup_dep
  trap - EXIT

  # Verify check-coverage and all fail (nonzero exit) when coverage is below MIN_COVERAGE
  if task check-coverage MIN_COVERAGE=90 >/dev/null 2>&1; then
    echo "ERROR: Expected check-coverage to fail when coverage is below MIN_COVERAGE=90" >&2
    exit 1
  fi
  if task all MIN_COVERAGE=90 >/dev/null 2>&1; then
    echo "ERROR: Expected task all to fail when coverage is below MIN_COVERAGE=90" >&2
    exit 1
  fi

  task clean
  test ! -d bin
  test ! -f coverage.out
  rm -rf .task
}

verify_override_fixture() {
  echo "==> Verifying override Go Taskfile fixture..."
  cd "$SCRIPT_DIR/go-override-fixture"
  task clean >/dev/null 2>&1 || true

  task all
  test -x bin/sample
  test -f bin/custom-build-executed.txt
  test -f bin/custom-lint-executed.txt
  grep -q "custom-build-executed" bin/custom-build-executed.txt
  grep -q "custom-lint-executed" bin/custom-lint-executed.txt

  task clean
  test ! -d bin
  test ! -f coverage.out
  rm -rf .task
}

verify_starter_and_shim() {
  echo "==> Verifying starter Go Taskfile and Makefile.shim..."
  REPO_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/../.." && pwd)
  TMP_SHIM_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_SHIM_DIR"' EXIT

  cp -R "$SCRIPT_DIR/go-fixture/." "$TMP_SHIM_DIR/"
  cp "$REPO_ROOT/templates/build/Makefile.shim" "$TMP_SHIM_DIR/Makefile"
  sed "s|https://raw.githubusercontent.com/borch-ai/.github/main/taskfiles/go.yml|$REPO_ROOT/taskfiles/go.yml|g" \
    "$REPO_ROOT/templates/build/Taskfile.go.yml" > "$TMP_SHIM_DIR/Taskfile.yml"

  cd "$TMP_SHIM_DIR"
  task --list-all | grep -q "all:"
  POWERWORD="$SCRIPT_DIR/mock-powerword.sh" MIN_COVERAGE=50 make all
  test -x bin/sample
  test -f coverage.out
  POWERWORD="$SCRIPT_DIR/mock-powerword.sh" make lint
  make clean
  test ! -d bin
  test ! -f coverage.out

  rm -rf "$TMP_SHIM_DIR"
  trap - EXIT
}

verify_standard_fixture
verify_override_fixture
verify_starter_and_shim
echo "==> All Taskfile self-tests passed."
