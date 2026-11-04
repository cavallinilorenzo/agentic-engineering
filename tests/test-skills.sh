#!/usr/bin/env bash
# Structural checks: names, descriptions, cross-references and provenance.
set -u
fail=0
bad() { echo "FAIL: $1"; fail=1; }

names=""
for dir in skills/*/; do
  name="$(basename "$dir")"
  names="$names $name"
  file="$dir/SKILL.md"
  [ -f "$file" ] || { bad "$name has no SKILL.md"; continue; }
  echo "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || bad "$name: invalid directory name"
  fm_name="$(sed -n 's/^name: //p' "$file" | head -1)"
  [ "$fm_name" = "$name" ] || bad "$name: frontmatter name is '$fm_name'"
  desc="$(sed -n 's/^description: //p' "$file" | head -1)"
  [ -n "$desc" ] || bad "$name: no description"
  [ "${#desc}" -le 1024 ] || bad "$name: description over 1024 characters"
  grep -q "\`$name\`\|\`/$name\`" README.md || bad "$name: missing from README.md"
  grep -q "\`$name\`\|\`/$name\`" NOTICE.md || bad "$name: missing from NOTICE.md"
  grep -q "\`$name\`\|\`/$name\`" skills/ask/SKILL.md || bad "$name: missing from the /ask router"
done

# Every skill reached through the Skill tool exists and is model-invoked.
refs="$(grep -rhoE 'Skill tool (twice, )?(with|for) [`"][a-z-]+[`"]( and [`"][a-z-]+[`"])?|`[a-z-]+` skill|the [`"][a-z-]+[`"] skill' skills agents | grep -oE '[`"][a-z-]+[`"]' | tr -d '`"' | sort -u)"
for ref in $refs; do
  [ "$ref" = "emil-design-eng" ] && continue
  file="skills/$ref/SKILL.md"
  if [ ! -f "$file" ]; then
    bad "reference to unknown skill: $ref"
  elif grep -q '^disable-model-invocation: true' "$file"; then
    bad "$ref is reached by other skills but is user-invoked"
  fi
done

# Agents named in skills exist.
for agent in $(grep -rhoE '`(reviewer|verifier)` agent' skills | grep -oE '(reviewer|verifier)' | sort -u); do
  [ -f "agents/$agent.md" ] || bad "reference to unknown agent: $agent"
done

# Names retired from upstream must not survive in the text.
stale="$(grep -rnE 'setup-matt-pocock|to-spec|to-tickets|implement-spec|diagnosing-bugs|improve-codebase-architecture|grill-with-docs|grill-me|ask-matt|/wayfinder|`code-review`' skills agents || true)"
[ -z "$stale" ] || bad "stale names: $stale"

# Relative links inside skills resolve.
# GLOSSARY-FORMAT.md is skipped: its links are examples of a target repo's layout.
for file in $(grep -rlE '\]\([^)h#][^)]*\.(md|sh)\)' skills | grep -v 'GLOSSARY-FORMAT.md'); do
  for link in $(grep -oE '\]\([^)h#][^)]*\.(md|sh)\)' "$file" | sed -E 's/^\]\(|\)$//g' | sed 's/#.*//'); do
    [ -e "$(dirname "$file")/$link" ] || bad "$file: broken link $link"
  done
done

[ "$fail" = 0 ] && echo "ok: skills"
exit "$fail"
