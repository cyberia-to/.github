#!/usr/bin/env nu
# sync-org.nu — reconcile GitHub org state with local filesystem and declarations
# dry-run only for session 1: computes and prints the plan, never mutates
# see SPEC.md for the full state machine

use std/log

# ---------- entry point ----------

def main [
    --apply                # apply non-destructive transitions (not yet implemented)
    --apply-renames        # apply rename plans (not yet implemented)
    --json                 # machine-readable plan output
    --only: string         # scope to one repo
] {
    if $apply or $apply_renames {
        print "--apply is not yet implemented in session 1; running dry-run"
    }

    let ws_root = (workspace-root)
    let ws = (load-workspace $ws_root)
    let lock = (load-lock $ws_root $ws.sync.lock_file)
    let decls = (load-declarations $ws_root)
    let org_state = (fetch-org-state $ws.org $json)
    let fs_state = (scan-filesystem ($ws.root_dir | path expand))

    let plan = (compute-plan $ws $lock $decls $org_state $fs_state $only)

    if $json {
        print ($plan | to json)
    } else {
        print-plan $plan $ws
    }

    exit (plan-exit-code $plan)
}

# ---------- workspace loading ----------

def workspace-root [] {
    # script lives at <root>/scripts/sync-org.nu
    # if run from .github/, pwd works; otherwise traverse up from script path
    let cwd = (pwd)
    if ($"($cwd)/workspace.toml" | path exists) {
        $cwd
    } else {
        error make {msg: "workspace.toml not found; run from .github/ root"}
    }
}

def load-workspace [root: string] {
    open $"($root)/workspace.toml"
}

def load-lock [root: string, lock_rel: string] {
    let path = $"($root)/($lock_rel)"
    if ($path | path exists) {
        open $path
    } else {
        {schema: 1, repos: {}, orphans: {}}
    }
}

def load-declarations [root: string] {
    let dir = $"($root)/subgraphs"
    if not ($dir | path exists) { return [] }
    let files = (glob $"($dir)/*.md")
    if ($files | length) == 0 { return [] }
    $files | each {|f|
        let parsed = (parse-declaration $f)
        $parsed | upsert _path $f
    }
}

def parse-declaration [path: string] {
    let raw = (open --raw $path)
    let fm = (extract-frontmatter $raw)
    $fm
}

def extract-frontmatter [raw: string] {
    let lines = ($raw | lines)
    if ($lines | length) < 2 or ($lines | get 0) != "---" {
        return {}
    }
    let end_idx = ($lines
        | enumerate
        | skip 1
        | where item == "---"
        | get index
        | first)
    if $end_idx == null { return {} }
    let yaml_lines = ($lines | skip 1 | first $end_idx)
    $yaml_lines | str join "\n" | from yaml
}

# ---------- github org state ----------

def fetch-org-state [org: string, quiet: bool] {
    if not $quiet { log info $"fetching org state for ($org)..." }
    let raw = (
        ^gh api $"/orgs/($org)/repos" --paginate
            --jq '.[] | {name, visibility, archived, default_branch, ssh_url, clone_url}'
    )
    $raw
        | lines
        | where ($it | str length) > 0
        | each { from json }
        | reduce --fold {} {|it, acc| $acc | upsert $it.name $it }
}

# ---------- filesystem state ----------

def scan-filesystem [root: string] {
    if not ($root | path exists) {
        return {}
    }
    ls $root
        | where type == dir
        | reduce --fold {} {|it, acc|
            let name = ($it.name | path basename)
            let classification = (classify-folder $it.name)
            $acc | upsert $name $classification
        }
}

def classify-folder [path: string] {
    let has_git = ($"($path)/.git" | path exists)
    if not $has_git {
        return {kind: "plain", path: $path, remote: null}
    }
    let remote = (try {
        ^git -C $path remote get-url origin | str trim
    } catch { null })
    {kind: "git", path: $path, remote: $remote}
}

# ---------- plan computation ----------

def compute-plan [ws, lock, decls, org_state, fs_state, only] {
    let org_names = ($org_state | columns)
    let policy = $ws.subgraphs.policy

    let relevant_org_names = if $only == null or ($only | is-empty) {
        $org_names
    } else {
        $org_names | where $it == $only
    }

    # for each org repo: figure out what to do
    let org_transitions = ($relevant_org_names | each {|name|
        let org_repo = ($org_state | get $name)
        let fs_entry = (try { $fs_state | get $name } catch { null })
        let decl = ($decls | where name == $name | first)
        let lock_entry = (try { $lock | get $"repos.($name)" } catch { null })

        classify-transition $name $org_repo $fs_entry $decl $lock_entry $policy
    })

    # for each local folder not in org: flag as foreign/orphan/local-only
    let fs_names = ($fs_state | columns)
    let fs_only = ($fs_names | where $it not-in $org_names | each {|name|
        let fs_entry = ($fs_state | get $name)
        classify-fs-only $name $fs_entry
    })

    {
        org:          $ws.org
        root_dir:     ($ws.root_dir | path expand)
        transitions:  $org_transitions
        fs_orphans:   $fs_only
        summary:      (summarize $org_transitions $fs_only)
    }
}

def classify-transition [name, org_repo, fs_entry, decl, lock_entry, policy] {
    # skip the .github repo itself — it is the workspace anchor, not a subgraph to clone
    if $name == ".github" {
        return {repo: $name, event: "workspace-self", detail: "this repo is the workspace root"}
    }

    # archived handling
    if $org_repo.archived {
        if $fs_entry == null {
            return {repo: $name, event: "archived-skip", detail: "archived upstream; not cloning"}
        }
        if $decl == null or ($decl.archived? | default false) != true {
            return {repo: $name, event: "archive", detail: "mark declaration archived: true"}
        }
        return {repo: $name, event: "noop", detail: "archived, already marked"}
    }

    # not cloned
    if $fs_entry == null {
        if $decl == null {
            let vis = $org_repo.visibility
            let detail = $"clone and create declaration, visibility ($vis)"
            return {repo: $name, event: "add", detail: $detail}
        }
        return {repo: $name, event: "add-clone", detail: "declaration exists; clone missing"}
    }

    # folder exists
    if $fs_entry.kind == "plain" {
        let p = $fs_entry.path
        let detail = $"plain folder ($p) shadows org repo name"
        return {repo: $name, event: "shadow-conflict", detail: $detail}
    }

    let expected_remote_ssh = $"git@github.com:cyberia-to/($name).git"
    let expected_remote_https = $"https://github.com/cyberia-to/($name).git"
    let remote_match = (
        $fs_entry.remote == $expected_remote_ssh or
        $fs_entry.remote == $expected_remote_https
    )

    if not $remote_match {
        let r = $fs_entry.remote
        let detail = $"remote ($r), expected ($expected_remote_ssh)"
        return {repo: $name, event: "foreign-or-rename", detail: $detail}
    }

    # tracked repo; check flag reconciliation
    let decl_vis = if $decl == null { null } else { $decl.visibility? }
    let vis_drift = ($decl != null and $decl_vis != $org_repo.visibility)
    let decl_arch = if $decl == null { false } else { ($decl.archived? | default false) }
    let arch_drift = ($decl_arch != $org_repo.archived)

    if $decl == null {
        return {repo: $name, event: "adopt", detail: "clone present; create declaration stub"}
    }

    if $vis_drift {
        let new_vis = $org_repo.visibility
        let detail = $"declaration ($decl_vis), org ($new_vis)"
        return {repo: $name, event: "visibility-flip", detail: $detail}
    }

    if $arch_drift {
        return {repo: $name, event: "archive-drift", detail: "declaration archive flag mismatch"}
    }

    {repo: $name, event: "fetch", detail: "tracked; would git fetch"}
}

def classify-fs-only [name, fs_entry] {
    if $fs_entry.kind == "plain" {
        return {repo: $name, kind: "local-folder", detail: "plain directory, no org counterpart"}
    }
    if $fs_entry.remote == null {
        return {repo: $name, kind: "no-remote", detail: "git repo with no remote"}
    }
    let is_org = ($fs_entry.remote | str contains "cyberia-to/")
    if $is_org {
        let r = $fs_entry.remote
        let detail = $"cyberia-to remote but not in org list ($r)"
        {repo: $name, kind: "orphan-or-rename", detail: $detail}
    } else {
        let r = $fs_entry.remote
        let detail = $"remote points elsewhere ($r)"
        {repo: $name, kind: "foreign", detail: $detail}
    }
}

def summarize [transitions, fs_only] {
    let by_event = ($transitions | group-by event | transpose event items | each {|r| {event: $r.event, count: ($r.items | length)}})
    let fs_by_kind = ($fs_only | group-by kind | transpose kind items | each {|r| {kind: $r.kind, count: ($r.items | length)}})
    {events: $by_event, fs_orphans: $fs_by_kind}
}

# ---------- output ----------

def print-plan [plan, ws] {
    print $"workspace: ($plan.org) @ ($plan.root_dir)"
    print ""

    print "org transitions:"
    print ($plan.transitions | sort-by event | select repo event detail | table --expand)
    print ""

    if ($plan.fs_orphans | length) > 0 {
        print "filesystem entries not in org:"
        print ($plan.fs_orphans | select repo kind detail | table --expand)
        print ""
    }

    print "summary:"
    print ($plan.summary.events | table)
    if ($plan.summary.fs_orphans | length) > 0 {
        print ($plan.summary.fs_orphans | table)
    }
    print ""

    let muts = ($plan.transitions | where event not-in ["noop" "fetch" "workspace-self" "archived-skip"])
    if ($muts | length) == 0 {
        print "plan: no transitions needed (clean)"
    } else {
        print $"plan: ($muts | length) transitions pending review"
        print "dry-run complete. re-run with --apply to execute (session 1: not yet implemented)"
    }
}

def plan-exit-code [plan] {
    let shadow = ($plan.transitions | where event == "shadow-conflict" | length)
    if $shadow > 0 { return 10 }

    let muts = ($plan.transitions | where event not-in ["noop" "fetch" "workspace-self" "archived-skip"])
    if ($muts | length) == 0 { 0 } else { 1 }
}
