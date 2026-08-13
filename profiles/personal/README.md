# Profile: personal workstation

**Risk model.** One human, many hats. The threats are cross-context bleed
(the resume leaking into a public site, private notes into a shipped repo),
session amnesia, and self-leak — no adversaries, no second principal. So:
minimum ceremony, maximum continuity.

**Target tree** — shown as a research workspace, the shape ICM's academic
deployments use; a script-to-animation studio is the same skeleton with
different stage names:

```
my-research/
├─ CLAUDE.md          entry: Voice section (no identity files yet), routing,
│                     authority ordering, resume 2-liner
├─ LOG.md             ## Now + dated entries; D-nnn decisions inline
├─ SECURITY.md        the 30-line always-loaded policy
├─ allowlist.md       every source domain: dated, scoped row (this IS the
│                     research audit trail; verify-by: dates on claims)
├─ 01_search/ 02_read/ 03_synthesize/   the form — design it with icm-architect
├─ _shared/           factory: method notes, citation policy
├─ _private/          gitignored; tiers named in one README line
├─ .gitignore         from the gitignore template — BEFORE the first lint
└─ tools/             all four script files, copied in
```

**Setup (the 30-minute path)** — copy-list: template → destination

1. Copy 6 templates: `CLAUDE.workspace.md` → `CLAUDE.md` · `LOG.md` →
   `LOG.md` · `SECURITY.md` → `SECURITY.md` · `allowlist.md` →
   `allowlist.md` (replace the two example rows) · `gitignore` →
   `.gitignore` · `stage-CONTEXT.md` → each stage's `CONTEXT.md`.
2. Fill 4 blanks: name, one-line purpose, routing rows, first `Next:`.
3. Copy the four script files (`icm-lint`, `icm-export.sh`, `icm-scope`,
   `scrub-patterns.txt`) into `tools/`; `git init` + first commit.
4. `tools/icm-lint .` → green. Optional: the pre-commit one-liner
   (ops-plane.md).

**Deliberate omissions** — each returns only when its pain arrives:

- Identity files — until a *second conflicting* voice exists; a Voice section
  carries one voice fine (trust-plane.md §1).
- BOARD.md — LOG `Next:` lines carry the discipline for one person.
- CI — the pre-commit one-liner suffices until something is public.
- GATE.md — until a genuinely risky project (legal, spend, irreversible).
- publish.manifest — rung 5, the day something first leaves the machine
  (write `README.public.md` the same day; the manifest's `readme` line
  requires it).
- *Running* icm-scope — until refused identities or real private material
  exist; then it is exactly what stops a confused session reading the
  resume. (The script sits in `tools/` from day one; running it is the
  rung-4 act.)

The lint's self-skipping checks mean this tree lints clean with almost no
trust files — you are never punished for rungs you haven't climbed.

**Ladder position:** rungs 1–3 on day one; 4–5 pulled in by events, never by
ambition.
