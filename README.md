# cyberia-to workspace

Org workspace root. Holds the org profile, sync tooling, subgraph declarations, and build orchestration for the cybergraph.

## Onboarding

```
git clone https://github.com/cyberia-to/.github.git ~/cyberia-to/.github
cd ~/cyberia-to/.github
nu scripts/sync-org.nu              # dry-run; prints the plan
nu scripts/sync-org.nu --apply      # clones every repo gh auth can see
```

After sync:
- public contributor: workspace contains every non-archived public repo
- org member: workspace additionally contains private repos

One script, same layout for everyone. Auth scope is the only difference.

## Layout

```
.github/                         # this repo — workspace anchor
├── workspace.toml               # org config, root graph, policy
├── subgraphs.lock.toml          # reconciler memory (committed)
├── scripts/
│   ├── sync-org.nu              # reconciler: org ↔ filesystem ↔ declarations
│   ├── build.nu                 # materialize optica config, invoke build
│   └── serve.nu                 # build + optica serve
├── subgraphs/                   # one declaration per org repo
├── context/                     # shared contributor context
├── profile/README.md            # org profile page (github convention)
└── .github/workflows/           # reusable CI workflows

~/cyberia-to/                    # workspace root
├── .github/                     # (this repo)
├── cyber/                       # root namespace donor
├── trident/
├── hemera/
└── ...                          # one dir per org repo
```

## Principles

1. GitHub org is the source of truth for membership, visibility, archive state, canonical name.
2. Local clones are a cache. The reconciler never touches working trees.
3. Declaration files own graph inclusion. The reconciler writes scoped keys only.
4. Mutations require `--apply`. Destructive-adjacent operations require a second opt-in.
5. Never delete. Orphans are reported, never removed.

See `SPEC.md` for the full reconciliation model.

## Tools

- `nu` — nushell 0.110+
- `gh` — GitHub CLI, authenticated
- `optica` — build tool, at `~/git/optica` or installed binary

## License

Cyber License: Don't trust. Don't fear. Don't beg.
