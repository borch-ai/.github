#!/usr/bin/env sh
set -eu

BUILD_RUNNER="${BUILD_RUNNER:-auto}"
TASKFILE_NAME="${TASKFILE_NAME:-}"
REQUIRED_TASKS="${REQUIRED_TASKS:-all lint tidy vuln check-coverage build}"

case "$BUILD_RUNNER" in
  auto|make|task) ;;
  *)
    echo "::error::Invalid build-runner '$BUILD_RUNNER' (must be auto, make, or task)"
    exit 1
    ;;
esac

if [ "$BUILD_RUNNER" = "make" ]; then
  echo "Selected build runner: make (explicit build-runner=make)"
  echo "runner=make" >> "$GITHUB_OUTPUT"
  exit 0
fi

if [ -z "$TASKFILE_NAME" ]; then
  for name in \
    Taskfile.yml \
    taskfile.yml \
    Taskfile.yaml \
    taskfile.yaml \
    Taskfile.dist.yml \
    taskfile.dist.yml \
    Taskfile.dist.yaml \
    taskfile.dist.yaml; do
    if [ -f "$name" ]; then
      TASKFILE_NAME="$name"
      break
    fi
  done
fi

if [ "$BUILD_RUNNER" = "task" ]; then
  if [ -z "$TASKFILE_NAME" ] || [ ! -f "$TASKFILE_NAME" ]; then
    echo "::error::build-runner is set to 'task', but no Taskfile was found in $(pwd)"
    exit 1
  fi
  echo "Selected build runner: task (explicit build-runner=task, found $TASKFILE_NAME)"
  echo "runner=task" >> "$GITHUB_OUTPUT"
  exit 0
fi

if [ -z "$TASKFILE_NAME" ] || [ ! -f "$TASKFILE_NAME" ]; then
  echo "Selected build runner: make (no Taskfile found)"
  echo "runner=make" >> "$GITHUB_OUTPUT"
  exit 0
fi

AVAILABLE_TASKS=""
if TASK_JSON=$(task --list-all --json 2>/dev/null); then
  AVAILABLE_TASKS=$(printf '%s\n' "$TASK_JSON" | jq -r '.tasks[]?.name // empty' 2>/dev/null || true)
fi

MISSING=""
for req in $REQUIRED_TASKS; do
  if ! printf '%s\n' "$AVAILABLE_TASKS" | grep -Fxq "$req"; then
    if [ -z "$MISSING" ]; then
      MISSING="$req"
    else
      MISSING="$MISSING, $req"
    fi
  fi
done

if [ -z "$MISSING" ]; then
  echo "Selected build runner: task (detected $TASKFILE_NAME)"
  echo "runner=task" >> "$GITHUB_OUTPUT"
  exit 0
fi

if [ -f "Makefile" ] || [ -f "makefile" ] || [ -f "GNUmakefile" ]; then
  echo "::warning::$TASKFILE_NAME found but missing required contract task(s) ($MISSING); falling back to Makefile"
  echo "runner=make" >> "$GITHUB_OUTPUT"
  exit 0
fi

echo "::error::$TASKFILE_NAME found but missing required contract task(s) ($MISSING) and no Makefile present"
exit 1
