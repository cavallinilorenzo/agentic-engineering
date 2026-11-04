#!/usr/bin/env bash
# install.sh against a throwaway HOME.
set -u
ROOT="$(pwd -P)"
T="$(mktemp -d)" || exit 1
trap 'case "$T" in */tmp.*) rm -rf "$T" ;; esac' EXIT
fail=0
check() { if eval "$2"; then :; else echo "FAIL: $1"; fail=1; fi; }
run() { HOME="$T/home" bash "$ROOT/scripts/install.sh" "$@" >"$T/out" 2>&1; }

mkdir -p "$T/home/.claude/skills/grill" "$T/home/.claude/skills/wayfinder" "$T/home/.claude/agents"
echo mine >"$T/home/.claude/skills/grill/SKILL.md"
ln -s /nonexistent "$T/home/.claude/skills/tdd"
echo keep >"$T/home/.claude/agents/code-reviewer.md"

run
check "dry run links nothing" '[ ! -L "$T/home/.claude/skills/spec" ]'
check "dry run keeps existing" 'grep -q mine "$T/home/.claude/skills/grill/SKILL.md"'

run --apply
check "links a skill" '[ "$(readlink "$T/home/.claude/skills/spec")" = "$ROOT/skills/spec" ]'
check "links an agent" '[ "$(readlink "$T/home/.claude/agents/reviewer.md")" = "$ROOT/agents/reviewer.md" ]'
check "replaces a colliding dir with a link" '[ -L "$T/home/.claude/skills/grill" ]'
check "backs up a colliding dir" 'grep -q mine "$T"/home/.claude/backups/*/skills/grill/SKILL.md'
check "replaces a dangling link" '[ "$(readlink "$T/home/.claude/skills/tdd")" = "$ROOT/skills/tdd" ]'
check "leaves legacy alone without --retire" '[ -d "$T/home/.claude/skills/wayfinder" ]'

run --apply
check "second run is idempotent" '! grep -q "^moved" "$T/out"'

sleep 1
run --apply --retire
check "retire moves legacy skill" '[ ! -e "$T/home/.claude/skills/wayfinder" ]'
check "retire moves legacy agent" '[ ! -e "$T/home/.claude/agents/code-reviewer.md" ]'
check "retire keeps a backup" 'ls "$T"/home/.claude/backups/*/agents/code-reviewer.md >/dev/null 2>&1'

mkdir -p "$T/home/.claude/skills/other"
run --uninstall
check "uninstall removes our links" '[ ! -e "$T/home/.claude/skills/spec" ]'
check "uninstall keeps the rest" '[ -d "$T/home/.claude/skills/other" ]'

[ "$fail" = 0 ] && echo "ok: install"
exit "$fail"
