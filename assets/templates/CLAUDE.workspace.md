# {{WORKSPACE_NAME}} — {{ONE_LINE_PURPOSE}}

## Voice
<!-- One voice, five lines. When a second CONFLICTING voice appears (a brand
     register vs a legal register), replace this section with the Identities
     blocks below — not before. -->
- Register: {{terse / warm / formal}}
- Always: {{e.g. evidence before adjectives}}
- Never: {{e.g. personal contact details in output}}

<!-- Uncomment when identity files exist (see references/trust-plane.md):
## Identities loaded
- identities/{{name}}.md   (read these first — plain paths; @-imports are a
                            Claude Code optimization, not a dependency)

## Identities REFUSED
- identities/{{other}}.md
Refusal script: "That request reads {{other}}, which this workspace does not
load. Open the right workspace or confirm the switch."
-->

## Routing
| Task domain | Go to |
|---|---|
| {{recurring job 1}} | `{{folder}}/CONTEXT.md` |
| {{recurring job 2}} | `{{folder}}/CONTEXT.md` |
| status (this run) | scan `stages/*/output/` — the filesystem is the state machine |
| status (project) | `LOG.md` `## Now` |

## Authority ordering
LOG.md `## Now` = current state; git log = what shipped; CONTEXT.md = how the
system works. On conflict, the loser gets fixed this session. If the files
disagree with the user, the files are stale — fix them, don't argue.

## Resume
Read this file, then LOG.md `## Now` + the top entry. Close every session by
updating `## Now` and appending an entry that ends with a named next step.

## Facts a fresh session must not re-derive
<!-- Add bullets only after a real incident, 3-6 max. Never speculatively. -->

Security: read SECURITY.md (always); allowlist.md before any fetch.
