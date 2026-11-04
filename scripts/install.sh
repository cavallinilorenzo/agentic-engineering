#!/usr/bin/env bash
#
# Links this repo's skills and agents into ~/.claude with symlinks.
#
# Usage:
#   install.sh                      show what would change, touching nothing
#   install.sh --apply              create the links
#   install.sh --apply --retire     also move superseded skills and agents away
#   install.sh --uninstall          remove the links that point into this repo
#
# Anything moved goes to ~/.claude/backups/agentic-engineering-<timestamp>.
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
CLAUDE="${HOME}/.claude"
APPLY=0
RETIRE=0
UNINSTALL=0
BACKUP="$CLAUDE/backups/agentic-engineering-$(date +%Y%m%d-%H%M%S)"

# Superseded by this repo, or dropped from the workflow.
LEGACY_SKILLS="ask-matt code-review diagnosing-bugs grill-me grill-with-docs grilling implement implement-spec improve-codebase-architecture pr setup-matt-pocock-skills to-spec to-tickets wayfinder impeccable"
LEGACY_AGENTS="code-reviewer.md security-auditor.md test-engineer.md web-performance-auditor.md impeccable-asset-producer.md impeccable-documenter.md impeccable-finish-reviewer.md impeccable-manual-edit-applier.md"

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --retire) RETIRE=1 ;;
    --uninstall) UNINSTALL=1 ;;
    *)
      sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//' >&2
      exit 2
      ;;
  esac
  shift
done

move_away() {
  if [ "$APPLY" = 1 ] || [ "$UNINSTALL" = 1 ]; then
    mkdir -p "$BACKUP/$2"
    mv "$1" "$BACKUP/$2/"
    echo "moved  $1 -> $BACKUP/$2/"
  else
    echo "would move $1 -> $BACKUP/$2/"
  fi
}

link() {
  local target="$1" dest="$2" kind="$3"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$target" ]; then
    echo "ok     $dest"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    move_away "$dest" "$kind"
  fi
  if [ "$APPLY" = 1 ]; then
    mkdir -p "$(dirname "$dest")"
    ln -s "$target" "$dest"
    echo "linked $dest"
  else
    echo "would link $dest -> $target"
  fi
}

unlink_ours() {
  local dest="$1"
  if [ -L "$dest" ]; then
    case "$(readlink "$dest")" in
      "$ROOT"/*)
        rm "$dest"
        echo "removed $dest"
        ;;
    esac
  fi
}

if [ "$UNINSTALL" = 1 ]; then
  for dir in "$ROOT"/skills/*/; do
    unlink_ours "$CLAUDE/skills/$(basename "$dir")"
  done
  for file in "$ROOT"/agents/*.md; do
    unlink_ours "$CLAUDE/agents/$(basename "$file")"
  done
  exit 0
fi

if [ "$RETIRE" = 1 ]; then
  for name in $LEGACY_SKILLS; do
    dest="$CLAUDE/skills/$name"
    if [ -e "$dest" ] || [ -L "$dest" ]; then move_away "$dest" skills; fi
  done
  for name in $LEGACY_AGENTS; do
    dest="$CLAUDE/agents/$name"
    if [ -e "$dest" ] || [ -L "$dest" ]; then move_away "$dest" agents; fi
  done
fi

for dir in "$ROOT"/skills/*/; do
  name="$(basename "$dir")"
  link "$ROOT/skills/$name" "$CLAUDE/skills/$name" skills
done
for file in "$ROOT"/agents/*.md; do
  name="$(basename "$file")"
  link "$ROOT/agents/$name" "$CLAUDE/agents/$name" agents
done

if [ "$APPLY" = 0 ]; then
  echo
  echo "Nothing changed. Run with --apply to do this."
fi
