# contributing

These rules apply to every repository of the cyberia-to organization that does
not carry its own `CONTRIBUTING.md`. The doctrine behind them is
[cyberia/dev.md](https://github.com/cyberia-to/cyberia/blob/main/dev.md); a
repository's `CLAUDE.md` or `AGENTS.md` names its gates.

## where things are

The [registry](README.md#registry) places every repository on the soft3 ladder
or on a shelf. Read the rung's one-liner before opening a pull request: a
change that belongs to a lower rung goes to that rung's repository. No
component depends on a rung above its own.

## the change

- One pull request, one logical change. Conventional prefix in the title and
  in every commit: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
  The message says why.
- Stage by explicit paths. History is never rewritten on shared branches, no
  amend, no force-push. No AI co-authorship trailers.
- Zero warnings and green tests before the commit. Rust repositories:
  `cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test --locked`.
  A red state may be committed only with the `wip:` prefix and the first error
  quoted in the message.
- Paths stay portable to Windows NTFS: no `< > : " / \ | ? *`, no trailing dot
  or space, no reserved basenames (`CON`, `PRN`, `AUX`, `NUL`, `COM1`–`9`,
  `LPT1`–`9`). Hyphens over punctuation. Policy: `soft3/specs/filenames.md`.

## the words

Cyber has its own vocabulary and the repositories use it: file (the thing),
particle (its identity), cyberlink, neuron, token, focus. Substitutes borrowed
from other stacks (CID, user, edge, wallet, knowledge graph) are corrected in
review. Prose states what a thing is; it does not define by negation, and it
does not use bold.

## specifications and reports

Contracts, invariants and acceptance criteria live in `specs/`. Audits,
benchmarks and release validation live in `audit/`, with the command and the
revision every number came from. A document that mixes the two is split.

## releases

cyb, cyber and soft3 ride a weekly candidate train: a candidate is cut every
friday 12:00 UTC from the default branches, gated, published as a draft
pre-release with receipts, and promoted by the owner alone. Contributors and
agents cut candidates, run gates and open bump pull requests; the owner merges
bumps, promotes, publishes to crates.io and pushes tags.

## license

Unless a repository says otherwise: Cyber License. Don't trust. Don't fear.
Don't beg.
