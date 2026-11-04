#!/usr/bin/env bash
#
# Removes worktrees under <repo>/.claude/worktrees whose pull request is done.
# When anything is uncertain, the worktree stays.
#
# Usage:
#   clean-worktrees.sh [--dry-run] [repo]           one repo (default: current)
#   clean-worktrees.sh [--dry-run] --all <folder>   every repo found in a folder
#
# A branch worktree is removed only when its PR is merged and HEAD equals the
# merged PR head. A review worktree (pr-<number>) is removed when the PR is
# merged or closed and HEAD belongs to the PR. Either way it must be clean,
# unlocked, and not the working directory of any process.
set -u

DRY_RUN=0
ALL_ROOT=""
REPO=""
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agentic-engineering"
LOG_FILE="$LOG_DIR/clean-worktrees.log"

log() {
  printf '%s\n' "$1"
  mkdir -p "$LOG_DIR" 2>/dev/null &&
    printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$1" >>"$LOG_FILE" 2>/dev/null
  return 0
}

die_usage() {
  sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --all)
      [ $# -ge 2 ] || die_usage
      ALL_ROOT="$2"
      shift
      ;;
    -h | --help) die_usage ;;
    -*) die_usage ;;
    *) REPO="$1" ;;
  esac
  shift
done

in_use() {
  command -v lsof >/dev/null 2>&1 || return 0
  lsof -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | awk -v wt="$1" '
    $0 == wt || index($0, wt "/") == 1 { found = 1 }
    END { exit found ? 0 : 1 }'
}

is_clean() {
  local status
  status="$(git -C "$1" status --porcelain --ignore-submodules=none 2>/dev/null)" || return 1
  [ -z "$status" ]
}

is_default_branch() {
  local default
  default="$(git -C "$1" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
  case "$2" in
    main | master | "${default#origin/}") return 0 ;;
  esac
  return 1
}

branch_pr_is_merged_at() {
  (cd "$1" && gh pr list --head "$2" --state merged --limit 30 \
    --json headRefOid --jq '.[].headRefOid' 2>/dev/null) | grep -qx "$3"
}

review_pr_is_done_at() {
  local state
  state="$(cd "$1" && gh pr view "$2" --json state --jq '.state' 2>/dev/null)" || return 1
  case "$state" in
    MERGED | CLOSED) ;;
    *) return 1 ;;
  esac
  (cd "$1" && gh pr view "$2" --json commits --jq '.commits[].oid' 2>/dev/null) | grep -qx "$3"
}

consider() {
  local repo="$1" wt="$2" head="$3" branch="$4" locked="$5"
  local prefix="$repo/.claude/worktrees/" name
  case "$wt" in
    "$prefix"*) ;;
    *) return 0 ;;
  esac
  name="${wt#"$prefix"}"

  if [ "$locked" = 1 ]; then log "keep $wt: locked"; return 0; fi
  [ -d "$wt" ] || return 0
  if ! is_clean "$wt"; then log "keep $wt: uncommitted changes"; return 0; fi

  case "$name" in
    pr-[0-9]*)
      local number="${name#pr-}"
      case "$number" in *[!0-9]*) log "keep $wt: unknown name"; return 0 ;; esac
      if ! review_pr_is_done_at "$repo" "$number" "$head"; then
        log "keep $wt: PR #$number still open, unknown, or HEAD outside it"
        return 0
      fi
      ;;
    *)
      if [ -z "$branch" ]; then log "keep $wt: detached HEAD"; return 0; fi
      if is_default_branch "$repo" "$branch"; then log "keep $wt: default branch"; return 0; fi
      if ! branch_pr_is_merged_at "$repo" "$branch" "$head"; then
        log "keep $wt: no merged PR at this commit"
        return 0
      fi
      ;;
  esac

  if in_use "$wt"; then log "keep $wt: in use"; return 0; fi

  if [ "$DRY_RUN" = 1 ]; then log "would remove $wt"; return 0; fi

  # Git refuses to remove a worktree with submodules without --force.
  # The tree was verified clean above, submodules included.
  if [ -f "$wt/.gitmodules" ]; then
    git -C "$repo" worktree remove --force "$wt" || { log "keep $wt: git refused"; return 0; }
  else
    git -C "$repo" worktree remove "$wt" || { log "keep $wt: git refused"; return 0; }
  fi
  # -D because a squash merge never looks merged to git. HEAD was matched above.
  [ -n "$branch" ] && git -C "$repo" branch -D "$branch" >/dev/null 2>&1
  log "removed $wt"
}

clean_repo() {
  local repo="$1" line wt="" head="" branch="" locked=0 top
  top="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null)" || return 0
  repo="$(cd "$top" && pwd -P)"
  [ -d "$repo/.claude/worktrees" ] || return 0
  command -v gh >/dev/null 2>&1 || { log "skip $repo: gh not installed"; return 0; }
  git -C "$repo" worktree prune

  while IFS= read -r line; do
    case "$line" in
      "worktree "*) wt="${line#worktree }" ;;
      "HEAD "*) head="${line#HEAD }" ;;
      "branch refs/heads/"*) branch="${line#branch refs/heads/}" ;;
      "locked" | "locked "*) locked=1 ;;
      "")
        [ -n "$wt" ] && consider "$repo" "$wt" "$head" "$branch" "$locked" </dev/null
        wt="" head="" branch="" locked=0
        ;;
    esac
  done < <(git -C "$repo" worktree list --porcelain; echo)
}

if [ -n "$ALL_ROOT" ]; then
  find "$ALL_ROOT" -maxdepth 6 \
    \( -name node_modules -o -name target -o -name .venv -o -name .git \) -prune -o \
    -type d -path '*/.claude/worktrees' -print -prune 2>/dev/null |
    while IFS= read -r dir; do
      clean_repo "${dir%/.claude/worktrees}" </dev/null
    done
else
  clean_repo "${REPO:-.}"
fi
exit 0
