# Agentic Engineering

My set of skills and subagents for doing software engineering with coding agents.

They are short words to type in Claude Code. Each word says which phase of the work you are in, the agent does the rest, and no work is declared done without proof.

```
Total fog     /fog ───┐
I know little /grill ─┴→ /spec → /slice → /build → /ship → /explain → merge
I know what   /spec ↗            /swarm     ↑
I want                           /fix       └ runs /verify and /judge
                                 /ui
```

Not sure what to do now? Type **`/ask`**: it looks at the repo state and tells you the next command.

> [!NOTE]
> This is the first version. The skills have not yet been tried on real work: the first pilot is planned on a real repo. See [What still needs testing](#what-still-needs-testing).

## Contents

- [Principles](#principles)
- [Installation](#installation)
- [All commands](#all-commands)
- [What to do in each situation](#what-to-do-in-each-situation)
- [The flow, phase by phase](#the-flow-phase-by-phase)
- [Risk levels](#risk-levels)
- [The verification receipt](#the-verification-receipt)
- [Pull request standards](#pull-request-standards)
- [Branches, worktrees and cleanup](#branches-worktrees-and-cleanup)
- [Skills, sessions and subagents](#skills-sessions-and-subagents)
- [Models and costs](#models-and-costs)
- [Interfaces](#interfaces)
- [How the repo is laid out](#how-the-repo-is-laid-out)
- [What still needs testing](#what-still-needs-testing)

## Principles

1. **The limit is not writing code, it is knowing it works.** That is why every piece of work goes through a real proof.
2. **Rigour follows risk.** The rules are the same everywhere, but a text fix does not get the same treatment as a database migration.
3. **Few commands to remember.** Day to day, 3-4 words are enough. Verification and review start on their own.
4. **Agents as far as you can control them.** More agents are useless if you then cannot understand what they did.
5. **Decisions are yours, facts are the agent's to find.**

## Installation

### 1. Install

```bash
npx agentic-engineering@latest
```

In a terminal it asks three things: **which tool**, **where** to install and **which skills**.

- **Tool:** Claude Code (`~/.claude`, which OpenCode reads too) or Antigravity (`~/.gemini/config`, skills only: see [Other tools](#other-tools)).
- **Global** (`~/.claude` or `~/.gemini/config`): the skills apply in every project.
- **This repo only** (`.claude/` or `.agents/` at the root of the current repo): they apply only there, and you can commit them.
- **Which skills:** a numbered list; answer with numbers or ranges (`1,3,5-8`), or press Enter for all. Skills call each other (`/ship` uses `judge`, `verify`, `risk`), so if you remove one, the ones that name it will not fully work.

For Claude Code, agents are always installed together with the skills. There is no need to clone the repo. Without prompts, for example in a script:

```bash
npx agentic-engineering@latest --global --all               # everything, global
npx agentic-engineering@latest --project --skills=spec,tdd  # only these, only in the repo
npx agentic-engineering@latest --yes                        # global, all, no prompts
npx agentic-engineering@latest --dry-run                    # show what would change, touch nothing
npx agentic-engineering@latest --tool=antigravity --global --all  # everything, for Antigravity
```

### Other tools

The skills are plain `SKILL.md` folders, so any tool that reads that format can load them. Antigravity lists them in its Customizations panel and turns each into a `/<name>` command. What depends on Claude Code:

- **`reviewer` and `verifier` agents:** Claude Code's format, so `--tool=antigravity` skips them. Without subagents, `judge` reviews one axis at a time and the skills run verification in the same session.
- **Model per subagent:** the skills name tiers (_mid-tier_, _top-tier_) with the Claude Code value in brackets. A tool that cannot pick a model per subagent runs everything on the session's model.
- **Worktree cleanup hook:** it lives in `~/.claude/settings.json`, so it is installed for Claude Code only.
- **`disable-model-invocation`:** Antigravity's docs do not mention it, so commands such as `/ship` may also start on their own there.

`--skills` gives the complete list: skills the installer previously put in the same scope that are not in the list are removed. The worktree cleanup script (step 3) is installed only globally.

If a name is already taken, the old item is moved to `backups/agentic-engineering-<date>/` inside `.claude`. Skills stay `/spec`, `/slice`, etc., with no plugin prefix.

Before publication on npm, or to try a branch, you can use GitHub directly:

```bash
npx github:cavallinilorenzo/agentic-engineering
```

### 2. Retire replaced skills (optional)

```bash
npx agentic-engineering@latest --retire
```

Moves to the backup the old skills that this set replaces, such as `wayfinder`, `to-spec`, `implement`, `pr`, `code-review` and `impeccable`, together with their agents. The exact list is at the top of `bin/cli.mjs`.

These things must be done by hand:

- **Impeccable hooks:** if you had them, remove the entries that name it from `SessionStart`, `PostToolUse` and `Stop` in `~/.claude/settings.json`.
- **OpenCode:** it reads both `~/.claude/skills` and `~/.agents/skills`. If you keep old copies in `~/.agents/skills`, remove them, otherwise you will get duplicate names.

### 3. Enable automatic worktree cleanup

The installation copies the script to `~/.claude/agentic-engineering/clean-worktrees.sh`. Add this to `~/.claude/settings.json`, with your own username:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOUR_USER/.claude/agentic-engineering/clean-worktrees.sh --all /Users/YOUR_USER/Developer",
            "async": true
          }
        ]
      }
    ]
  }
}
```

Details in [Branches, worktrees and cleanup](#branches-worktrees-and-cleanup).

### 4. Prepare each repo

Inside each repo you want to work in, once:

```
/setup
```

### Update and uninstall

```bash
npx agentic-engineering@latest                       # update: rerun the installation
npx agentic-engineering@latest uninstall --global    # removes only what it installed in ~/.claude
npx agentic-engineering@latest uninstall --project   # same, in .claude of the current repo
```

Each scope has its own `agentic-engineering.json`, so global and repo are updated and removed separately.

An update overwrites the copies it installed, so manual edits to those skills are lost. To change them, work in the repo.

### For people developing the skills

When you clone the repo, `./scripts/install.sh --apply` creates symlinks instead of copies, so changes show up immediately. Do not mix the two methods on the same `~/.claude`.

### Optional

For animations, `/ui` uses Emil Kowalski's skill if it finds it:

```bash
npx skills add emilkowalski/skills --skill emil-design-eng
```

## All commands

| Phase | Command | When you use it |
|---|---|---|
| **Define** | `/fog` | Total fog: work too big or confusing for one session |
| | `/grill` | You know little: an interview clarifies it |
| | `/spec` | You know what you want: fixes the what and why |
| **Slice** | `/slice` | Decides how, in what order and at what risk |
| **Build** | `/build` | One ticket, test-first, in a worktree |
| | `/swarm` | All the tickets of a spec, in dependency order |
| | `/fix` | Something is broken or slow |
| | `/ui` | A screen, a redesign or a polish pass |
| **Verify** | `/verify` | Proves it works. Starts on its own after `/build` and `/fix` |
| **Review** | `/judge` | Independent judgement. Starts on its own inside `/ship` |
| | `/explain` | Helps you understand a PR, yours or someone else's |
| **Ship** | `/ship` | Checks everything and opens the PR |
| | `/release` | Delivers a version to people |
| **Repo** | `/setup` | Prepares a repo, once |
| **Context** | `/handoff` | The work moves to another tool, folder or person |
| **Help** | `/ask` | You do not know what comes next |

These are called by the other commands. You can type them, but usually there is no need:

| Skill | What it does | Used by |
|---|---|---|
| `tdd` | Red → green test cycle at the agreed seams | `/build`, `/swarm` |
| `risk` | Risk levels and certainty ladder | `/slice`, `/verify`, `/judge`, `/explain` |
| `research` | A background agent looks up facts in primary sources and saves them with citations | `/slice`, `/fog` |
| `prototype` | Throwaway code to answer a question about logic or looks | `/slice`, `/fog`, `/ui` |
| `domain-modeling` | Keeps the glossary and ADRs up to date | `/slice`, `/fog` |
| `codebase-design` | Vocabulary for designing deep modules | `/slice`, `tdd` |
| `writing-for-agents` | Rules for writing documents for agents | Whoever edits these skills |

## What to do in each situation

### Starting work

| Situation | What you do |
|---|---|
| Repo never prepared | `/setup` |
| I have an idea but do not even know if it makes sense | `/fog` if it is huge, otherwise `/grill` |
| I know what I want, but it is a feature with several parts | `/spec` → `/slice` → `/build` for each ticket |
| I know exactly what to do and it is small | `/build` and describe the work |
| I change one line of text or documentation | `/build`: the risk is low and the checks are minimal |
| I do not know if something is technically feasible | `research` starts during `/slice`, or ask for it yourself |
| I do not know how it should look or behave | `prototype` starts during `/slice`, or ask for it yourself |
| I already have a ready issue | `/build #123`, or `/slice #123` if a plan is needed |

### Building

| Situation | What you do |
|---|---|
| One ticket at a time | A new session per ticket: `/build #123`, then `/ship` |
| Several tickets with shared parts | One at a time, in dependency order |
| All the tickets of the spec in one go, even with dependencies | `/swarm #spec` |
| I want to launch several agents by hand | One session per ticket: each creates its own worktree |
| Two tickets would touch the same files | Not in parallel: make one block the other |
| The work grows beyond a reviewable PR | `/build` stops and proposes splitting it |
| Big rename or refactor across the whole codebase | `/slice`: sequences it as expand, migrate in blocks, contract |

### Fixing

| Situation | What you do |
|---|---|
| Any bug | `/fix` and describe the symptom |
| Bug that shows up sometimes | `/fix`: raises the reproduction rate until it can be analysed |
| Cannot be reproduced | `/fix` stops and asks you for access or redacted data, without guessing |
| Performance regression | `/fix`: measures first, then fixes |
| Production emergency | `/fix` on a `fix/...` branch, then `/ship`, then `/release` with a rollback plan |
| Verification fails after `/build` | The agent fixes and reverifies; the PR is not opened until it passes |

### Interfaces

| Situation | What you do |
|---|---|
| New screen | `/ui`: asks you for 1-3 real references, writes the direction, builds and looks at the result |
| Several possible directions | `/ui` creates variants with `prototype` and you choose by looking at them |
| Polish something that already exists | `/ui` and name the screen |
| Repo without `DESIGN.md` | `/ui` derives it from the code and writes it |
| macOS or SwiftUI app | `/ui`: the audit uses Apple's guidelines instead of the web ones |

### Opening and understanding a PR

| Situation | What you do |
|---|---|
| Work finished | `/ship #123` from any folder, even the main checkout: it finds the branch and its worktree. Then `/explain` in a clean session |
| I have not read my PR's diff | `/explain`: it is the check designed for this |
| Someone else's PR | `/explain 123`: an explanation and a review draft, which only you publish |
| High-risk PR | `/explain` points out up to 3 critical spots to read with it |
| The receipt is for an old commit | `/ship` rejects it and reruns verification; `/explain` flags it as stale |
| PR with several themes together | `/ship` blocks it: unrelated themes go on another branch |
| Review comments to address | Reopen the session on the branch, fix, `/ship` reverifies |
| Red CI after opening | `/ship` watches the checks and fixes what the branch broke; the rest it reports with the job link |
| I only want an opinion on a branch | `/judge` |

### After the merge

| Situation | What you do |
|---|---|
| PR merged | Nothing: at the next session the worktree and the local branch disappear |
| I want to clean up right now | `./scripts/clean-worktrees.sh` in the repo |
| I want to see what would be removed | `./scripts/clean-worktrees.sh --dry-run --all ~/Developer` |
| A worktree is not removed | Look at the log: `~/.local/state/agentic-engineering/clean-worktrees.log` |
| PR closed without merge | The worktree stays: you decide |
| Releasing a version | `/release`: go/no-go, rollback plan, and it starts only with your approval |

### Context, limits and maintenance

| Situation | What you do |
|---|---|
| End of a phase: continue or clean up? | `/ask`, which uses the rules in `PHASE-BOUNDARIES.md` |
| The session is long, work not finished | `/compact` at a phase boundary |
| Work finished, moving to an unrelated one | `/clear` |
| I ran out of Claude plan limits | `/handoff`, then restart with OpenCode Go, only on non-sensitive repos |
| Handing the work to a colleague | `/handoff` |
| Repo with client data | In `/setup` flag `sensitive: yes`: no models from other providers |
| A skill does not do what it should | Edit the skill in this repo with `writing-for-agents` |

## The flow, phase by phase

### 1. Define: what and why

Choose based on how much you already know:

- **`/fog`** is for work too big for one session. It creates a **map** of decision tickets on the tracker and resolves one per session, until the path is clear. It produces decisions, not code. Some tickets it resolves with `research` or `prototype`, others with an interview. At the end you move on to `/spec`.
- **`/grill`** is a round-based interview: for each question it gives you a recommendation, and you answer only where you disagree. The agent looks up the facts, the decisions stay yours.
- **`/spec`** summarises the conversation into an issue: problem, solution, user stories, externally verifiable **acceptance criteria**, out of scope. It does not contain how to build it.

You can skip this phase when the work is small and clear.

### 2. Slice: how and in what order

**`/slice`** does not write code. It fixes the decisions on data, modules and seams, assigns the risk, orders the dependencies and splits the work into **vertical slices**: each slice is a complete path, demonstrable on its own, as big as one session and one PR. Then it shows you everything and waits for your approval.

With a single slice the plan is a comment on the issue. With several slices it creates one ticket for each, with the tracker's native blocking links.

### 3. Build

- **`/build`** works on one ticket: creates the worktree, writes the test first, implements, commits and launches the `verifier`.
- **`/swarm`** runs all the tickets of the spec following the blocks: independent ones in parallel, the others as soon as they are unblocked. One mid-tier subagent per ticket (Sonnet in Claude Code), each in its own worktree, towards a single integration branch and a single PR; one full verification at the end.
- **`/fix`** first creates a command that "goes red" on that bug, then minimises, forms hypotheses, finds the root cause, writes the regression test and verifies.
- **`/ui`** builds with a budgeted visual loop ([details](#interfaces)).

### 4. Verify: the proof

**`/verify`** starts on its own. It runs the repo's commands on the exact commit, really uses the feature and writes the [receipt](#the-verification-receipt). If something is wrong, the receipt is not written as valid.

### 5. Review: judgement and understanding

They are two different things:

- **`/judge`** gives an independent judgement, with agents that did not write the code. It checks the standards, the spec and, at high risk, the blast radius. It starts on its own inside `/ship`.
- **`/explain`** helps you understand. It is the check that replaces reading the whole diff: every claim is tied to a `file:line` or to a command that was run, and it says what is not verified.

**The limit:** an agent can explain something wrong very well. That is why, at high risk, it asks you to read up to 3 critical spots.

### 6. Ship: delivering

- **`/ship`** checks the branch, single theme, size, receipt and review, then opens the PR in the [standard format](#pull-request-standards) and stays until CI is green. You do the merge.
- **`/release`** delivers a version: lists the changes, checks it is ready, writes the rollback plan and starts only with your approval. It also starts on its own when you ask to release, publish or tag a version.

## Risk levels

Risk depends on what the change touches and how reversible it is, not on how many lines it changes. The highest level wins. When in doubt it is **high**.

| Level | Examples | Verification | Review |
|---|---|---|---|
| **Low** | Docs, copy, tests, styling without logic | Commands and a short receipt | CI only |
| **Medium** | Product logic, UI with state, dependencies | + real behaviour | `/judge` (standards + spec) and `/explain` |
| **High** | Money, client or personal data, migrations, auth, secrets, CI/release, public APIs, deletions, one-way doors | + proof in the app on the critical path | `/judge` with blast radius and `/explain` with critical spots |

- Each repo has a **minimum** in `docs/agents/engineering.md`. For client repos the minimum is medium.
- The agent can raise the level, only you can lower it.
- A **one-way door** cannot be undone at low cost: destructive migration, published version, sent message.

### Certainty ladder

For every claim that something works, or is safe:

1. **Stated:** I asserted it. On its own it is worth nothing.
2. **Pointed to:** there is a real `file:line`.
3. **Traced:** I followed the negative case and it cannot happen.
4. **Executed:** a script or a test on the real code.
5. **Reproduced:** I saw it in the running app.

Medium risk requires level 4 on the changed behaviour, high risk level 5 on the critical path. What stays below goes under **Not verified**.

## The verification receipt

It lives outside the diff, in `$(git rev-parse --git-path verification-receipt.md)`, and is bound to a commit:

```markdown
Commit: 3f2a9c1e...
Risk: medium (changes the total calculation)

## Commands
- `npm test`: exit 0, 538 passed

## Behaviour
- The total updates: proven in the browser on fake data (certainty 5)

## Not verified
- PDF export: not touched and not proven

## Screenshots
- desktop: /path/desktop.png
```

**The receipt expires with every commit.** `/ship` accepts it only if `Commit:` matches `HEAD`, so an old verification cannot cover new code.

## Pull request standards

**Title:** Conventional Commits in English, at most 72 characters, for example `feat(budget): keep limits from the current month onward`. Domain terms stay in the language of the glossary.

**Branch:** `type/topic`, with type `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf` or `ci`.

**Rules:** one theme per PR, no line limit, `Closes #n` when the work comes from an issue.

**Body:**

```markdown
Closes #123

## Why
The problem and the approach, in 1-3 sentences.

## What changed
1-3 points, with a small diagram if it helps.

## Scope
What it includes and what it leaves out.

## Risk
**Level:** medium (reason)
**Door:** two-way
**Blast radius:** who or what it touches, and why it is safe or risky.

## Verification
**Commit:** `full sha`
- `command`: outcome
- criterion: observed behaviour (certainty 4)

**Not verified:** list, or None

## Screenshots
Before and after, only if the UI changes.
```

**Screenshots:** GitHub has no public API for attaching images, so `/ship` gives you the local paths and you drag them into the PR. It creates no release, tag or branch to host them. They show **always and only fake data**: in a public repo an image exposes data just like code does.

An image costs about 1,500-2,700 tokens only when the model opens it. Saving and attaching it is free.

## Branches, worktrees and cleanup

They are two different things and you need both:

- A **branch** is a line of history.
- A **worktree** is the folder in which that branch is open.

A folder holds only one branch open at a time. With two agents in the same folder, the second would change files under the first one's feet. Since I often launch several agents together, **every implementation works in its own worktree**, in `.claude/worktrees/<topic>`.

Cost: each worktree is a new folder, to be prepared with dependencies and `.env`. The `setup` line in `docs/agents/engineering.md` tells the agent how. In a Rust project the build also starts from scratch.

### Automatic cleanup

`scripts/clean-worktrees.sh` starts in the background at every session start ([how to enable it](#3-enable-automatic-worktree-cleanup)) and checks all the repos in the given folder. It removes the worktree and the local branch only if **all** these conditions are true:

| Check | Why |
|---|---|
| It lives in `.claude/worktrees/` | Does not touch worktrees created elsewhere by hand |
| Its PR is merged **at that exact commit** | A commit made after the merge must not be lost |
| No changes, not even untracked files | Uncommitted work stays |
| It is not locked (`git worktree lock`) | Respects an explicit lock |
| No process is working inside it | Does not delete the folder under an active agent |

**When in doubt it stays.** If GitHub does not answer, if the PR is only closed or if `gh` is missing, the worktree is not touched. Ignored files, like `node_modules`, do not block removal.

The `pr-<number>` review worktrees, created by `/explain`, disappear when the PR is merged or closed, unless they contain commits foreign to the PR.

Also enable deletion of the remote branch on merge in GitHub. `/setup` suggests it.

## Skills, sessions and subagents

| | What it is | Context | Good for |
|---|---|---|---|
| **Skill** | Instructions loaded where you work | The current thread | A method to follow |
| **New session** | You with a clean agent | Empty, but you can converse | One ticket |
| **Subagent** | Another worker with a specific task | Empty, only the result comes back to you | Side work |

They are not alternatives: a subagent can load a skill. **For a ticket, the normal choice is a new session with `/build`.**

Use a subagent in four cases:

1. The work would fill the main context: searches, logs, verbose tests.
2. You want a judgement independent from whoever wrote the code.
3. You have truly independent tasks to run in parallel.
4. You want to limit permissions, for example read-only.

Stay in the main session when you need back-and-forth, the steps are sequential or the change is small. Subagents do not save tokens overall, they only protect the main context, and they consume the same plan limits.

This repo defines only two agents:

- **`reviewer`:** reads a diff on a single axis, changing nothing. `/judge` launches it.
- **`verifier`:** runs `/verify` and returns only the outcome, keeping logs and screenshots out of the conversation. `/build`, `/fix`, `/swarm` and `/ship` launch it.

## Models and costs

| Work | Model | Why |
|---|---|---|
| `/fog`, `/slice`, `/judge` at high risk, direction in `/ui` | Opus 5.5 | A mistake costs more here |
| `/build`, `/fix`, `/ship`, `reviewer`, `verifier` | Sonnet 5.5 | Handles most of the work and costs less |
| Simple, repetitive tasks | Haiku 5.5 | The cheapest |
| Second opinion and low-risk work, on non-sensitive repos | OpenCode Go | A different model finds different mistakes |

- Switch with `/model` depending on the phase.
- **Sensitive repos** (client, financial, personal data): stay on Claude models. In `engineering.md` write `sensitive: yes`.
- The second opinion is enabled with the `second_opinion` line of `engineering.md`.
- The habits that save the most: one session per ticket, `/clear` between unrelated jobs, few parallel sessions.

## Interfaces

**No skill guarantees a beautiful UI.** The result depends a lot on the direction and the references you choose. `/ui` helps you get there spending little:

1. **Base:** reads `DESIGN.md` and reuses existing tokens and components.
2. **References:** asks you for 1-3 real examples you like.
3. **Direction:** a brief under 150 words, with choices that come from the subject, not from generic defaults.
4. **Construction:** Opus decides and judges, a Sonnet subagent implements, including empty, loading and error states.
5. **Visual loop:** desktop and mobile screenshots with Playwright CLI on fake data, **at most 3 rounds per screen**, then it stops and asks you.
6. **Audit:** Vercel's [Web Interface Guidelines](https://github.com/vercel-labs/web-interface-guidelines) in a subagent, only on the touched files. For SwiftUI, Apple's guidelines.
7. **Animations:** Emil Kowalski's skill, only when needed.

Images cost about 3-5k tokens per round, that is 10-16k per screen: an estimate to be measured. The biggest saving comes from not redoing work because of a vague brief.

## How the repo is laid out

```
skills/<name>/SKILL.md    one folder per skill
agents/                   reviewer and verifier
bin/cli.mjs               installer for npx (copies into ~/.claude)
scripts/install.sh        symlink installer, for people developing
scripts/clean-worktrees.sh  worktree cleanup after merge
tests/                    checks on skills, installation and cleanup
NOTICE.md                 origin and licence of every skill
```

**Where each skill comes from:** [NOTICE.md](NOTICE.md) states for each one whether it is copied, reworked or new, with commit and licence.

In short: the base is [Matt Pocock](https://github.com/mattpocock/skills), the six-phase cycle comes from [Addy Osmani](https://github.com/addyosmani/agent-skills), some ideas from [pstack](https://github.com/cursor/plugins/tree/main/pstack), the UI guidelines from [Vercel](https://github.com/vercel-labs/web-interface-guidelines).

**Editing the skills:** run `bash tests/run.sh` before every commit. It checks names, cross-references, citations and the dangerous cleanup cases.

**Updating from the sources:** compare the source with the commit in `NOTICE.md`, bring over what is needed and update the commit. There is no automatic sync, by choice.

## What still needs testing

The deterministic parts have tests: installation, worktree cleanup, skill structure. The rest must be tried on real work:

| To test | Risk |
|---|---|
| The full flow, from `/spec` to `/explain` | Never run end to end |
| `/slice` and `/verify` replacing Claude Code's same-named commands | Documented for the local terminal, not for other surfaces |
| `/ship` watching CI and fixing red checks | Not yet run on a real PR |
| The `/ui` budget | Tokens are an estimate |
| `second_opinion` with OpenCode Go | The exact command is still to be defined |
| Subagents on OpenCode | The skills work, but `reviewer` and `verifier` use the Claude Code format |
