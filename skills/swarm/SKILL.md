---
name: swarm
description: "Build every ticket of a spec, following the blocking links, each in its own worktree, onto one integration branch."
disable-model-invocation: true
---

# Swarm

The tickets are a **task graph** with a **frontier** of ready tickets. You orchestrate; fresh implementer subagents build.

Tickets that block each other run in order: finishing one widens the frontier. Independent ones run in parallel. A chain with one ready ticket is fine: it runs alone, then the tickets it unblocks follow.

The result is one integration branch and one PR for the whole spec. If the total passes the size limit of `/ship`, say so before starting and offer to split the spec.

The issue tracker should have been provided to you. If not, tell the user to run `/setup`.

## Steps

1. **Read the graph.** Read the spec and tickets. Confirm no two tickets on the frontier edit the same file. If they would, sequence them with a blocking link.
2. **Explore once, if needed.** A subagent saves notes outside the repo, so implementers start from pointers.
3. **Create the integration branch** `feat/<topic>` from the default branch, in a worktree.
4. **Run the frontier.** At most three implementers at a time unless the user asks for more. Each is a fresh background subagent with `isolation: worktree`, briefed through pointers to the spec, ticket and notes, which:
   - confirms its worktree is based on the integration branch, and resets onto it if not;
   - follows the `tdd` skill;
   - merges the integration branch tip into its own branch before reporting done.
5. **Merge** each finished implementer into the integration branch with a merger subagent. Each merge can widen the frontier: go back to step 4 until no ticket remains.
6. **Verify and review.** Dispatch the `verifier` agent on the integration branch, then call the Skill tool with `judge`. One fresh implementer fixes all findings, then verify again.
7. **Clean up** every implementer worktree and its branch.

Done when every ticket is merged, the receipt's `Commit:` line equals `HEAD`, and no implementer worktree remains. Finish by telling the user the next step: `/ship`.
