---
name: icm-shipwright
description: Take an ICM (Interpretable Context Methodology) workspace from empty folder to shipped, team-run production. Adds the trust plane (scoped identities, security policy + dated expiring egress allowlist, GATE files, _private tiers, citation-required claims) and the ops plane (the machine-checkable slice of the walk test as a lint, one-file session state, whitelist export with fail-closed guardrails, board + QA conventions, CI, a maturity ladder) on top of icm-architect's control plane. Use when the user wants to (1) take a workspace or project "to production" / "make this safe to run", (2) ship or publish part of a private workspace to a public repo, (3) add security, identities, gates, or an allowlist to an agent workspace, (4) lint/audit an ICM workspace, (5) set up a personal, startup, or company (business/engineering/marketing) workspace, or says "shipwright this", "ICM to prod", "harden my workspace".
---

# ICM Shipwright

**icm-architect designs the workspace; icm-shipwright makes it safe to run
and ships it.** The control plane — five layers, ten invariants, five forms,
stage contracts, the walk test — is ICM canon (Van Clief & McDermott,
arXiv:2603.16021) implemented by RinDig's icm-architect, inherited here by
reference and never restated. Shipwright adds the two planes every real
deployment grows by hand, with one law: **a rule may exist as prose only if a
machine check backs it** — and every judgment a machine can't make must
produce an artifact a check can see.

## The three planes

| Plane | Question it answers | Files | Enforcement |
|---|---|---|---|
| Control | What runs, in what order, checked by whom? | entry file, CONTEXT.md contracts | icm-architect + lint C1–C8 |
| Trust | Who may read what, fetch what, claim what, build what? | identities/, SECURITY.md, allowlist.md, GATE.md, _private/ | lint T1–T8 + icm-scope deny rules |
| Ops | How does state stay true, and how does work leave the machine? | LOG.md, BOARD.md, publish.manifest, tools/, CI | lint O1 + export guardrails + CI |

## Route by what hurts

| The pain | Go to |
|---|---|
| I re-explain context every session | ladder rung 1 (ops-plane.md) |
| sessions keep losing or corrupting state | LOG.md contract (ops-plane.md) |
| the files lied once — dead link, stale status | icm-lint, rung 3 |
| a secret or PII nearly shipped | publish path, rung 5 |
| two voices are bleeding into each other | identities (trust-plane.md) |
| the agent fetches the web | SECURITY.md + allowlist.md |
| work must not exist until someone says so | GATE.md (trust-plane.md) |
| a second person just joined | rung 6: BOARD, CI, CODEOWNERS |

## Four modes

**INIT** — ask which profile (personal / startup / company), read
`profiles/<name>/README.md`, copy exactly the templates its copy-list names
(always including `gitignore` → `.gitignore` — lint T1 fails without it),
fill the blanks inline (workspace name, one-line purpose, routing rows,
ticket prefix), copy all four script files (`icm-lint`, `icm-export.sh`,
`icm-scope`, `scrub-patterns.txt`) into `tools/`, `git init` + first commit
(provenance needs it), run the lint, write the first LOG entry. Promise: ten
minutes to a green lint. The agent is the skeleton generator — never scaffold
folders the profile doesn't name.

**AUDIT** — run `tools/icm-lint .` (or `assets/scripts/icm-lint` from this
skill). Walk the findings with `references/checks.md`: each ID names what it
catches, the template that satisfies it, and the fix. Fix structure, not
prose. If findings keep landing in the same file, the control plane itself is
wrong — defer to icm-architect's restructure mode.

**PUBLISH** — write or repair `publish.manifest` from the template;
hand-write `README.public.md`; one-time: `git init` (or clone the empty
public repo) at the export target so its persistent `.git` becomes the public
history; run `tools/icm-export.sh .`; review the printed tree and every
listed `.md`; then commit and push *from inside the export directory* with
the suggested `Exported-From:` trailer. The last gate is human, on purpose.

**UPGRADE** — find the current rung on the ladder (ops-plane.md), run its
promotion test, and do exactly the next rung's work. Never two rungs at once.

## The ladder in one line each

0 fits-in-a-prompt: build nothing · 1 folder: entry file + LOG · 2 contracts:
form via icm-architect · 3 lint: the checkable slice of the walk test ·
4 trust: only the mechanism whose risk exists · 5 publish: manifest + export,
the only path out · 6 team: BOARD, CI, CODEOWNERS. Pain-triggered; promotion
tests are checks; descent is legal and recorded as a D-nnn line.

## Guardrails

- Never climb the ladder speculatively; a workspace for a thing done twice is
  scaffolding, not architecture (icm-architect's rule — it holds here).
- Scripts are *copied into the workspace's* `tools/` at init: a workspace
  must lint and publish with the skill uninstalled. The skill is the
  shipwright, not a runtime dependency.
- What stays manual, stays manual: human checks, claim semantics, QA
  judgment, gate-lift consent. Verify their artifacts; never simulate them.
- A recorded decision (gate lift, clearance, waiver, ruling) is closed —
  never re-ask; a `.icmlint` waiver line is the honest way to disagree with
  the lint.

## References

- [references/control-plane.md](references/control-plane.md) — the three
  deltas over canon: authority ordering, anti-drift guards, machine-readable
  status lines. Read when writing an entry file.
- [references/trust-plane.md](references/trust-plane.md) — the five trust
  mechanisms and their honesty note. Read at rung 4.
- [references/ops-plane.md](references/ops-plane.md) — LOG contract, ladder,
  BOARD/QA, publish path, CI. Read at rungs 3, 5, 6.
- [references/checks.md](references/checks.md) — every check ID → cause →
  fix. Read in audit mode.
- [profiles/](profiles/personal/README.md) — personal · startup · company
  (business-ops, engineering, marketing). Read in init mode.
