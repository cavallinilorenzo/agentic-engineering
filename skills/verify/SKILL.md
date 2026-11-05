---
name: verify
description: Prove a change works against the real artifact and write a verification receipt bound to the commit. Use before declaring work done, before opening a PR, or when a receipt is missing or stale.
---

# Verify

Prove behaviour by observing the real thing. A compile, a green unit test or an agent's report is a proxy.

Talk to the user in their language. Commits, PR text, issue text and code stay in English.

## Steps

1. **Pin the commit.** Commit pending work. Record `git rev-parse HEAD`.
2. **Load the recipe.** Read `docs/agents/engineering.md`. If it is missing, derive commands from CI and the build files, and say that `/setup` has not run. Call the Skill tool with `risk`, then classify the change.
3. **List the criteria.** Take acceptance criteria from the ticket, spec or plan; for a bug, the original symptom. With no source, derive them from the diff and label them `inferred`.
4. **Run the commands** the recipe names, fresh, at the pinned commit. Keep each command's exit status and the one line that summarises it.
5. **Exercise the behaviour.** Drive every criterion through the real artifact: dev server, CLI, app. Climb the certainty ladder as far as the risk level demands. Turn a bug found here into a failing test, then fix it and restart from step 1.
6. **Capture screenshots** when the change is visual (see below).
7. **Write the receipt** to `$(git rev-parse --git-path verification-receipt.md)`, which stays out of the diff.

Done when every criterion has an observed result or a line under **Not verified**, and the receipt's commit equals `HEAD`. If a command or criterion failed, report the failure and write no passing receipt.

## Receipt

```markdown
Commit: <full sha>
Risk: <level> (<reason>)

## Commands
- `<command>`: exit <n>, <one-line summary>

## Behaviour
- <criterion>: <what was done and observed> (certainty <1-5>)

## Not verified
- <what, and why>

## Screenshots
- <viewport>: <path>
```

Write `None` under an empty section. Redact every secret.

## Screenshots

Use the recipe's method, or `npx playwright screenshot --viewport-size=1280,800 <url> <path>`, plus a 390×844 viewport. Saving is free: an image costs tokens only when the model opens it. Open only what the verification needs.

Save under `$(git rev-parse --git-path verification-screenshots)`. Use synthetic data, always.
