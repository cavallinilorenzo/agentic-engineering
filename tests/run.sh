#!/usr/bin/env bash
# Runs every check for this repo. Exits non-zero on the first failing suite.
set -u
cd "$(dirname "$0")/.." || exit 1
status=0
for suite in tests/test-*.sh; do
  echo "== $suite"
  bash "$suite" || status=1
done
exit "$status"
