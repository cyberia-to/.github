# cyberia-to

Cyberia is the cyberstate led by superintelligence. This repository is the door
to the organization: the map of every repository, the defaults every repository
inherits, and the workflow that keeps the map true.

## start here

| you are | read |
| --- | --- |
| new to the whole thing | [profile](profile/README.md) — what soft3, cyb, cyber and cyberia are, in four lines each |
| looking for a repository | the [registry](#registry) below, placed on the ten rungs of the soft3 ladder |
| about to contribute | [CONTRIBUTING.md](CONTRIBUTING.md), then the repository's own `CLAUDE.md` or `AGENTS.md` for its gates |
| reporting a vulnerability | [SECURITY.md](SECURITY.md) |
| lost | [SUPPORT.md](SUPPORT.md) |

Four surfaces carry the work: [soft3.org](https://soft3.org) is the stack,
[cyb.ai](https://cyb.ai) is the robot, [cyber.page](https://cyber.page) is the
protocol, [cyberia.to](https://cyberia.to) is the state. The doctrine every
contributor and agent works by is
[cyberia/dev.md](https://github.com/cyberia-to/cyberia/blob/main/dev.md).

## registry

Every repository of the organization, generated from the GitHub API and placed
by `soft3/release/components.toml` (the ladder) and
[`registry/groups.toml`](registry/groups.toml) (the shelves). The section
between the markers is written by `nu registry/registry.nu update`; edits inside
it are overwritten within the hour.

<!-- registry:start -->

75 public repositories, 3 archived. Private repositories are inventoried locally with the same script: `nu registry/registry.nu render --all`.

The rungs follow [soft3.org/layers](https://soft3.org/layers) and `soft3/release/components.toml`; the shelves follow `registry/groups.toml`.

### kernel

what computes and proves, for any project

#### 1 nox · machine

| repository | what | language | site |
| --- | --- | --- | --- |
| [hemera](https://github.com/cyberia-to/hemera) | 💧 the hash | Rust |  |
| [honeycrisp](https://github.com/cyberia-to/honeycrisp) | tasty apple | Rust |  |
| [nox](https://github.com/cyberia-to/nox) | the vm | Rust |  |
| [strata](https://github.com/cyberia-to/strata) | five algebras | Rust |  |

#### 2 trident · weapon

| repository | what | language | site |
| --- | --- | --- | --- |
| [trident](https://github.com/cyberia-to/trident) | 👽 language from future | Rust | [trident.pink](https://trident.pink) |

#### 3 joy · warrior

| repository | what | language | site |
| --- | --- | --- | --- |
| [bbg](https://github.com/cyberia-to/bbg) | big badass graph | Rust |  |
| [joy](https://github.com/cyberia-to/joy) | the cyber warrior | Rust |  |
| [lens](https://github.com/cyberia-to/lens) | polynomial commitments | Rust |  |
| [zheng](https://github.com/cyberia-to/zheng) | polynomial proof system | Rust |  |

### core

what knows and connects: the soft3 stack proper

#### 4 cybergraph · brain

| repository | what | language | site |
| --- | --- | --- | --- |
| [cybergraph](https://github.com/cyberia-to/cybergraph) | cyberlink processor | Rust |  |
| [file](https://github.com/cyberia-to/file) | Content-addressed files, particle identities and content kinds. | Rust |  |
| [neuron](https://github.com/cyberia-to/neuron) | the protocol subject and its optional durable execution model | Rust |  |
| [plumb](https://github.com/cyberia-to/plumb) |  | Rust |  |
| [tru](https://github.com/cyberia-to/tru) | convergence vm | Rust |  |

#### 5 neural · language

| repository | what | language | site |
| --- | --- | --- | --- |
| [eidos](https://github.com/cyberia-to/eidos) | proof assistant | Rust |  |
| [inf](https://github.com/cyberia-to/inf) | provable graph queries | Rust |  |
| [mudra](https://github.com/cyberia-to/mudra) | crypto magic | Rust |  |
| [neural](https://github.com/cyberia-to/neural) | graph language | Rust |  |
| [nu](https://github.com/cyberia-to/nu) | Nushell source for Cyb, pinned and qualified through soft3 | Rust |  |
| [rs](https://github.com/cyberia-to/rs) | 🏍 safer, faster, field-first rust | Rust |  |
| [rune](https://github.com/cyberia-to/rune) | dynamic language | Rust |  |
| [spark](https://github.com/cyberia-to/spark) | render for most formats | Rust |  |

#### 6 cy · agent

| repository | what | language | site |
| --- | --- | --- | --- |
| [cy](https://github.com/cyberia-to/cy) | the 🧬 agent: the mind over the book — headless anywhere |  |  |
| [glia](https://github.com/cyberia-to/glia) | universal .model runtime: import (source → .model) + run (honeycrisp/wgpu/cpu backends) | Rust |  |
| [seer](https://github.com/cyberia-to/seer) | seer — the proposer: what a neuron should link next |  |  |
| [sigma](https://github.com/cyberia-to/sigma) | Σ the sum: a neuron's tokens, valued in the token of your choice |  |  |
| [soma](https://github.com/cyberia-to/soma) | machine mind |  |  |
| [vault](https://github.com/cyberia-to/vault) | secret storage | Rust |  |

#### 7 soft3 · network

| repository | what | language | site |
| --- | --- | --- | --- |
| [foculus](https://github.com/cyberia-to/foculus) | consensus by convergence | Rust |  |
| [radio](https://github.com/cyberia-to/radio) | communication system | Rust |  |
| [soft3](https://github.com/cyberia-to/soft3) | type 2 civilization stack | Rust | [soft3.org](https://soft3.org) |
| [soft3.js](https://github.com/cyberia-to/soft3.js) |  | TypeScript |  |
| [tade](https://github.com/cyberia-to/tade) | typed annotated data exchange | Rust |  |

### apps

what people use

#### 8 cyb · robot

| repository | what | language | site |
| --- | --- | --- | --- |
| [cyb](https://github.com/cyberia-to/cyb) | 🤖 immortal robot | Rust | [cyb.ai](https://cyb.ai) |
| [evy](https://github.com/cyberia-to/evy) |  | Rust |  |
| [lytics](https://github.com/cyberia-to/lytics) | Just Lytics. No Anal. | Rust |  |
| [mir](https://github.com/cyberia-to/mir) | R-1.0 world renderer: tru field state + glia features → deterministic 3D graph world | Rust |  |
| [optica](https://github.com/cyberia-to/optica) | graph render for any repo | Rust |  |
| [prysm](https://github.com/cyberia-to/prysm) | world class design | Rust |  |
| [wysm](https://github.com/cyberia-to/wysm) | soft3 wasm | Rust | [cyb.ai](https://cyb.ai) |

#### 9 cyber · superintelligence

| repository | what | language | site |
| --- | --- | --- | --- |
| [bostrom](https://github.com/cyberia-to/bostrom) | 🟢 the bootloader of superintelligence | JavaScript | [bostrom.network](https://bostrom.network) |
| [cyber](https://github.com/cyberia-to/cyber) | the 🟢 superintelligence | Nushell | [cyber.page](https://cyber.page) |
| [space-pussy](https://github.com/cyberia-to/space-pussy) · archived, fork | Your 🟣 Pussy | TypeScript | [spacepussy.ai](https://spacepussy.ai) |
| [true-cyber](https://github.com/cyberia-to/true-cyber) | cyber product CLI — cargo install true-cyber → binary cyber | Rust |  |

#### 10 cyberia · state

| repository | what | language | site |
| --- | --- | --- | --- |
| [blog](https://github.com/cyberia-to/blog) | chronicle and knowledge | Nushell | [cyberia.blog](https://cyberia.blog) |
| [cx](https://github.com/cyberia-to/cx) | century index | Rust |  |
| [cyber-valley](https://github.com/cyberia-to/cyber-valley) | genesis city |  | [cybervalley.io](https://cybervalley.io) |
| [cyberia](https://github.com/cyberia-to/cyberia) | the cyberstate | Python | [cyberia.to](https://cyberia.to) |
| [cyberia-my](https://github.com/cyberia-to/cyberia-my) | cyberstate interface | Rust |  |
| [cyberstates](https://github.com/cyberia-to/cyberstates) | sovereignty terminal | Rust | [cyberstates.net](https://cyberstates.net) |

### warriors

the computing army: miners and provers for every chain worth the electricity

| repository | what | language | site |
| --- | --- | --- | --- |
| [erga](https://github.com/cyberia-to/erga) | $ERGO miner on Apple Silicon | Rust |  |
| [trisha](https://github.com/cyberia-to/trisha) | triton + neptune warrior | Rust |  |

### languages

seeds of the neural dialects: one repository per way of speaking

| repository | what | language | site |
| --- | --- | --- | --- |
| [arc](https://github.com/cyberia-to/arc) |  |  |  |
| [bel](https://github.com/cyberia-to/bel) |  |  |  |
| [bt](https://github.com/cyberia-to/bt) |  |  |  |
| [dif](https://github.com/cyberia-to/dif) |  |  |  |
| [ren](https://github.com/cyberia-to/ren) |  |  |  |
| [sec](https://github.com/cyberia-to/sec) |  |  |  |
| [seq](https://github.com/cyberia-to/seq) |  |  |  |
| [sym](https://github.com/cyberia-to/sym) |  |  |  |
| [ten](https://github.com/cyberia-to/ten) |  |  |  |

### cyberia

the state beyond the ladder: capital, membership, the presidency and the pages

| repository | what | language | site |
| --- | --- | --- | --- |
| [cyberia-meme](https://github.com/cyberia-to/cyberia-meme) | cyberia.meme — the meme state. a meme is a particle. | CSS |  |
| [cyberia.my](https://github.com/cyberia-to/cyberia.my) | what cyberia.my serves beside the SPA — published pages, synced to the docroot by cron | HTML |  |
| [cyberia.to](https://github.com/cyberia-to/cyberia.to) | what cyberia.to serves — the page and the set, synced to the docroot by cron | JavaScript |  |

### land

the genesis city and its species, soil and buildings

| repository | what | language | site |
| --- | --- | --- | --- |
| [cloud-forest](https://github.com/cyberia-to/cloud-forest) | species research — highland cloud-forest climate (Gesing / Cyber Valley) |  |  |
| [cybervalley](https://github.com/cyberia-to/cybervalley) | cybervalley.io — autonomous genesis city in the heart of Bali | HTML | [cybervalley.io](http://cybervalley.io/) |
| [cybervalley-io](https://github.com/cyberia-to/cybervalley-io) |  | HTML |  |

### cybics

mother science and the crystal: the world at large, written down

| repository | what | language | site |
| --- | --- | --- | --- |
| [crystal](https://github.com/cyberia-to/crystal) |  |  |  |
| [cybics](https://github.com/cyberia-to/cybics) | mother science |  |  |
| [simulation](https://github.com/cyberia-to/simulation) |  | Rust |  |

### bootloader

what carried the idea before soft3: the chains, the sdk, the vehicles

| repository | what | language | site |
| --- | --- | --- | --- |
| [bootloader](https://github.com/cyberia-to/bootloader) |  | Python |  |
| [chaingear](https://github.com/cyberia-to/chaingear) · archived | The consensus computer driven database framework | JavaScript | [cloudflare-ipfs.com/ipfs/QmQmQKkPFqLS4iNiicvAqx6aJtRpYookK8iEZjojcfEqib](https://cloudflare-ipfs.com/ipfs/QmQmQKkPFqLS4iNiicvAqx6aJtRpYookK8iEZjojcfEqib) |
| [episode-1](https://github.com/cyberia-to/episode-1) · fork |  | JavaScript |  |
| [go-cyber](https://github.com/cyberia-to/go-cyber) · archived | 🟢 cybergraph prototype sdk | TypeScript | [bostrom.network](https://bostrom.network) |

### org

the organization itself

| repository | what | language | site |
| --- | --- | --- | --- |
| [.github](https://github.com/cyberia-to/.github) | 🏴‍☠️ org | Nushell | [cyberia.to](https://cyberia.to) |

<!-- registry:end -->

### how the registry stays true

- [`registry/registry.nu`](registry/registry.nu) reads the organization,
  the ladder and the shelves, renders the table, and compares it with this file.
- [`Registry`](.github/workflows/registry.yml) runs every hour, on every
  repository event relayed from the organization webhook
  ([relay/](relay/README.md)), and by hand. Drift is fixed with a commit
  `chore: registry sync (<event>)`. On a pull request the workflow only
  verifies and fails when the section is stale.
- `nu registry/registry.nu lint` lists repositories without description, topics,
  license or placement; the workflow writes it to the run summary. The fix for
  a missing description is on GitHub, the fix for a missing placement is in
  `groups.toml` or in the ladder.
- The public README lists public repositories. A member sees the whole
  organization with the same script, locally:
  `nu registry/registry.nu render --all --out build/registry.md`
  (`build/` is ignored by git).

## what this repository holds

```
README.md                          the door and the registry
profile/README.md                  the organization profile GitHub shows
registry/registry.nu               the registry: render, update, check, lint
registry/groups.toml               shelves outside the ladder, rung corrections
relay/                             organization webhook → repository_dispatch, runs on cyberproxy
SECURITY.md CONTRIBUTING.md        defaults inherited by every repository without its own
CODE_OF_CONDUCT.md SUPPORT.md
.github/ISSUE_TEMPLATE/config.yml  default issue chooser: routes to the registry and to advisories
.github/PULL_REQUEST_TEMPLATE.md   default pull request body
.github/CODEOWNERS                 owners of this repository
.github/workflows/registry.yml     the registry workflow
workflow-templates/                starter workflows offered in every repository's Actions tab
```

Defaults from this repository apply to public and private repositories alike;
a repository with its own file keeps its own.

## license

Cyber License. Don't trust. Don't fear. Don't beg.
