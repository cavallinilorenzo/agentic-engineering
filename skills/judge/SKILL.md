---
name: judge
description: Independent review of a diff against repo standards, its spec and, at high risk, its blast radius. Use when reviewing a branch or PR, or when /ship needs a verdict.
---

# Judge

Separate axes, each in a fresh `reviewer` agent, so no axis masks another and none inherits the author's reasoning.

Talk to the user in their language. Commits, PR text, issue text and code stay in English.

## Steps

1. **Pin the fixed point.** Default: the merge-base with the default branch. Capture `git diff <base>...HEAD` and `git log <base>..HEAD --oneline`. A bad ref or an empty diff stops here.
2. **Classify.** Call the Skill tool with `risk`. Low risk with green CI needs no judge: report that and stop.
3. **Gather sources.**
   - **Standards**: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, and any file documenting how code is written.
   - **Spec**: issues referenced by commits, a path from the user, or files matching the branch. With no spec, skip that axis and say so.
4. **Dispatch in parallel**, one `reviewer` agent per axis, passing commands and paths as pointers:
   - **Standards**, always.
   - **Spec**, when a spec exists.
   - **Blast radius**, at high risk, with `model: opus`.
5. **Second opinion, optional.** At high risk, when `engineering.md` names a `second_opinion` command and the repo is not `sensitive`, run it on the diff and report it as its own axis.
6. **Report** each axis under its own heading, findings neither merged nor reranked. End with the finding count per axis and the worst finding within each.

Done when every applicable axis has returned. Every finding carries `file:line`, its severity (`critical`, `required`, `optional`, `nit`) and how to fix it.

## Axis briefs

**Standards.** Report where the diff breaks a documented standard (cite file and rule), and any smell from the baseline below, labelled as a judgement call. A repo standard overrides the baseline. Skip what tooling enforces. Also check: correctness at edges, readability, security (input validation, secrets, authorisation), and performance (N+1 queries, unbounded work).

Smell baseline (Fowler, *Refactoring*): Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man, Refused Bequest.

**Spec.** Quote the spec line for each finding. Report requirements missing or partial; behaviour nobody asked for; requirements that look implemented but behave wrongly.

**Blast radius.** Find what the change breaks somewhere else, beyond the diff.
1. Name the **one fact** the change is safe because of.
2. Look where grep stops: the source of called libraries at their pinned version, execution timing, JSON and wire formats, database columns, flags, other languages reading the same bytes.
3. Prove the one fact by running real code. Report its level on the certainty ladder, or write `unproven`.
4. List confirmed risks with likelihood, cost and how to check. List separately what you cleared and why.

## Why the axes stay apart

Code can follow every standard and implement the wrong thing, or do exactly what was asked and break the conventions. A merged ranking lets one hide the other.
