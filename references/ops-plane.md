# Ops plane — how state stays true, and how work leaves the machine

## The LOG.md contract

One file carries session state. Not a status file plus a decision file plus a
work log — a production deployment ran that trio for months and proved it
triplicates state until the copies disagree.

- `## Now` at the top, ≤15 lines: `Status:` (one line, project-level — *this
  run's* status stays a scan of `stages/*/output/`, per invariant 9),
  `Next:` (the single named next step), `External:` (one shareable
  paragraph, honest enough to paste into an update as-is).
- Below it, newest-first `## YYYY-MM-DD — title` entries. Every entry ends
  with `Next:`.
- Decisions are inline lines — `D-014: decision — why — consequence`. The
  index is `grep -h "D-[0-9]" LOG.md logs/*.md`, never a hand-built list.
- Past 400 lines, old entries roll to `logs/YYYY-MM.md` (lint C7 warns).
- Staleness rule: if the user disagrees with `## Now`, the file is stale —
  fix it, don't argue.
- Graduation: DECISIONS.md and BOARD.md split out at rung 6 only, when a
  second contributor makes the single file contended.

## The maturity ladder — rungs 0–6

Pain-triggered: each rung names the pain that justifies the climb. Never
climb speculatively; promotion tests are checks, not feelings. Descent is
legal and recorded as a `D-nnn` line. (Worked example in parentheses: the
paper's canonical script-to-animation pipeline.)

**0 — Not a workspace.** The job fits in one prompt → build nothing.
(One-off clip: just ask.)

**1 — Folder** *(10 min)*. Pain: re-explaining context every session.
Entry file ≤60 lines + LOG.md + `.gitignore` (template: `gitignore`) +
`git init`. Test: a cold session resumes in two reads.
(An episodes/ folder, a voice paragraph, a LOG.)

**2 — Contracts** *(30 min)*. Pain: the same stages repeat with human checks
between them. Pick a form **with icm-architect**; write stage CONTEXT.md
contracts; split factory from product. Test: the manual walk test passes.
(01_research → 02_script → 03_production, voice.md in _shared/.)

**3 — Lint** *(10 min)*. Pain: the files lied once — a dead link, a stale
status. Copy all four script files into tools/ (icm-lint, icm-export.sh,
icm-scope, scrub-patterns.txt — one copy, no drift between docs); optionally
the pre-commit one-liner below. Test: `tools/icm-lint .` exits 0.

**4 — Trust** *(when risk appears, not before)*. Pain: secrets exist / the
agent fetches / a second voice bleeds / legally irreversible work waits on
approval. Add exactly the matching mechanism from trust-plane.md — they are
independent. Test: T-checks clean, and a deliberately refused read fails at
the harness (icm-scope), not at the model's discretion.
(Research sources get allowlist rows; the sponsor's brand voice becomes an
identity the research stage refuses.)

**5 — Publish** *(when anything leaves the machine)*. Write publish.manifest
+ README.public.md; `icm-export.sh` becomes the only path out. Test: export
exits 0 and the public repo contains zero internal names, by filename or by
reference. (The rendered episodes ship; the board and research never do.)

**6 — Team** *(when contributor #2 arrives)*. Split BOARD.md out of LOG.md;
roles by function; CI on; CODEOWNERS + branch protection on governance files;
`[QA: pass]` trailers. Test: a PR touching SECURITY.md without codeowner
review cannot merge; a new teammate resumes any workspace from files alone in
one day.

## BOARD.md + QA conventions (rung 6; startups from day one)

- **Working agreement** — roles by *function*, never by model or person name:
  the lead writes ticket specs, QAs adversarially (tests run + code read +
  standards check), re-runs gates independently, and writes no feature code;
  the implementer implements the spec exactly and declares deviations on the
  ticket. Bind occupants to seats in one place, so the seats outlive them.
- Statuses `Backlog → In Progress → In Review → Done | Reopened`. No ticket
  without a spec; no code outside a ticket; every ticket carries acceptance
  criteria including the AC command set.
- **Standing rulings** — `R-n: ruling (ruled at <ticket> QA)` — defined on
  the board, referenced everywhere else. A ruling cites the ticket that
  earned it, so "why is this exception allowed" always has an answer.
- Tickets are `<PREFIX>-n`, letter suffixes for rework (`APP-33b`). QA-log
  verdicts: PASS / REOPENED / INCIDENT. Ship commits carry `[QA: pass]`
  (`[QA: pass, screenshots reviewed]` for UI).
- **Incident hardening**: an INCIDENT gets a permanent QA-log row *and* an
  anti-drift guard bullet in the entry file (control-plane.md, delta 2).
- Authority: BOARD = what is built; git log = what shipped; LOG = where we
  are.

## The publish path

The workspace is the factory; the export is the product. publish.manifest is
a whitelist whose grammar (`target/dir/file/optional/never/allow-ref/readme`)
doubles as a structure contract — a listed item missing on disk hard-fails,
and `allow-ref <name>` is the recorded, reviewable way to let shipped content
mention one internal name (a dev tool documenting CLAUDE.md). Never whitelist
a dir containing an entry file — whitelist its code subtrees. One-time setup:
`git init` (or clone the empty public repo) at the export target; its
persistent `.git` is how repeated exports build one continuous public history
while the factory repo never gets a public remote. The README swap means the internal README can never ship. Five
guardrail families (internal filenames, secret shapes, internal-doc
references in content, PII, symlink escape) all exit non-zero: **the export
does not exist until the tree is clean — fix the source, never the export.**
`--check` re-runs the guardrails on the existing export (that is the CI job,
and it closes the edit-after-export hole). The printed `Exported-From: <sha>`
trailer makes public-bug archaeology possible: any public commit traces to
the exact factory commit. The final push stays human.

## CI wiring

`ci.icm.yml` ships three jobs: lint `--strict`, your AC command set
(commented placeholder), and export + `--check` when a manifest exists.
Pre-commit, if you want it, is one line — no framework:

```
printf '#!/bin/sh\ntools/icm-lint . || exit 1\n' > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

The rung-6 QA-trailer check is a one-line grep documented in the template,
enabled only when the team adopts trailers. CODEOWNERS is a 4-line snippet in
profiles/company/README.md.

## What stays manual

The human checks in stage contracts, the semantics of claims, QA judgment,
and gate-lift consent. Validation verifies their *artifacts* exist and parse
— a `status:` line, a QA row, a dated clearance — it never simulates the
judgment itself.
