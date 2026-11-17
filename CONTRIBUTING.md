# Contributing

Read [AGENTS.md](AGENTS.md) first: it holds the rules for editing skills.

## Setup

```bash
git clone https://github.com/cavallinilorenzo/agentic-engineering
cd agentic-engineering
npm ci
npm test        # skills, installer and worktree-cleanup checks
npm run lint    # shellcheck (needs shellcheck installed)
```

## Changing something

`main` is protected: work on a branch and open a pull request. The `checks`, `package` and `secrets` jobs must pass; the branch is deleted when the PR is merged. Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`), in English.

## Releasing

Releases are automatic. To publish a new version:

1. In a PR, bump the version: `npm version patch --no-git-tag-version` (or `minor`, `major`).
2. Merge it. The `Release` workflow sees a version npm does not have, runs the tests, publishes to npm with provenance, and creates the `v<version>` tag and GitHub release with generated notes.
3. Users running `npx agentic-engineering@latest` get it on their next run; re-running the installer updates their copies.

### One-time npm setup

The workflow publishes with [npm trusted publishing](https://docs.npmjs.com/trusted-publishers) (no token stored). On npmjs.com, open the package → Settings → Trusted publisher → GitHub Actions, and enter owner `cavallinilorenzo`, repository `agentic-engineering`, workflow `release.yml`.
