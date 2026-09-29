# security

This policy applies to every repository of the cyberia-to organization that does
not carry its own `SECURITY.md`.

## reporting

Report a vulnerability privately through GitHub: open the Security tab of the
affected repository and choose Report a vulnerability. That creates a draft
advisory only maintainers can read. A repository without the Security tab
enabled takes the report through the same tab on
[cyberia-to/.github](https://github.com/cyberia-to/.github/security/advisories/new).

Say what you found, where (repository, path, revision), how to reproduce it and
what it lets an attacker do. A proof of concept helps; a working exploit against
live infrastructure does not need to be run to be believed.

## what counts

Anything that lets a party do what the specification says they cannot: forge a
proof, spend or move tokens without the neuron's key, read data the protocol
marks private, take over a node or a build, or make a release artifact differ
from its sources. Cryptographic components (hemera, zheng, lens, mudra, tru,
foculus) are in scope with the highest priority.

## response

Acknowledgement within seven days. Fixes ship through the normal release train;
a fix that cannot wait for friday ships as a `fix:` commit on the release branch
with its own candidate. Credit goes to the reporter in the advisory unless they
ask otherwise.

## keys and secrets

Signing keys, deploy keys and tokens live in GitHub secrets or on the servers
that need them, never in a repository. A secret that appears in git history is
rotated, then the history is left as it is.
