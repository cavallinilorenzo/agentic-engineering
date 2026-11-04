# Agentic Engineering

Skills live in `skills/<name>/SKILL.md`, subagents in `agents/`. Public repo: no client data, no credentials, no private project names.

- Writing or editing a skill: use the `writing-for-agents` skill.
- Adding, removing or renaming a skill: update `README.md`, `NOTICE.md` and `skills/ask/SKILL.md`. `bash tests/run.sh` checks this.
- Taking material from another project: record source, commit, licence and kind (copied, reworked, inspired) in `NOTICE.md`.
- Changing `scripts/clean-worktrees.sh`: add a test for the case. A wrong removal destroys work, so uncertainty means keep.
