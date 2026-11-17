#!/usr/bin/env bash
# bin/cli.mjs (the npx installer) against a throwaway HOME.
set -u
ROOT="$(pwd -P)"
T="$(mktemp -d)" || exit 1
trap 'case "$T" in */tmp.*|/tmp/*|/var/folders/*) rm -rf "$T" ;; esac' EXIT
fail=0
check() { if eval "$2"; then :; else echo "FAIL: $1"; fail=1; fi; }
run() { HOME="$T/home" node "$ROOT/bin/cli.mjs" "$@" >"$T/out" 2>&1; }
H="$T/home/.claude"

if ! command -v node >/dev/null; then echo "skip: cli (no node)"; exit 0; fi

mkdir -p "$H/skills/grill" "$H/skills/wayfinder" "$H/agents" "$H/skills/mine"
echo mine >"$H/skills/grill/SKILL.md"
echo keep >"$H/agents/code-reviewer.md"
ln -s /nonexistent "$H/skills/tdd"

run --dry-run
check "dry run copies nothing" '[ ! -e "$H/skills/spec" ] && [ ! -e "$H/agentic-engineering.json" ]'
check "dry run keeps existing" 'grep -q mine "$H/skills/grill/SKILL.md"'

run
check "copies a skill" '[ -f "$H/skills/spec/SKILL.md" ] && [ ! -L "$H/skills/spec" ]'
check "copies a nested skill file" '[ -f "$H/skills/fix/scripts/hitl-loop.template.sh" ]'
check "copies an agent" '[ -f "$H/agents/reviewer.md" ]'
check "copies the worktree script" '[ -f "$H/agentic-engineering/clean-worktrees.sh" ]'
check "backs up a colliding dir" 'grep -q mine "$H"/backups/*/skills/grill/SKILL.md'
check "replaces a dangling link" '[ -f "$H/skills/tdd/SKILL.md" ] && [ ! -L "$H/skills/tdd" ]'
check "leaves legacy alone without --retire" '[ -d "$H/skills/wayfinder" ]'
check "writes the manifest" 'grep -q "\"spec\"" "$H/agentic-engineering.json"'

run
check "second run does not back up again" '! grep -q "^moved" "$T/out"'

sleep 1
run --retire
check "retire moves legacy skill" '[ ! -e "$H/skills/wayfinder" ]'
check "retire moves legacy agent" '[ ! -e "$H/agents/code-reviewer.md" ]'
check "retire keeps a backup" 'ls "$H"/backups/*/agents/code-reviewer.md >/dev/null 2>&1'

run uninstall
check "uninstall removes ours" '[ ! -e "$H/skills/spec" ] && [ ! -e "$H/agents/reviewer.md" ] && [ ! -e "$H/agentic-engineering.json" ]'
check "uninstall keeps the rest" '[ -d "$H/skills/mine" ]'

check "unknown flag fails" '! HOME="$T/home" node "$ROOT/bin/cli.mjs" --bogus >/dev/null 2>&1'
check "global and project together fail" '! HOME="$T/home" node "$ROOT/bin/cli.mjs" --global --project >/dev/null 2>&1'
check "unknown skill fails" '! HOME="$T/home" node "$ROOT/bin/cli.mjs" --skills=nope >/dev/null 2>&1'

# Project scope: only the chosen skills, only inside the repo, global untouched.
mkdir -p "$T/proj"
prun() { (cd "$T/proj" && HOME="$T/home" node "$ROOT/bin/cli.mjs" "$@") >"$T/out" 2>&1; }
prun --project --skills=spec,tdd
# shellcheck disable=SC2034  # read by the check strings below, which are eval'd
P="$T/proj/.claude"
check "project installs the chosen skills" '[ -f "$P/skills/spec/SKILL.md" ] && [ -f "$P/skills/tdd/SKILL.md" ]'
check "project skips the others" '[ ! -e "$P/skills/ship" ]'
check "project installs the agents" '[ -f "$P/agents/reviewer.md" ]'
check "project has no worktree script" '[ ! -e "$P/agentic-engineering" ]'
check "project writes its own manifest" 'grep -q "\"tdd\"" "$P/agentic-engineering.json"'
check "project leaves global alone" '[ ! -e "$H/skills/spec" ]'
prun --project --skills=spec
check "narrowing removes the skill dropped" '[ ! -e "$P/skills/tdd" ] && [ -f "$P/skills/spec/SKILL.md" ]'
prun uninstall --project
check "project uninstall removes ours" '[ ! -e "$P/skills/spec" ] && [ ! -e "$P/agentic-engineering.json" ]'

# Antigravity: skills only, in its own folders, Claude Code's untouched.
# shellcheck disable=SC2034  # read by the check strings below, which are eval'd
G="$T/home/.gemini/config"
run --tool=antigravity --global
check "antigravity installs skills globally" '[ -f "$G/skills/spec/SKILL.md" ]'
check "antigravity installs no agents" '[ ! -e "$G/agents" ]'
check "antigravity has no worktree script" '[ ! -e "$G/agentic-engineering" ]'
check "antigravity writes its own manifest" 'grep -q "\"spec\"" "$G/agentic-engineering.json"'
check "antigravity leaves Claude Code alone" '[ ! -e "$H/skills/spec" ]'
run uninstall --tool=antigravity --global
check "antigravity uninstall removes ours" '[ ! -e "$G/skills/spec" ] && [ ! -e "$G/agentic-engineering.json" ]'
prun --tool=antigravity --project --skills=spec
check "antigravity project installs in .agents" '[ -f "$T/proj/.agents/skills/spec/SKILL.md" ]'
prun uninstall --tool=antigravity --project
check "antigravity project uninstall removes ours" '[ ! -e "$T/proj/.agents/skills/spec" ]'
check "unknown tool fails" '! HOME="$T/home" node "$ROOT/bin/cli.mjs" --tool=nope >/dev/null 2>&1'

# The legacy lists live in two places; they must match.
for var in LEGACY_SKILLS LEGACY_AGENTS; do
  sh_list="$(grep "^$var=" "$ROOT/scripts/install.sh" | sed 's/^[A-Z_]*="//; s/"$//')"
  js_list="$(grep "^export const $var" "$ROOT/bin/cli.mjs" | sed 's/.*= "//; s/".*//')"
  if [ "$sh_list" = "$js_list" ]; then :; else echo "FAIL: $var matches install.sh"; fail=1; fi
done

[ "$fail" = 0 ] && echo "ok: cli"
exit "$fail"
