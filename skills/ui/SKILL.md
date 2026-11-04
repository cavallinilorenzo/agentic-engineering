---
name: ui
description: Build or restyle an interface with a real visual loop on a token budget. Use for any new screen, redesign, or visual polish.
---

# UI

Quality comes from a clear direction, real references and looking at the result. Taste is the human's: the human picks the references and has the last word.

Budget: the direction first, then **at most three visual rounds per screen**. Each round opens two screenshots, roughly 3-5k tokens. Stop at the limit and show the user where you are.

## Steps

1. **Ground it.** Identify the subject, audience and primary job of the screen. Read `DESIGN.md` and the existing tokens and components; reuse them. With no `DESIGN.md`, derive one from the code and write it as part of this work.
2. **Get references.** Ask the user for one to three real examples they admire, unless the task only extends an established design. Without any, propose two contrasting directions in one sentence each and let the user choose.
3. **Direction brief.** In under 150 words: layout idea, type, colour, density, motion, and the one characteristic moment. Choices come from the subject's world. Treat these as generic defaults to justify or avoid: identical rounded card grids, a gradient wash, an eyebrow label above each heading, one accent word in a headline, a fade-up on every section.
   When several directions stay plausible, call the Skill tool with `prototype`, UI branch, and let the user pick by looking.
4. **Build.** On Opus, delegate implementation to a subagent with `model: sonnet`, passing the brief. Real content, real states: empty, loading, error, long text.
5. **Visual round.** Screenshot desktop and mobile with Playwright CLI, using synthetic data, and open both. Compare them to the brief and references. Fix the most important problems first. Repeat up to the budget.
6. **Audit.** Dispatch a subagent with [references/web-interface-guidelines.md](references/web-interface-guidelines.md) over the changed files only, returning `file:line` findings. Fix them. This guide covers the web. For SwiftUI and native macOS, audit against Apple's Human Interface Guidelines instead.
7. **Motion, only if the work has it.** Use `emil-design-eng` when it is installed. Motion answers a person's action and shows what changed.

Done when the screen matches the brief at both viewports, every state exists, the audit has no open critical finding, and the user has seen the screenshots. Continue with `/build` step 4.

## Spending less

- Use a tool that saves screenshots to disk rather than a browser MCP, whose page snapshots dominate cost.
- Decide from the brief before building. A vague brief is the largest source of wasted rounds.
- Keep the reference files out of the main context: the audit subagent loads them.
