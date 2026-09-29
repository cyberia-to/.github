#!/bin/sh
# org-repo — relays an organization `repository` webhook into a repository_dispatch
# on cyberia-to/.github, so the registry workflow runs the moment a repository is
# created, renamed, archived, transferred or changes visibility.
#
# Runs on cyberproxy under adnanh/webhook (hook id: org-repo, see hook.json.fragment).
# Arguments come from the payload: $1 = action, $2 = repository.name.
# Token comes from /home/cyber/hooks/org-repo.env:
#   GITHUB_TOKEN=<fine-grained PAT, repository cyberia-to/.github, Contents: read and write>
set -eu

ENV_FILE="${ORG_REPO_ENV:-/home/cyber/hooks/org-repo.env}"
# shellcheck disable=SC1090
. "$ENV_FILE"

action="${1:-unknown}"
repo="${2:-unknown}"

case "$repo" in
  *[!A-Za-z0-9._-]*) echo "org-repo: refusing repository name '$repo'" >&2; exit 1 ;;
esac
case "$action" in
  *[!a-z_]*) echo "org-repo: refusing action '$action'" >&2; exit 1 ;;
esac

curl -fsS -X POST "https://api.github.com/repos/cyberia-to/.github/dispatches" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "{\"event_type\":\"org-repo\",\"client_payload\":{\"action\":\"$action\",\"repository\":\"$repo\"}}"

logger -t org-repo "dispatched $action $repo" 2>/dev/null || true
echo "org-repo: dispatched $action $repo"
