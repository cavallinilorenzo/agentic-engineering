---
name: spec
description: "Turn the current conversation into a spec of what to build and why, published to the issue tracker."
disable-model-invocation: true
---

# Spec

Synthesise what the conversation already knows: the **what** and the **why**. The how belongs to `/plan`. If a question remains that only the user can answer, ask it; everything else you can look up.

The issue tracker should have been provided to you. If not, tell the user to run `/setup`.

## Steps

1. Read enough of the repo to use its domain vocabulary (`GLOSSARY.md` or legacy `CONTEXT.md`) and to respect ADRs in the area.
2. Write the spec with the template below. Every acceptance criterion must be something an outsider could check by using the product.
3. Publish it to the tracker with the `ready-for-agent` label.

Done when the issue exists and its URL is shown. Finish by telling the user the next step: `/plan <issue>`, or `/build <issue>` when the change is obvious.

## Template

```markdown
## Problem
The problem from the user's perspective.

## Solution
The solution from the user's perspective.

## User stories
1. As a <actor>, I want <feature>, so that <benefit>
(Extensive, numbered, covering every aspect of the feature.)

## Acceptance criteria
- [ ] Observable behaviour, checkable from outside the code.

## Out of scope
What this deliberately leaves out.

## Notes
Constraints, and links to prototypes, research or the map that produced this.
```

Leave out file paths and implementation. They go stale, and they belong to the plan.
