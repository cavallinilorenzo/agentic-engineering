---
name: ask
description: "Ask which skill fits your situation, what comes next, or how the workflow works."
disable-model-invocation: true
---

# Ask

The user cannot remember every skill, so they ask. Answer in the user's language.

Before saying what a skill does or recommending that a step be skipped, read that skill's `SKILL.md`: the summaries here are for orientation.

## Steps

1. **Without a question:** look at where the user is, then recommend. Read `git status`, the current branch, `git rev-parse --git-dir`, and `gh pr view` if a PR exists. Check for a receipt at `$(git rev-parse --git-path verification-receipt.md)`.
2. **Recommend one next command,** with one sentence on why and the alternative that would change your mind. Give the whole map only when asked.

Done when the user has one next action, or their question about the workflow is answered with a pointer to the skill that owns it.

## The map

| Phase | Command | Reach for it when |
|---|---|---|
| Define | `/fog` | Total fog: too big or too unclear for one session |
| | `/grill` | You know a little; an interview will sharpen it |
| | `/spec` | You know what you want: write down what and why |
| Plan | `/plan` | Decide how, in what order, with what risk |
| Build | `/build` | One ticket, test-first, in a worktree |
| | `/swarm` | At least three independent tickets in parallel |
| | `/fix` | Something is broken or slow |
| | `/ui` | A screen, redesign or polish |
| Verify | `/verify` | Prove it works (runs by itself after build and fix) |
| Review | `/judge` | An independent verdict (runs by itself in ship) |
| | `/explain` | Understand a PR, yours or someone else's |
| Ship | `/ship` | Open the PR |
| | `/release` | Deliver a version to people |
| Repo | `/setup` | Once per repo, before anything else |
| Upkeep | `/triage` | Issues arrived that you did not write |
| | `/arch` | A spare moment to deepen the codebase's modules |
| | `/retro` | A session went badly: improve the environment |
| Context | `/handoff` | Work moves to another harness, folder or person |
| Help | `/ask` | You do not know what comes next |

Internal, called by the others but also typeable: `tdd`, `risk`, `research`, `prototype`, `domain-modeling`, `codebase-design`, `writing-for-agents`.

## The usual routes

- **Bug:** `/fix` → `/ship` → `/explain`
- **Small and clear:** `/build` → `/ship` → `/explain`
- **Feature:** `/grill` → `/spec` → `/plan` → `/build` per ticket → `/ship` → `/explain`
- **Fog:** `/fog` over many sessions → `/spec` → `/plan` → `/build` or `/swarm`
- **Someone else's PR:** `/explain <number>`
- **Issues piling up:** `/triage` → `/build`
- **New repo:** `/setup` first

## Rules of thumb

- Start one fresh session per ticket: the ticket holds the context.
- Reach for a subagent when work would flood the main context, needs an independent judgement, is truly parallel, or needs restricted tools. Conversation, sequential steps and small edits stay in the main session.
- Run several agents only as far as you can still review what they produce.
- Between phases, read [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) to choose among continuing, `/clear`, `/compact`, `/handoff` and a subagent.
