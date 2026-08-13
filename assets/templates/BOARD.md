# BOARD — {{PREFIX}}

## Working agreement
<!-- Roles are FUNCTIONS. Bind people or models to them here, in this block —
     never inside the role definitions, so the seats outlive the occupants. -->
- **Lead** — writes ticket specs, QAs every deliverable adversarially
  (tests run + code read + standards check), re-runs gates independently,
  writes no feature code. Held by: {{person/model}}
- **Implementer** — implements the ticket spec exactly; deviations are
  declared on the ticket and adjudicated, never silently improvised.
  Held by: {{person/model}}

Statuses: Backlog → In Progress → In Review → Done | Reopened
Rules: no ticket without a spec; no code outside a ticket; every ticket
carries acceptance criteria including the AC command set:
`{{npm run typecheck && npm run lint && npm test && npm run build}}`

## Standing rulings
<!-- A ruling is defined here and only referenced elsewhere. -->
| ID | Ruling | Ruled at |
|---|---|---|
| R-1 | {{e.g. integration-test files may run to 400 lines when fixtures dominate}} | {{PREFIX}}-11 QA |

## Sprint {{N}} — {{goal in five words}}
| ID | Title | Assignee | Status | Depends |
|---|---|---|---|---|
| {{PREFIX}}-1 | {{title}} | {{implementer}} | Backlog | — |

### {{PREFIX}}-1 — {{title}}
Owner request (verbatim): "{{what was actually asked, unparaphrased}}"
Spec: {{what to build, exact enough to implement without guessing}}
AC:
- [ ] {{observable behavior}}
- [ ] AC command set green
Deviations: {{none yet — declared here, never silent}}

## QA log
<!-- Verdicts: PASS / REOPENED / INCIDENT. An incident gets a permanent row
     here plus an anti-drift guard bullet in the workspace entry file. -->
| Date | Ticket | Verdict | Notes |
|---|---|---|---|

---
Authority: BOARD = what is built; git log = what shipped; LOG.md = where we
are. Commit grammar: `type(scope): {{PREFIX}}-n — description [QA: pass]`
(`[QA: pass, screenshots reviewed]` for UI work).
