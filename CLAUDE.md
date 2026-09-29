# .github — agent instructions

This repository is the door to the cyberia-to organization: the registry of every
repository, the community defaults every repository inherits, the relay that
turns organization events into workflow runs, and the starter workflows. Content
lives elsewhere; this repository knows where.

## dependency direction

One way, always: `.github → every other repository`. The registry reads the
ladder from `soft3/release/components.toml` on origin/main and the GitHub API.
No repository reads `.github`. Never reintroduce org-awareness into a content
repository.

## the registry

- `README.md` between `<!-- registry:start -->` and `<!-- registry:end -->` is
  generated. Never edit inside the markers; run `nu registry/registry.nu update`.
- Placement has two sources, in order: the ladder (`components.toml`: a product
  on its own repository, then a crate's `part_of`, then a part's `part_of`),
  then `registry/groups.toml` (`[rung]` corrections, `[[group]]` shelves). A
  repository matching neither renders under `unsorted` and fails lint; that is
  the cue to place it, in `groups.toml` or in the ladder, never both.
- The README carries public rows only, whatever token runs the script.
  `render --all` is for a member's local view and writes under `build/`, which
  git ignores. Never commit a render that names a private repository.
- `check` compares the rendered section with the file; the workflow self-heals
  on schedule, dispatch and push, and only verifies on pull requests.
- The table omits volatile fields (stars, push dates) so a commit means the
  inventory changed: a repository appeared, vanished, renamed, moved rung,
  changed description, homepage, language, visibility or archive state.

## the relay

`relay/` documents what runs on cyberproxy. The server is the truth,
`cybernode/local/servers/cyberproxy.md` mirrors it. The token on the server has
Contents write on this repository only. Changing `hook.json` means backing it
up first and restarting `webhook-deploy`, the only unit.

## defaults

`SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SUPPORT.md`,
`.github/ISSUE_TEMPLATE/config.yml`, `.github/PULL_REQUEST_TEMPLATE.md` apply
to every repository of the organization, public or private, that has no file of
its own. Write them for the whole organization; a repository-specific rule goes
into that repository.

## writing style

- State what things are. Never define by negation. No bold.
- Root vocabulary: file, particle, cyberlink, neuron, token, focus. Never CID,
  user, edge, wallet, knowledge graph.
- Nushell for scripts. Bash only where nushell cannot run (the relay script on
  the server is `sh`).
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
  The registry bot commits as `chore: registry sync (<event>)`.

## filenames

Every organization repository keeps paths portable to Windows NTFS: none of
`< > : " / \ | ? *`, no control characters, no trailing `.` or space, no reserved
basenames (`CON` `PRN` `AUX` `NUL` `COM1`–`9` `LPT1`–`9`). Policy in
`soft3/specs/filenames.md`; check from the workspace root with
`python3 soft3/scripts/check-filenames.py --root ~/cyber`.

## git

Atomic commits, one logical change each, staged by explicit path. Never amend
published commits. Never push without the user's explicit ask, with one
exception: the registry workflow pushes its own `chore: registry sync` commits.
