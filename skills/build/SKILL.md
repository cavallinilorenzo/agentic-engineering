---
name: build
description: "Implement one ticket or small spec test-first in its own worktree, then verify it."
disable-model-invocation: true
---

# Build

One ticket, one worktree, one branch, one PR. Start from a fresh session: the ticket holds the context.

Talk to the user in their language. Commits, PR text, issue text and code stay in English.

## Steps

1. **Load the work, and check it may start.** If the user passed a reference, fetch it with its comments, labels, assignee and blocking links, and state its title. Otherwise use the conversation. Stop **now**, before any worktree, if a comment or label says the ticket is not approved, on hold, blocked or waiting for a decision, or if a blocker is still open. Quote the line, give one recommendation, and wait. A ticket that passes this check is not questioned again later.
2. **Enter a worktree.** You are in one when `git rev-parse --git-dir` differs from `git rev-parse --git-common-dir`. Otherwise use the harness's worktree tool, or:
   ```bash
   git fetch origin
   git worktree add -b <type>/<topic> .claude/worktrees/<topic> origin/<default-branch>
   ```
   Then work from that folder and run the `setup` line of `docs/agents/engineering.md` to prepare dependencies. `<type>` is `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf` or `ci`.
3. **Build test-first.** Call the Skill tool with `tdd`, using the seams the plan agreed. Typecheck and run single test files as you go. Run the full suite once at the end. For interface work, use the `ui` skill.
4. **Commit** small logical steps with Conventional Commit messages in English.
5. **Verify.** Dispatch the `verifier` agent. On failure, fix and dispatch it again.

Done when the receipt's `Commit:` line equals `HEAD`, every acceptance criterion is observed or listed under **Not verified**, and the worktree is clean. Finish by telling the user the next step: `/ship`.

Keep going on your own between steps: wait for the verifier without narrating the wait, and ask the user only when something cannot be decided from the ticket, the repo or the skills. If the work grows past one reviewable PR, say so in one line and carry on; the user decides how to split.
