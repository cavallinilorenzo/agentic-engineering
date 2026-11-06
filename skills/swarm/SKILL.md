---
name: swarm
description: "Build every ticket of a spec, following the blocking links, each in its own worktree, onto one integration branch."
disable-model-invocation: true
---

# Swarm

The tickets are a **task graph** with a **frontier** of ready tickets. You orchestrate; fresh implementer subagents build.

Tickets that block each other run in order: finishing one widens the frontier. Independent ones run in parallel. A chain with one ready ticket is fine: it runs alone, then the tickets it unblocks follow.

The result is one integration branch and one PR for the whole spec.

The issue tracker should have been provided to you. If not, tell the user to run `/setup`.

Talk to the user in their language. Commits, PR text, issue text and code stay in English.

## Steps

1. **Read the graph.** Read the spec and tickets. A blocking link needs a proven reason: two frontier tickets that edit the same file, or one consuming the other's output. Sequence on that evidence only; every other pair runs in parallel.
2. **Explore once, if needed**, in the same turn as step 4's first implementer, never ahead of it. A cheap subagent (`model: sonnet`) saves notes outside the repo; implementers start from pointers and read the notes when they exist.
3. **Create the integration branch** `feat/<topic>` from the default branch, in a worktree.
4. **Run the frontier.** At most two implementers at a time unless the user asks for more. Each is a fresh background subagent with `isolation: worktree`, briefed through pointers to the spec, ticket and notes, which:
   - confirms its worktree is based on the integration branch, and resets onto it if not;
   - follows the `tdd` skill, then runs the fast checks from `engineering.md` (format, lint, tests), with no `verify` and no receipt;
   - commits after every green cycle, so a limit or crash loses minutes, not work;
   - starts long measurements (benchmarks, soaks) in the background and ends its turn; a `Monitor` or the orchestrator resumes it when they finish;
   - merges the integration branch tip into its own branch before reporting done.
5. **Merge** each finished implementer with a merger subagent (`model: sonnet`). It resolves conflicts and runs only the checks the implementer has not already run at that commit. Each merge can widen the frontier: go back to step 4 until no ticket remains.
6. **Verify and review.** Dispatch the `verifier` agent once on the integration branch, then call the Skill tool with `judge`. One fresh implementer fixes all findings, then `verifier` runs once more.
7. **Clean up** every implementer worktree and its branch.

An implementer that dies mid-ticket (usage limit, crash) is resumed in its existing worktree: briefed with the branch and path, it continues from the last commit. Remove that worktree only after its branch is merged or the user agrees to discard it.

Done when every ticket is merged, the receipt's `Commit:` line equals `HEAD`, and no implementer worktree remains. Finish by telling the user the next step: `/ship`.
