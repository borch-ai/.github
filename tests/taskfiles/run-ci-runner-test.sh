#!/usr/bin/env sh
set -eu

FIXTURE="${1:?missing fixture name (make, task, or task-partial)}"
DETECTED_RUNNER="${2:?missing detected runner output}"

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/../.." && pwd)
CHECK_SCRIPT="$REPO_ROOT/.github/actions/setup-build-runner/check-taskfile.sh"
DETECT_SCRIPT="$REPO_ROOT/.github/actions/setup-build-runner/detect-runner.sh"

case "$FIXTURE" in
  make)
    EXPECTED_RUNNER="make"
    FIXTURE_DIR="$SCRIPT_DIR/go-make-fixture"
    ;;
  task)
    EXPECTED_RUNNER="task"
    FIXTURE_DIR="$SCRIPT_DIR/go-fixture"
    ;;
  task-partial)
    EXPECTED_RUNNER="make"
    FIXTURE_DIR="$SCRIPT_DIR/go-partial-fixture"
    ;;
  *)
    echo "ERROR: Unknown fixture '$FIXTURE'" >&2
    exit 1
    ;;
esac

echo "==> Verifying fixture '$FIXTURE' (detected='$DETECTED_RUNNER', expected='$EXPECTED_RUNNER')..."
if [ "$DETECTED_RUNNER" != "$EXPECTED_RUNNER" ]; then
  echo "ERROR: Expected runner '$EXPECTED_RUNNER' for fixture '$FIXTURE', got '$DETECTED_RUNNER'" >&2
  exit 1
fi

if [ "$FIXTURE" = "make" ] && [ "${VERIFY_NO_TASK_INSTALLED:-false}" = "true" ]; then
  if command -v task >/dev/null 2>&1; then
    echo "ERROR: Expected Task CLI NOT to be installed for Make-only fixture" >&2
    exit 1
  fi
fi

cd "$FIXTURE_DIR"
"$DETECTED_RUNNER" clean >/dev/null 2>&1 || true

# Run standard CI quality gate targets using detected runner
"$DETECTED_RUNNER" lint
"$DETECTED_RUNNER" tidy
"$DETECTED_RUNNER" vuln

if [ "$DETECTED_RUNNER" = "make" ]; then
  MIN_COVERAGE=40 COVERAGE_THRESHOLD=40 make check-coverage MIN_COVERAGE=40 COVERAGE_THRESHOLD=40
else
  MIN_COVERAGE=40 COVERAGE_THRESHOLD=40 "$DETECTED_RUNNER" check-coverage
fi

"$DETECTED_RUNNER" build
test -x bin/sample
./bin/sample | grep -q "hello world (dev)"

# Validate non-default coverage-threshold enforcement (fixture actual coverage is 50.0%)
if [ "$DETECTED_RUNNER" = "make" ]; then
  if MIN_COVERAGE=90 make check-coverage >/dev/null 2>&1; then
    echo "ERROR: Expected make check-coverage to fail when MIN_COVERAGE=90 in env" >&2
    exit 1
  fi
  if COVERAGE_THRESHOLD=90 make check-coverage >/dev/null 2>&1; then
    echo "ERROR: Expected make check-coverage to fail when COVERAGE_THRESHOLD=90 in env" >&2
    exit 1
  fi

  # Also test a legacy Makefile that uses '=' assignment for COVERAGE_THRESHOLD
  # and does not reference MIN_COVERAGE, verifying CLI arg override enforcement.
  TMP_MAKEFILE=$(mktemp)
  cat > "$TMP_MAKEFILE" <<'EOF'
POWERWORD = ../mock-powerword.sh
COVERAGE_THRESHOLD = 50

.PHONY: test check-coverage
test:
	go test -v -race -covermode=atomic -coverprofile=coverage.out -coverpkg=./... ./...
check-coverage: test
	$(POWERWORD) check-coverage $(COVERAGE_THRESHOLD) coverage.out
EOF
  if MIN_COVERAGE=90 COVERAGE_THRESHOLD=90 make -f "$TMP_MAKEFILE" check-coverage MIN_COVERAGE=90 COVERAGE_THRESHOLD=90 >/dev/null 2>&1; then
    rm -f "$TMP_MAKEFILE"
    echo "ERROR: Expected legacy Makefile check-coverage to fail with CLI COVERAGE_THRESHOLD=90" >&2
    exit 1
  fi
  rm -f "$TMP_MAKEFILE"
else
  if MIN_COVERAGE=90 "$DETECTED_RUNNER" check-coverage >/dev/null 2>&1; then
    echo "ERROR: Expected task check-coverage to fail when MIN_COVERAGE=90" >&2
    exit 1
  fi
  if COVERAGE_THRESHOLD=90 "$DETECTED_RUNNER" check-coverage >/dev/null 2>&1; then
    echo "ERROR: Expected task check-coverage to fail when COVERAGE_THRESHOLD=90" >&2
    exit 1
  fi
fi

# Verify partial fixture warning annotation and fallback semantics
if [ "$FIXTURE" = "task-partial" ]; then
  TMP_OUT=$(mktemp)
  WARN_LOG=$(GITHUB_OUTPUT="$TMP_OUT" BUILD_RUNNER=auto TASKFILE_NAME=Taskfile.yml "$DETECT_SCRIPT")
  rm -f "$TMP_OUT"
  printf '%s\n' "$WARN_LOG" | grep -q "::warning::Taskfile.yml found but missing required contract task(s) (all, check-coverage); falling back to Makefile"
fi

# Verify additional setup-build-runner modes and failure conditions when task is installed
if [ "$FIXTURE" = "task" ]; then
  TMP_OUT=$(mktemp)

  # 1. Explicit build-runner=make skips Task and selects make even when Taskfile.yml exists
  : > "$TMP_OUT"
  GITHUB_OUTPUT="$TMP_OUT" BUILD_RUNNER=make "$CHECK_SCRIPT"
  grep -q "^install-task=false$" "$TMP_OUT"
  : > "$TMP_OUT"
  GITHUB_OUTPUT="$TMP_OUT" BUILD_RUNNER=make "$DETECT_SCRIPT" >/dev/null
  grep -q "^runner=make$" "$TMP_OUT"

  # 2. Explicit build-runner=task selects task when Taskfile.yml exists
  : > "$TMP_OUT"
  GITHUB_OUTPUT="$TMP_OUT" BUILD_RUNNER=task "$CHECK_SCRIPT"
  grep -q "^install-task=true$" "$TMP_OUT"
  : > "$TMP_OUT"
  GITHUB_OUTPUT="$TMP_OUT" BUILD_RUNNER=task TASKFILE_NAME=Taskfile.yml "$DETECT_SCRIPT" >/dev/null
  grep -q "^runner=task$" "$TMP_OUT"

  # 3. Explicit build-runner=task fails when no Taskfile exists
  : > "$TMP_OUT"
  if (cd "$SCRIPT_DIR/go-make-fixture" && GITHUB_OUTPUT="$TMP_OUT" BUILD_RUNNER=task "$DETECT_SCRIPT" >/dev/null 2>&1); then
    rm -f "$TMP_OUT"
    echo "ERROR: Expected build-runner=task to fail when Taskfile is missing" >&2
    exit 1
  fi

  # 4. build-runner=auto fails when Taskfile is partial and no Makefile exists
  TMP_NO_MAKE=$(mktemp -d)
  cp "$SCRIPT_DIR/go-partial-fixture/Taskfile.yml" "$TMP_NO_MAKE/Taskfile.yml"
  : > "$TMP_OUT"
  if (cd "$TMP_NO_MAKE" && GITHUB_OUTPUT="$TMP_OUT" BUILD_RUNNER=auto TASKFILE_NAME=Taskfile.yml "$DETECT_SCRIPT" >/dev/null 2>&1); then
    rm -rf "$TMP_NO_MAKE" "$TMP_OUT"
    echo "ERROR: Expected build-runner=auto to fail when partial Taskfile has no Makefile fallback" >&2
    exit 1
  fi
  rm -rf "$TMP_NO_MAKE" "$TMP_OUT"
fi

"$DETECTED_RUNNER" clean
rm -rf .task
echo "==> Fixture '$FIXTURE' passed all runner and coverage threshold checks."
