# Engineering config

Read by `/verify`, `/judge`, `/build`, `/ship`, `/ui` and `/release`.

## Risk

- floor: <low|medium|high>
- sensitive: <yes|no>
- high-risk paths:
  - <glob>: <why>

## Recipe

- setup: `<command that prepares a new worktree: dependencies, env from an example file>`
- checks:
  - `<lint or typecheck command>`
  - `<test command>`
  - `<build command>`
- run: `<command that starts the real app>`, available at `<url or how to reach it>`
- exercise: <how an agent observes real behaviour here: browser, curl, CLI, simulator>
- screenshots: <e.g. `npx playwright screenshot`, `xcrun simctl io booted screenshot`, or none>
- test data: <where synthetic data comes from>

## Review

- second_opinion: <command that runs a second model on a diff, or none>

## Release

- release: <workflow or command, how it is triggered, or none>
