---
name: slice
description: "Decide how to build a spec: design decisions, risk, dependency order and vertical slices, with no code written."
disable-model-invocation: true
---

# Slice

Turn a spec, an issue or the conversation into the **how**. Read and think only: the sole outputs are the plan and any research or prototype it needs.

The issue tracker should have been provided to you. If not, tell the user to run `/setup`.

## Steps

1. **Load.** Fetch the reference the user passed, with its comments. Read the code it touches, `GLOSSARY.md` and ADRs in the area.
2. **Find the gaps.** A missing fact goes to the `research` skill. A question about how something feels or looks goes to the `prototype` skill. A choice only the user can make goes to the `grill` skill.
3. **Decide the design.** Name the data shape first, then the modules, interfaces and seams. Prefer existing seams, and the highest one that works. Use the `codebase-design` skill when an interface is in question. Draft a hard-to-reverse decision as an ADR, and a resolved term as a glossary entry, with the `domain-modeling` skill. Keep the drafts as text: do not write them into the repo, and open no branch or PR for them.
4. **Classify.** Call the Skill tool with `risk`, and state the result.
5. **Order the work.** Map what depends on what, and put any prefactoring first: make the change easy, then make the easy change.
6. **Slice vertically.** Each slice is a tracer bullet: a narrow but complete path through every layer, demoable alone, sized to one fresh context window and one reviewable PR. A wide refactor is the exception: sequence it as expand, migrate in batches, contract, keeping CI green between batches.
7. **Quiz the user.** Show the design decisions and the numbered slices with what each delivers, its blockers and how it will be verified. Ask whether the granularity is right, whether each blocker truly gates, and whether anything should merge or split. Iterate until approved.
8. **Publish.**
   - One slice: post the plan as a comment on the issue.
   - Several slices: one ticket per slice in dependency order, blockers first, using the tracker's native blocking links, labelled `ready-for-agent`. Each ticket is a sub-issue of the spec when the tracker supports it.
   - ADR and glossary drafts go in the ticket of the first slice that depends on them, under `## Docs to record`, and every ticket that relies on a decision restates it in prose. `/build` commits them with that slice, so the plan needs no docs-only PR and no merge before building.

Done when every acceptance criterion of the spec is covered by a slice, and every slice has its own verification. Finish by telling the user the next step: `/build <ticket>`, or `/swarm <spec>` to build every ticket, in dependency order, onto one branch.

## Ticket template

```markdown
## Parent
Reference to the spec.

## What to build
The end-to-end behaviour, from the user's perspective.

## Acceptance criteria
- [ ] Criterion

## How to verify
The command or real interaction that proves it.

## Risk
<level> (<reason>)

## Docs to record
Optional. ADR or glossary text this slice commits.

## Blocked by
References, or "None".
```

Keep file paths and code out of tickets, except a snippet from a prototype that encodes a decision better than prose.
