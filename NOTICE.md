# Origin of every skill

This project is licensed under the MIT licence (see [LICENSE](LICENSE)). It reuses other people's material, credited here with commit and licence.

- **Copied:** original text. Only the names and the listed references change.
- **Reworked:** starts from one or more sources, with structure or content rewritten.
- **New:** written here. The sources are only inspiration.

## Source commits

| Key | Project | Commit | Licence |
|---|---|---|---|
| Matt | [mattpocock/skills](https://github.com/mattpocock/skills) | `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d` | MIT |
| Addy | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | `301b02b12bff98e4688e6984af6556802322bbde` | MIT |
| pstack | [cursor/plugins, pstack folder](https://github.com/cursor/plugins/tree/main/pstack) | `bb68f2365eceafa0cb2d253112f675acf5f144cc` | MIT |
| Vercel | [vercel-labs/web-interface-guidelines](https://github.com/vercel-labs/web-interface-guidelines) | `434b7f91364665f2f733b310ec54809bf8f37937` | MIT |

## Copied

| Skill | Origin | What changes |
|---|---|---|
| `grill` | Matt `productivity/grilling` | Name |
| `handoff` | Matt `productivity/handoff` | None |
| `tdd` | Matt `engineering/tdd` | Reference to `judge` |
| `research` | Matt `engineering/research` | None |
| `domain-modeling` | Matt `engineering/domain-modeling` | None |
| `codebase-design` | Matt `engineering/codebase-design` | None |
| `writing-for-agents` | Matt `productivity/writing-for-agents` | None |

Files copied inside reworked skills:

| File | Origin |
|---|---|
| `skills/ask/PHASE-BOUNDARIES.md` | Matt `engineering/ask-matt` |
| `skills/setup/domain.md`, `issue-tracker-*.md`, `triage-labels.md` | Matt `engineering/setup-matt-pocock-skills` (references to `/fog` and `/slice`; the external-PR triage sections removed) |
| `skills/ui/references/web-interface-guidelines.md` | Vercel `command.md` |

## Reworked

| Skill | Sources | What changed |
|---|---|---|
| `spec` | Matt `to-spec` | Only what and why: technical decisions move to `slice`; acceptance criteria added |
| `slice` | Matt `to-tickets`, Addy `planning-and-task-breakdown`, Matt `to-spec` | Always-present phase that combines design, risk, dependencies and slices; publishes tickets only when needed |
| `build` | Matt `implement`, Addy `incremental-implementation` | Mandatory worktree; closes with the `verifier` and the receipt |
| `fog` | Matt `engineering/wayfinder` | Name; references to `grill` and `/setup`; a ticket's resolution is written as soon as the user answers |
| `prototype` | Matt `engineering/prototype` | The agent starts the prototype and hands over its URL or path |
| `swarm` | Matt `implement-spec` | At most 2 agents at a time; Sonnet implementers; shared-file check; one final verification |
| `fix` | Matt `diagnosing-bugs`, pstack `principle-fix-root-causes` | Base copied; added root-cause rule, worktree and final verification |
| `judge` | Matt `code-review`, Addy `code-review-and-quality`, pstack `blast-radius` | Matt's separate axes, Addy's checks, a blast-radius axis; depth set by risk |
| `ship` | Matt `pr`, pstack `opening-a-pr`, Matt `implement` (fast checks often, full suite once), Addy `/ship` (parallel fan-out) | Blocking checks in cost order, verification once at the end, unified PR format, waits for green CI. Matt's `pr` cites [Dex Horthy, HumanLayer](https://github.com/humanlayer/skills) |
| `release` | Addy `shipping-and-launch` | From a general checklist to a procedure with a human go/no-go, using the repo's own mechanism |
| `setup` | Matt `setup-matt-pocock-skills`, Addy `constraint-driven-development` | Added risk, sensitive data and a proven verification recipe |
| `ask` | Matt `ask-matt` | Same idea: rewritten around this repo's flow; also looks at the repo state |

## New

| Item | Inspiration |
|---|---|
| `verify` | pstack `principle-prove-it-works`; Simon Willison, [Agentic manual testing](https://simonwillison.net/guides/agentic-engineering-patterns/agentic-manual-testing/) |
| `risk` | Certainty ladder from pstack `blast-radius`; [Cortex, risk-based code review](https://www.cortex.io/post/risk-based-code-review) |
| `explain` | Simon Willison, [Linear walkthroughs](https://simonwillison.net/guides/agentic-engineering-patterns/linear-walkthroughs/) and [Interactive explanations](https://simonwillison.net/guides/agentic-engineering-patterns/interactive-explanations/); pstack `how` |
| `ui` | Anthropic [`frontend-design`](https://github.com/anthropics/skills/tree/main/skills/frontend-design) (Apache-2.0), inspiration only; Matt `prototype`; [Emil Kowalski](https://github.com/emilkowalski/skills) (MIT), optional reference not included |
| `agents/reviewer.md`, `agents/verifier.md` | Simon Willison, [Subagents](https://simonwillison.net/guides/agentic-engineering-patterns/subagents/) |
| `scripts/` | No source |

## Licence texts

```text
MIT License

Copyright (c) 2026 Matt Pocock
Copyright (c) 2025 Addy Osmani
Copyright (c) 2026 Lauren Tan
Copyright (c) 2025 Vercel Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
