#!/usr/bin/env sh
set -eu

SUBCMD="${1:-}"
case "$SUBCMD" in
  lint-go|vuln)
    echo "[mock-powerword] $SUBCMD ok"
    exit 0
    ;;
  check-coverage)
    MIN_COV="${2:?missing minimum coverage threshold}"
    PROFILE="${3:?missing coverage profile path}"
    if [ ! -f "$PROFILE" ]; then
      echo "[mock-powerword] coverage profile not found: $PROFILE" >&2
      exit 1
    fi
    TOTAL_PCT=$(go tool cover -func="$PROFILE" | awk '/^total:/ {gsub(/%/, "", $3); print $3}')
    if [ -z "$TOTAL_PCT" ]; then
      echo "[mock-powerword] failed to parse total coverage from $PROFILE" >&2
      exit 1
    fi
    if awk -v actual="$TOTAL_PCT" -v min="$MIN_COV" 'BEGIN { exit !(actual + 0 >= min + 0) }'; then
      echo "[mock-powerword] PASS: coverage ${TOTAL_PCT}% >= ${MIN_COV}%"
      exit 0
    else
      echo "[mock-powerword] FAIL: coverage ${TOTAL_PCT}% < ${MIN_COV}%" >&2
      exit 1
    fi
    ;;
  *)
    echo "[mock-powerword] unknown subcommand: $SUBCMD" >&2
    exit 1
    ;;
esac
