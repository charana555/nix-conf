## Git

### Conflict Resolution

NEVER run `git commit` during merge, rebase, or cherry-pick conflict resolution. NEVER run `--continue`. After `git add` of resolved files, stop and tell the user to review, test, and run `--continue` manually.

For each conflict block, understand BASE, OURS, and THEIRS before resolving. Preserve observability, error handling, and tests from both sides. When in doubt, ask.

### Hygiene

Prefer focused commits in imperative mood. Check recent commit messages before writing one. NEVER commit or push without explicit approval.

## Before You Code

Search first. Before creating anything new, check whether an existing utility, function, module, or pattern already solves it. Prefer importing over copying. Extract shared logic only when the duplication is real.

Respect existing conventions. Read the surrounding code, docs, README, and configuration before changing behavior. Match naming, indentation, error handling, and testing patterns.

For complex work, think before acting: restate the problem, identify constraints, compare approaches, ask if requirements are ambiguous, then implement the smallest correct change.

## Style

Comments explain why, not what. Keep comments short and only add them when the reason is not obvious from the code. Do not add divider comments, ASCII art headers, commented-out code, or AI-generated markers.

Do not use em dashes. Use hyphens or commas.

## Documentation

When changing public configuration, modules, packages, services, or user-visible behavior, update relevant docs in the same change. Skip docs for pure refactors, typos, or formatting-only changes.
