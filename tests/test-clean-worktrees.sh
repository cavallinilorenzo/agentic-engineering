#!/usr/bin/env bash
# clean-worktrees.sh against real git repos and a stub of gh.
set -u
ROOT="$(pwd -P)"
T="$(mktemp -d)" || exit 1
T="$(cd "$T" && pwd -P)" || exit 1
trap 'kill $HOLD 2>/dev/null; case "$T" in */tmp.*) rm -rf "$T" ;; esac' EXIT
HOLD=0
fail=0
export HOME="$T/home" XDG_STATE_HOME="$T/state"
mkdir -p "$HOME" "$T/bin"
git config --global user.email test@example.invalid
git config --global user.name test
git config --global init.defaultBranch main
git config --global protocol.file.allow always

# Stub: answers from files. merged/<branch> holds merged head oids;
# state/<n> a PR state; commits/<n> its commit oids; "offline" fails everything.
cat >"$T/bin/gh" <<STUB
#!/usr/bin/env bash
[ -e "$T/offline" ] && exit 1
case "\$1 \$2" in
  "pr list")
    while [ \$# -gt 0 ]; do [ "\$1" = "--head" ] && b="\$2"; shift; done
    cat "$T/merged/\$(echo "\$b" | tr / _)" 2>/dev/null
    ;;
  "pr view")
    n="\$3"
    case "\$*" in
      *"json state"*) cat "$T/state/\$n" 2>/dev/null || exit 1 ;;
      *"json commits"*) cat "$T/commits/\$n" 2>/dev/null ;;
    esac
    ;;
esac
STUB
chmod +x "$T/bin/gh"
export PATH="$T/bin:$PATH"
mkdir -p "$T/merged" "$T/state" "$T/commits"

R="$T/repo"
git init -q "$R"
git -C "$R" commit -q --allow-empty -m init
mkdir -p "$R/.claude/worktrees"
printf '.claude/worktrees/\nignored.txt\n' >"$R/.gitignore"
git -C "$R" add .gitignore && git -C "$R" commit -q -m ignore

add() { # name branch
  git -C "$R" worktree add -q -b "$2" "$R/.claude/worktrees/$1" main
  git -C "$R/.claude/worktrees/$1" commit -q --allow-empty -m "work on $1"
}
merged() { # name branch
  git -C "$R/.claude/worktrees/$1" rev-parse HEAD >"$T/merged/$(echo "$2" | tr / _)"
}
gone() { if [ -e "$R/.claude/worktrees/$1" ]; then echo "FAIL: $2"; fail=1; fi; }
kept() { if [ ! -d "$R/.claude/worktrees/$1" ]; then echo "FAIL: $2"; fail=1; fi; }
branch_gone() { if git -C "$R" rev-parse -q --verify "refs/heads/$1" >/dev/null; then echo "FAIL: $2"; fail=1; fi; }
branch_kept() { if ! git -C "$R" rev-parse -q --verify "refs/heads/$1" >/dev/null; then echo "FAIL: $2"; fail=1; fi; }
run() { bash "$ROOT/scripts/clean-worktrees.sh" "$@" >"$T/out" 2>&1; }

add merged-clean feat/merged-clean; merged merged-clean feat/merged-clean
echo x >"$R/.claude/worktrees/merged-clean/ignored.txt"
add merged-dirty feat/merged-dirty; merged merged-dirty feat/merged-dirty
echo x >"$R/.claude/worktrees/merged-dirty/untracked.txt"
add merged-staged feat/merged-staged; merged merged-staged feat/merged-staged
echo x >"$R/.claude/worktrees/merged-staged/staged.txt"; git -C "$R/.claude/worktrees/merged-staged" add staged.txt
add merged-ahead feat/merged-ahead; merged merged-ahead feat/merged-ahead
git -C "$R/.claude/worktrees/merged-ahead" commit -q --allow-empty -m "after the merge"
add not-merged feat/not-merged
add locked feat/locked; merged locked feat/locked; git -C "$R" worktree lock "$R/.claude/worktrees/locked"
add busy feat/busy; merged busy feat/busy
(cd "$R/.claude/worktrees/busy" && exec sleep 300) & HOLD=$!
sleep 1
git -C "$R" worktree add -q --detach "$R/.claude/worktrees/detached" main
git -C "$R" worktree add -q -b feat/outside "$T/outside" main
git -C "$T/outside" rev-parse HEAD >"$T/merged/feat_outside"

# Review worktrees.
git -C "$R" worktree add -q --detach "$R/.claude/worktrees/pr-7" main
git -C "$R" rev-parse main >"$T/commits/7"; echo MERGED >"$T/state/7"
git -C "$R" worktree add -q --detach "$R/.claude/worktrees/pr-8" main
git -C "$R" rev-parse main >"$T/commits/8"; echo OPEN >"$T/state/8"
git -C "$R" worktree add -q --detach "$R/.claude/worktrees/pr-9" main
git -C "$R/.claude/worktrees/pr-9" commit -q --allow-empty -m "local note"
git -C "$R" rev-parse main >"$T/commits/9"; echo CLOSED >"$T/state/9"

# Offline: nothing may go.
touch "$T/offline"; run "$R"; rm "$T/offline"
kept merged-clean "offline: must keep everything"

# Dry run: nothing may go.
run --dry-run "$R"
kept merged-clean "dry run must keep the worktree"
grep -q "would remove .*merged-clean" "$T/out" || { echo "FAIL: dry run must report"; fail=1; }

run "$R"
gone merged-clean "merged, clean: removed (ignored files do not block)"
branch_gone feat/merged-clean "merged, clean: local branch removed"
kept merged-dirty "untracked file: kept"
kept merged-staged "staged change: kept"
kept merged-ahead "commit after the merge: kept"
branch_kept feat/merged-ahead "commit after the merge: branch kept"
kept not-merged "PR not merged: kept"
kept locked "locked: kept"
kept busy "process inside: kept"
kept detached "detached, not a review worktree: kept"
[ -d "$T/outside" ] || { echo "FAIL: outside .claude/worktrees: kept"; fail=1; }
gone pr-7 "review worktree of a merged PR: removed"
kept pr-8 "review worktree of an open PR: kept"
kept pr-9 "review worktree with a local commit: kept"
# pr-9 is listed last: this proves the final entry is evaluated, not skipped.
grep -q "keep .*pr-9" "$T/out" || { echo "FAIL: last worktree in the list was not evaluated"; fail=1; }

kill "$HOLD" 2>/dev/null; wait "$HOLD" 2>/dev/null
run "$R"
gone busy "after the process exits: removed"

# --all finds repos; a branch merged from a submodule-bearing worktree goes too.
S="$T/root/group/sub"; mkdir -p "$T/root/group"
git init -q "$T/lib"; git -C "$T/lib" commit -q --allow-empty -m lib
git init -q "$S"; git -C "$S" commit -q --allow-empty -m init
printf '.claude/worktrees/\n' >"$S/.gitignore"
git -C "$S" submodule --quiet add "$T/lib" lib
git -C "$S" add . && git -C "$S" commit -q -m sub
mkdir -p "$S/.claude/worktrees"
git -C "$S" worktree add -q -b feat/with-sub "$S/.claude/worktrees/with-sub" main
git -C "$S/.claude/worktrees/with-sub" submodule --quiet update --init
git -C "$S/.claude/worktrees/with-sub" rev-parse HEAD >"$T/merged/feat_with-sub"
run --all "$T/root"
if [ -e "$S/.claude/worktrees/with-sub" ]; then echo "FAIL: --all with submodules: removed"; cat "$T/out"; fail=1; fi

[ "$fail" = 0 ] && echo "ok: clean-worktrees"
exit "$fail"
