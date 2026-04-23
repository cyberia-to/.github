#!/usr/bin/env nu
# build.nu — materialize optica subgraph config from the workspace and invoke optica
#
# Reads: workspace.toml + subgraphs/*.md declarations
# Writes: /tmp/optica-subgraphs.toml (ephemeral)
# Invokes: optica build <root_graph> --subgraphs /tmp/optica-subgraphs.toml

def main [
    --public-only          # exclude private + local-only subgraphs (for public deploys)
    --output: path         # override output directory
    --optica: path         # path to optica binary (defaults to ~/cyberia-to/optica/target/release/optica)
] {
    let ws_root = (workspace-root)
    let ws = (open $"($ws_root)/workspace.toml")
    let root_dir = ($ws.root_dir | path expand)
    let root_graph = ($root_dir | path join $ws.graph.root_subgraph)

    let decls = (load-declarations $ws_root)
    let filtered = (filter-decls $decls $public_only)

    let subgraphs = ($filtered | each {|d|
        {
            name: $d.name,
            path: ($root_dir | path join $d.repo),
        }
    })

    let config_path = "/tmp/optica-subgraphs.toml"
    let toml_content = ({subgraphs: $subgraphs} | to toml)
    $toml_content | save --force $config_path

    let optica_bin = if $optica == null {
        $"($env.HOME)/cyberia-to/optica/target/release/optica"
    } else {
        $optica
    }

    if not ($optica_bin | path exists) {
        error make {msg: $"optica binary not found at ($optica_bin). build it with: cd ($env.HOME)/cyberia-to/optica && cargo build --release"}
    }

    print $"root graph: ($root_graph)"
    print $"subgraphs: ($subgraphs | length)"
    print $"config: ($config_path)"
    print ""

    let out = if $output == null { $ws.graph.output } else { $output }
    ^$optica_bin build $root_graph --output $out --subgraphs $config_path
}

def workspace-root [] {
    let cwd = (pwd)
    if ($"($cwd)/workspace.toml" | path exists) {
        $cwd
    } else {
        error make {msg: "workspace.toml not found; run from .github/ root"}
    }
}

def load-declarations [root: string] {
    let dir = $"($root)/subgraphs"
    if not ($dir | path exists) { return [] }
    let files = (glob $"($dir)/*.md")
    if ($files | length) == 0 { return [] }
    $files | each {|f|
        let parsed = (parse-declaration $f)
        $parsed | merge {_path: $f}
    } | where ($it.name? | is-not-empty)
}

def parse-declaration [path: string] {
    let raw = (open --raw $path)
    let split = (split-frontmatter $raw)
    if $split.frontmatter == null { return {} }
    try { $split.frontmatter | from yaml } catch { {} }
}

def split-frontmatter [raw: string] {
    let lines = ($raw | lines)
    if ($lines | length) < 2 or ($lines | get 0) != "---" {
        return {frontmatter: null, body: $raw}
    }
    let end_idx = ($lines
        | enumerate
        | skip 1
        | where item == "---"
        | get index
        | first)
    if $end_idx == null { return {frontmatter: null, body: $raw} }
    let fm_lines = ($lines | skip 1 | take ($end_idx - 1))
    let body_lines = ($lines | skip ($end_idx + 1))
    {
        frontmatter: ($fm_lines | str join "\n")
        body: ($body_lines | str join "\n")
    }
}

def filter-decls [decls, public_only: bool] {
    $decls
        | where ($it.archived? | default false) != true
        | where ($it.orphan? | default false) != true
        | where ($it.name? | default "") != ".github"       # workspace self does not publish
        | where {|d|
            if not $public_only {
                true
            } else {
                let vis = ($d.visibility? | default "public")
                let local_only = ($d.local-only? | default false)
                $vis == "public" and not $local_only
            }
        }
}
