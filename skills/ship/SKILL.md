---
name: ship
description: "Check the branch is ready, run the review its risk requires, and open a pull request in the standard format."
disable-model-invocation: true
---

# Ship

Open a PR a stranger could trust. Merging stays with the human.

Talk to the user in their language. Commits, PR text, issue text and code stay in English.

## Gates

Work through these in order, cheapest first: each gate spares the dearer ones below it from running twice. A failing gate blocks the PR, except where it says otherwise. Fix what you can fix yourself and keep going. Ask the user only when a gate fails and cannot be fixed from the repo, then ask once, with your recommendation first. The repo answers the rest: the remote, the target repository (`gh repo view --json nameWithOwner`), the state of a worktree.

1. **Branch.** Not the default branch. Named `<type>/<topic>`; if it has a `worktree-` name, rename it with `git branch -m`. Uncommitted changes on the branch are its own work: let gate 3 pass on them, then commit them.
2. **One theme.** Every commit serves one purpose. Move unrelated changes to their own branch.
3. **Fast checks.** Run the fast checks from `engineering.md` (format, lint, types, the tests of the touched files) and fix what fails. Seconds here save minutes at gate 5. Commit.
4. **Judge.** Call the Skill tool with `risk` once, then with `judge`, and pass the level on. Fix `critical` and `required` findings without asking, along with the optional ones that are cheap, axis by axis as each report returns, so a slow axis never holds up the fixes of a fast one. Commit once, then run gate 3 again. Put what remains in the PR's **Risk** section; do not stop to present the findings first.
5. **Receipt.** Last, and once, because every earlier fix moves `HEAD` and voids the receipt. It must exist and be bound to `HEAD`:
   ```bash
   receipt="$(git rev-parse --git-path verification-receipt.md)"
   test -f "$receipt" && grep -qx "Commit: $(git rev-parse HEAD)" "$receipt"
   ```
   If this fails, dispatch the `verifier` agent. A failed verification blocks the PR: fix it, run gates 3 and 5 again, and run gate 4 again only when the fix touched behaviour a reviewer already cleared.

## Open the PR

1. Push, then write the title and body in English, keeping domain terms in the glossary's language.
2. **Title:** Conventional Commits, `type(scope): imperative subject`, at most 72 characters, no trailing period.
3. **Body:** the template below. Use `Closes #<n>` when the work comes from an issue.
4. `gh pr create`, marked ready.
5. **Screenshots**, when the UI changed. GitHub has no public API for attachments, so upload to a prerelease whose tag cannot trigger a release:
   ```bash
   gh release create "pr-assets-<pr>" <files> --prerelease --target "$(git rev-parse HEAD)" --title "PR <pr> assets" --notes "Screenshots for PR <pr>."
   gh release view "pr-assets-<pr>" --json assets --jq '.assets[].url'
   ```
   Embed the URLs with `gh pr edit --body-file`. Confirm that each image shows synthetic data first.

Done when the PR URL is shown and its checks are running. Finish by telling the user the next step: `/explain`. Once the PR is merged, the worktree cleaner removes its worktree and local branch.

## Body template

```markdown
Closes #<n>

## Why
The problem and approach, in 1-3 short sentences.

## What changed
1-3 bullets. Add the smallest diagram, diff sketch or call tree that makes the change clear.

## Scope
What this covers and what it deliberately leaves out.

## Risk
**Level:** <low|medium|high> (<reason>)
**Door:** <one-way|two-way>
**Blast radius:** <who or what it touches, and why that is safe or risky>

## Verification
**Commit:** `<full sha>`
- `<command>`: <result>
- <criterion>: <observed behaviour> (certainty <1-5>)

**Not verified:** <list, or None>

## Screenshots
<before/after images, only if the UI changed>
```

Drop empty optional sections, but keep **Risk** and **Verification** in every PR.
