# Workspace Agent Instructions

This repo is the cyberia-to workspace anchor. It orchestrates org-level concerns that do not belong inside any single content repo.

## Dependency direction

One-way, always:

```
.github → cyber, trident, hemera, optica, ...
```

`.github` knows every subgraph. No subgraph knows about `.github`. Never reintroduce org-awareness into a content repo.

## What lives here

- `workspace.toml` — org config, root graph choice, policy
- `subgraphs.lock.toml` — last-seen org snapshot (generated, committed)
- `scripts/*.nu` — sync, build, serve; nushell only
- `subgraphs/<name>.md` — one declaration per org repo, reconciler-scoped frontmatter plus human-owned body
- `context/` — shared contributor onboarding material
- `profile/README.md` — org profile page (GitHub convention)
- `SPEC.md` — the full reconciliation spec

## What does not live here

- Content. Content lives in `cyber/` and other subgraph repos.
- Build logic. Optica builds; `scripts/build.nu` is just the adapter that hands optica a config.
- Secrets. CI uses GitHub-managed secrets; local runs use `gh auth`.

## Writing style

- Never define by negation. State what things are.
- Never use bold. Use headings, frontmatter, and wiki-links for emphasis.
- Nushell for scripts. Bash only when no nushell equivalent exists.
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.

## Git workflow

- Atomic commits, one logical change each.
- Commit by default after completing a change.
- Never amend published commits.
- Never push without the user's explicit ask.
- The lock file is committed. Every sync-org run that produces diff is a reviewable commit.

## Reconciler safety rules

1. `rm -rf` appears nowhere in the scripts. No clone, no declaration, no directory is ever removed.
2. Working trees are untouched. `git fetch` only.
3. Frontmatter writes are key-scoped. Bodies are human-owned.
4. `--dry-run` is the default. `--apply` is required for any mutation. `--apply-renames` is required for renames.
5. Shadow conflicts halt the run. Hand-created folders never silently bind to org repo names.

See `SPEC.md` for the full state machine and safety invariants.
