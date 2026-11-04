---
name: release
description: "Decide go or no-go for a production release, with a rollback plan, then run it through the repo's release mechanism."
disable-model-invocation: true
---

# Release

Merging delivers code to the repo; a release delivers it to people. Publishing is a one-way door, so the human gives the go.

## Steps

1. **Find the mechanism.** Read the `release` line in `docs/agents/engineering.md`, then the release workflows, `VERSION` files and tags. Name what will run.
2. **Scope it.** List the PRs since the last release with `git log <last-tag>..HEAD`. Propose the semantic version and write notes for the people who will receive it. Flag every migration and every one-way door.
3. **Check readiness.** Each line gets evidence or a `gap`:
   - CI is green on the exact commit being released.
   - Tests and build pass; dependency audit shows no critical or high vulnerability.
   - No secrets in the range; configuration and migrations are ready for production.
   - Monitoring or an error signal exists, and you can name what would show a failure.
   - A smoke test is defined for after the release.
4. **Plan the rollback.** State how to return to the previous version, how long it takes, and what happens to data written in between. A change that cannot be rolled back says so, in words.
5. **Decide.** Present go or no-go with the gaps and your recommendation. Wait for the user's explicit go.
6. **Run the mechanism**, one step at a time, stage by stage where the repo supports staging.
7. **Check after.** Run the smoke test against the released artifact, and read the error signal.

Done when the smoke test has passed and the user has the result, or the rollback has run and the failure is reported. Run `/retro` when something went wrong.
