---
name: git-wisdom
description: Git conflict resolution protocol and safety rules for merge, rebase, cherry-pick, commit, and push operations.
---

# Git Wisdom

## Conflict Resolution Protocol

1. NEVER run `git commit` during an active merge, rebase, or cherry-pick.
2. NEVER run `git merge --continue`, `git rebase --continue`, or `git cherry-pick --continue`.
3. After resolving conflicts and staging files with `git add`, stop immediately.
4. Tell the user: "Conflicts resolved and staged. Please review, test, then run --continue manually."

## Conflict Analysis

Before resolving each conflict, understand these three sides:

- BASE: the common ancestor before divergence.
- OURS: the current branch.
- THEIRS: the incoming branch.

Answer these before editing:

1. What semantic change was attempted in OURS?
2. What semantic change was attempted in THEIRS?
3. What was the original intent in BASE?
4. Which resolution preserves both intents safely?
5. Is there a third option that supersedes both branches?

## Priorities

- Prefer explicit over implicit.
- Preserve logs, metrics, error handling, tracing, and tests.
- Never drop error handling or tests added by either side.
- Keep the more defensive error handling when both sides conflict.
- Prefer preserving feature behavior over preserving refactor shape.
- Ask the user when behavior is genuinely ambiguous.

## General Git Hygiene

- Prefer rebase over merge for feature branches.
- Use imperative commit messages.
- Keep commits focused and atomic.
- Check recent commit messages before proposing one.
- Never commit or push without explicit user approval.
