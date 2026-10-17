# relay — repository events into the registry workflow

GitHub Actions has no trigger for a repository being created in an organization.
The `repository` event exists only as a webhook. This relay turns that webhook
into a `repository_dispatch` on `cyberia-to/.github`, which runs
`.github/workflows/registry.yml` within seconds of the change.

```
GitHub org webhook (event: repository)
  → https://cyb.ai/hooks/org-repo            nginx on cyberproxy, /hooks/ → localhost:9000
  → adnanh/webhook, hook id org-repo         verifies X-Hub-Signature-256, checks X-GitHub-Event
  → /home/cyber/hooks/org-repo.sh action name
  → POST /repos/cyberia-to/.github/dispatches  event_type org-repo
  → registry.yml: check, update, commit `chore: registry sync (created <name>)`
```

The hourly schedule in the same workflow stays on; the relay removes the lag.

## files

| file | where it runs | what |
| --- | --- | --- |
| `org-repo.sh` | cyberproxy, `/home/cyber/hooks/org-repo.sh` | reads the token, posts the dispatch |
| `hook.json.fragment` | cyberproxy, one entry in `/home/cyber/hooks/hook.json` | HMAC and event guard, argument mapping |
| `/home/cyber/hooks/org-repo.env` | cyberproxy, mode 600, never in git | `GITHUB_TOKEN=<fine-grained PAT>` |

## install

Server state is the truth; `cybernode/local/servers/cyberproxy.md` mirrors it.

1. Token. Fine-grained personal access token, resource owner cyberia-to, repository
   access: only `cyberia-to/.github`, permission Contents: read and write, expiry
   one year. Put it on the server:
   ```
   ssh cyberproxy 'umask 077; printf "GITHUB_TOKEN=%s\n" "<token>" > /home/cyber/hooks/org-repo.env'
   ```
2. Script and hook. Copy `org-repo.sh` to `/home/cyber/hooks/`, `chmod 755`. Add the
   fragment to `hook.json` with `ORG_HOOK_SECRET` replaced by a fresh secret
   (`openssl rand -hex 32`), then `sudo systemctl restart webhook-deploy`.
3. Organization webhook. Needs the `admin:org_hook` scope once:
   `gh auth refresh -h github.com -s admin:org_hook`, then
   ```
   gh api orgs/cyberia-to/hooks -X POST \
     -f name=web -F active=true -f 'events[]=repository' \
     -f config[url]=https://cyb.ai/hooks/org-repo \
     -f config[content_type]=json -f config[secret]=<same secret>
   ```
4. Prove it. `gh api orgs/cyberia-to/hooks/<id>/pings -X POST` answers 200 on the
   server side; the hook ignores a `ping` because `X-GitHub-Event` is `ping`. Create
   a throwaway repository, watch `gh run list -R cyberia-to/.github -w Registry`,
   delete the repository, watch again.

## events that reach the registry

`created`, `deleted`, `archived`, `unarchived`, `publicized`, `privatized`,
`renamed`, `transferred`, `edited` (description or homepage). All are actions of
the `repository` webhook; the script passes the action through so the commit
message says what happened.
