---
name: setup
description: "Prepare a repo for these skills: issue tracker, labels, domain docs, risk floor and how to verify. Run once per repo."
disable-model-invocation: true
---

# Setup

Write the per-repo configuration the other skills read. Detect first, and ask only what the repo cannot tell you, at most four questions, each with a recommended answer.

## Steps

1. **Explore.** Read `git remote -v`; `AGENTS.md`, `CLAUDE.md` and any `## Agent skills` block; `GLOSSARY.md` or legacy `CONTEXT.md`; `docs/adr/`; `docs/agents/`; `.gitignore`; CI workflows; test and build commands; release workflows; `.github/pull_request_template.md`. Report what you found in a few lines.
2. **Decide with the user:**
   - **Issue tracker.** Propose the host of the remote: GitHub, GitLab, or local markdown for a repo with none. Keep what exists.
   - **Labels.** Keep the defaults: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`.
   - **Domain docs.** Single context unless the repo is a monorepo. Offer to `git mv` a legacy `CONTEXT.md` to `GLOSSARY.md` only if the user wants it; otherwise record the existing name.
   - **Risk.** Propose the floor, high-risk paths, and whether the repo is `sensitive` (client, financial or personal data).
3. **Show drafts** of every file below. Let the user edit them before anything is written.
4. **Write:**
   - The `## Agent skills` block in whichever of `CLAUDE.md` or `AGENTS.md` exists, updated in place. If neither exists, ask which to create.
   - `docs/agents/issue-tracker.md` from [issue-tracker-github.md](issue-tracker-github.md), [issue-tracker-gitlab.md](issue-tracker-gitlab.md) or [issue-tracker-local.md](issue-tracker-local.md).
   - `docs/agents/triage-labels.md` from [triage-labels.md](triage-labels.md).
   - `docs/agents/domain.md` from [domain.md](domain.md).
   - `docs/agents/engineering.md` from [engineering.md](engineering.md).
   - `.github/pull_request_template.md` with the body template from `/ship`, if the host is GitHub. If one exists, show the difference and ask.
   - `.claude/worktrees/` in `.gitignore`.
5. **Configure the host,** with the user's approval: create missing labels; on GitHub, enable deleting head branches on merge with `gh repo edit --delete-branch-on-merge`.
6. **Prove the recipe.** Run each command in `engineering.md` once, from a clean checkout where you can, and fix what fails.

Done when every command in the recipe has run, the files are written, and the user has seen a summary. Commit on a branch and tell the user the next step: `/ship`.

## The Agent skills block

```markdown
## Agent skills

Workflow: see `/ask`. Before verifying or reviewing, read `docs/agents/engineering.md`.

- Issue tracker: <one line>. See `docs/agents/issue-tracker.md`.
- Triage labels: <one line>. See `docs/agents/triage-labels.md`.
- Domain docs: <one line>. See `docs/agents/domain.md`.
```
