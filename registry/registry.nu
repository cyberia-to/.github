#!/usr/bin/env nu
# registry — the inventory of every repository in the cyberia-to organization.
#
# Sources, in order of authority:
#   1. the GitHub API — membership, visibility, archive state, description, language, homepage
#   2. soft3/release/components.toml on origin/main — the ladder: which rung a repository sits on
#   3. registry/groups.toml — shelves outside the ladder and rung corrections
#
# Commands:
#   nu registry/registry.nu render [--all] [--out <path>]   print the registry markdown
#   nu registry/registry.nu update                          rewrite the section in README.md (public rows only)
#   nu registry/registry.nu check                           exit 1 when README.md drifts from the API
#   nu registry/registry.nu lint [--all]                    repositories missing description, topics, homepage, group
#
# `render` and `lint` see whatever the caller's token sees: a member's `gh auth`
# shows private repositories, the Actions token shows public ones. The README
# carries public rows only, so `update` filters regardless of the token.

const ORG = "cyberia-to"
const LADDER_REPO = "soft3"
const LADDER_PATH = "release/components.toml"
const START = "<!-- registry:start -->"
const END = "<!-- registry:end -->"

const RAILS = [
  {name: "kernel", layers: [1 2 3],   line: "what computes and proves, for any project"}
  {name: "core",   layers: [4 5 6 7], line: "what knows and connects: the soft3 stack proper"}
  {name: "apps",   layers: [8 9 10],  line: "what people use"}
]

def registry-root [] { $env.CURRENT_FILE | path dirname }
def repo-root [] { registry-root | path dirname }

# --- sources -----------------------------------------------------------------

def fetch-repos [] {
  ^gh repo list $ORG -L 1000 --json name,description,visibility,isArchived,isFork,primaryLanguage,homepageUrl,repositoryTopics,licenseInfo
  | from json
  | each {|r| {
      name: $r.name
      description: ($r.description | default "" | str trim)
      visibility: ($r.visibility | str downcase)
      archived: $r.isArchived
      fork: $r.isFork
      language: ($r.primaryLanguage | default {} | get -o name | default "")
      homepage: ($r.homepageUrl | default "")
      topics: ($r.repositoryTopics | default [] | each {|t| $t.name })
      license: ($r.licenseInfo | default {} | get -o key | default "")
    }}
  | sort-by name
}

def fetch-ladder [] {
  ^gh api $"repos/($ORG)/($LADDER_REPO)/contents/($LADDER_PATH)" -H "Accept: application/vnd.github.raw"
  | from toml
  | get component
}

def load-groups [] { open (registry-root | path join groups.toml) }

# --- placement ---------------------------------------------------------------

# products: the ten rungs, name → {layer, role}
def products [ladder] {
  $ladder | where ($it | get -o role | default "") != "" | select name layer role
}

# repo → rung name, from the ladder file: a component whose repo is the repository.
# A product on its own repository wins; then the part_of of any crate, network,
# ops or product that lives there; then the part_of of any part.
def ladder-placement [ladder, groups] {
  let prods = products $ladder
  let prod_names = $prods | get name
  let by_repo = $ladder | group-by repo
  let from_ladder = $by_repo | transpose repo comps | each {|row|
    let comps = $row.comps
    let own_product = $comps | where ($it.name in $prod_names) | get -o 0.name
    let crate_parent = $comps | where kind != "part" | get -o part_of | compact | get -o 0
    let part_parent = $comps | where kind == "part" | get -o part_of | compact | get -o 0
    let rung = [$own_product $crate_parent $part_parent] | compact | where $it != "" | get -o 0
    let rung = if $rung == null { null } else { rung-up $ladder $prod_names $rung }
    if $rung == null { null } else { {repo: $row.repo, rung: $rung} }
  } | compact
  let overrides = $groups.rung | transpose repo rung
  $from_ladder | append $overrides | uniq-by repo
}

# follow part_of from a component name up to the product it belongs to
# (sigma → chroma → cy); null when the chain ends without a product
def rung-up [ladder, prod_names, name, depth = 0] {
  if $name in $prod_names { return $name }
  if $depth > 8 { return null }
  let parent = $ladder | where name == $name | get -o 0.part_of
  if $parent == null or $parent == "" { null } else { rung-up $ladder $prod_names $parent ($depth + 1) }
}

def rung-of [placement, name] {
  $placement | where repo == $name | get -o 0.rung
}

def shelf-of [groups, name] {
  $groups.group | where ($name in $it.repos) | get -o 0.name
}

# Every repository with its section: {section, order, ...repo}
def place [repos, ladder, groups] {
  let placement = ladder-placement $ladder $groups
  let prods = products $ladder
  let shelves = $groups.group | enumerate | each {|g| {name: $g.item.name, order: (100 + $g.index)}}
  $repos | each {|r|
    let rung = rung-of $placement $r.name
    if $rung != null {
      let p = $prods | where name == $rung | get -o 0
      $r | merge {section: $"($p.layer) ($rung) · ($p.role)", order: $p.layer, rail: (rail-of $p.layer)}
    } else {
      let shelf = shelf-of $groups $r.name
      if $shelf != null {
        $r | merge {section: $shelf, order: ($shelves | where name == $shelf | get 0.order), rail: "shelves"}
      } else {
        $r | merge {section: "unsorted", order: 999, rail: "shelves"}
      }
    }
  }
}

def rail-of [layer: int] { $RAILS | where ($layer in $it.layers) | get 0.name }

# --- rendering ---------------------------------------------------------------

def cell [s: string] { $s | str replace --all "|" "\\|" | str replace --all "\n" " " }

def render-table [rows] {
  let header = "| repository | what | language | site |\n| --- | --- | --- | --- |"
  let body = $rows | sort-by name | each {|r|
    let flags = [
      (if $r.archived { "archived" } else { "" })
      (if $r.fork { "fork" } else { "" })
      (if $r.visibility == "private" { "private" } else { "" })
    ] | where $it != "" | str join ", "
    let name = if $flags == "" { $"[($r.name)]\(https://github.com/($ORG)/($r.name)\)" } else { $"[($r.name)]\(https://github.com/($ORG)/($r.name)\) · ($flags)" }
    let site = if $r.homepage == "" { "" } else { $"[($r.homepage | str replace -r '^https?://' '' | str trim -c '/')]\(($r.homepage)\)" }
    $"| ($name) | (cell $r.description) | ($r.language) | ($site) |"
  } | str join "\n"
  $"($header)\n($body)"
}

def render-registry [repos, ladder, groups] {
  let placed = place $repos $ladder $groups
  let total = $placed | length
  let public = $placed | where visibility == "public" | length
  let private = $placed | where visibility == "private" | length
  let archived = $placed | where archived | length
  let counts = if $private == 0 {
    $"($public) public repositories, ($archived) archived. Private repositories are inventoried locally with the same script: `nu registry/registry.nu render --all`."
  } else {
    $"($total) repositories: ($public) public, ($private) private, ($archived) archived."
  }
  let ladder_note = $"The rungs follow [soft3.org/layers]\(https://soft3.org/layers\) and `soft3/release/components.toml`; the shelves follow `registry/groups.toml`."

  let rails = $RAILS | each {|rail|
    let sections = $placed | where rail == $rail.name | group-by section | transpose section rows | sort-by {|s| $s.rows.0.order }
    if ($sections | is-empty) { return "" }
    let blocks = $sections | each {|s| $"#### ($s.section)\n\n(render-table $s.rows)" } | str join "\n\n"
    $"### ($rail.name)\n\n($rail.line)\n\n($blocks)"
  } | where $it != ""

  let shelf_sections = $placed | where rail == "shelves" | group-by section | transpose section rows | sort-by {|s| $s.rows.0.order }
  let shelves = $shelf_sections | each {|s|
    let line = $groups.group | where name == $s.section | get -o 0.line | default "repositories the registry has not placed yet: add them to registry/groups.toml or to the ladder"
    $"### ($s.section)\n\n($line)\n\n(render-table $s.rows)"
  }

  ([$counts $ladder_note] | append $rails | append $shelves | str join "\n\n") + "\n"
}

def public-only [repos] { $repos | where visibility == "public" }

def readme-path [] { repo-root | path join README.md }

def split-readme [] {
  let lines = open --raw (readme-path) | lines
  let s = $lines | enumerate | where item == $START | get -o 0.index
  let e = $lines | enumerate | where item == $END | get -o 0.index
  if $s == null or $e == null or $e <= $s {
    error make {msg: $"README.md needs the markers ($START) and ($END), in that order"}
  }
  {head: ($lines | take ($s + 1)), body: ($lines | skip ($s + 1) | take ($e - $s - 1)), tail: ($lines | skip $e)}
}

def current-section [] { split-readme | get body | str join "\n" | str trim }

def public-section [] {
  render-registry (public-only (fetch-repos)) (fetch-ladder) (load-groups) | str trim
}

# --- commands ----------------------------------------------------------------

def main [] {
  print "registry — the inventory of every repository in cyberia-to"
  print ""
  print "  nu registry/registry.nu render [--all] [--out <path>]"
  print "  nu registry/registry.nu update"
  print "  nu registry/registry.nu check"
  print "  nu registry/registry.nu lint [--all]"
}

# Print the registry. Public rows by default; --all includes what the token sees.
def "main render" [--all, --out: path] {
  let repos = fetch-repos
  let repos = if $all { $repos } else { public-only $repos }
  let md = render-registry $repos (fetch-ladder) (load-groups)
  if $out == null { print -n $md } else {
    mkdir ($out | path dirname)
    $md | save -f $out
    print $"wrote ($out): ($repos | length) repositories"
  }
}

# Rewrite the registry section of README.md with public rows.
def "main update" [] {
  let parts = split-readme
  let section = public-section
  let out = $parts.head | append "" | append ($section | lines) | append "" | append $parts.tail | str join "\n"
  ($out + "\n") | save -f (readme-path)
  print $"README.md registry section updated"
}

# Exit 1 when README.md differs from what the API renders now.
def "main check" [] {
  let want = public-section
  let have = current-section
  if $want == $have {
    print "registry: README.md matches the organization"
  } else {
    let tmp_want = mktemp -t registry-want.XXXXXX
    let tmp_have = mktemp -t registry-have.XXXXXX
    $want | save -f $tmp_want
    $have | save -f $tmp_have
    print "registry: README.md drifted from the organization"
    ^diff -u $tmp_have $tmp_want | complete | get stdout | print
    rm -f $tmp_want $tmp_have
    exit 1
  }
}

# Repositories the registry can see but cannot describe or place.
def "main lint" [--all] {
  let repos = fetch-repos
  let repos = if $all { $repos } else { public-only $repos }
  let placed = place $repos (fetch-ladder) (load-groups)
  let live = $placed | where not archived
  let findings = [
    {check: "unsorted", repos: ($live | where section == "unsorted" | get name)}
    {check: "no description", repos: ($live | where description == "" | get name)}
    {check: "no topics", repos: ($live | where ($it.topics | is-empty) | get name)}
    {check: "no license", repos: ($live | where license == "" and visibility == "public" | get name)}
  ]
  print $"## registry lint\n\n($live | length) repositories checked \(archived skipped\).\n"
  print "| check | count | repositories |\n| --- | --- | --- |"
  for f in $findings {
    print $"| ($f.check) | ($f.repos | length) | ($f.repos | str join ', ') |"
  }
}
