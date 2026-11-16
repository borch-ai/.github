#!/usr/bin/env sh
set -eu

BUILD_RUNNER="${BUILD_RUNNER:-auto}"
case "$BUILD_RUNNER" in
  auto|make|task) ;;
  *)
    echo "::error::Invalid build-runner '$BUILD_RUNNER' (must be auto, make, or task)"
    exit 1
    ;;
esac

TASKFILE_NAME=""
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

echo "taskfile=$TASKFILE_NAME" >> "$GITHUB_OUTPUT"
if [ "$BUILD_RUNNER" = "task" ] || { [ "$BUILD_RUNNER" = "auto" ] && [ -n "$TASKFILE_NAME" ]; }; then
  echo "install-task=true" >> "$GITHUB_OUTPUT"
else
  echo "install-task=false" >> "$GITHUB_OUTPUT"
fi

