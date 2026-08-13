# Profile: startup (the flagship)

**Risk model.** One to five people shipping under deadline. The threats:
shipping a secret; shipping the *process* (board, strategy, research leaking
into the customer-visible repo); agent state-corruption across daily
sessions; unverifiable claims to investors and customers; bus-factor of one.

**Target tree**

```
acme/
├─ CLAUDE.md            roles by function + authority ordering (BOARD = what
│                       is built; git log = what shipped; LOG = where we are)
├─ LOG.md               ## Now — its External: paragraph IS the investor update
├─ BOARD.md             working agreement, R-n rulings, tickets, QA log
├─ SECURITY.md          + allowlist.md — startups fetch a lot; every domain
│                       gets a dated, scoped, expiring row
├─ product/             the app (own entry file pointing up, not duplicating)
├─ _shared/standards.md coding rules; overrides cite the ruling ticket
├─ _private/            contracts, cap-table notes, credential NAMES only
├─ publish.manifest     written BEFORE the first feature
├─ README.public.md     the only README that ever ships
├─ .gitignore           from the gitignore template — first lint fails T1 without it
├─ tools/               icm-lint, icm-export.sh, icm-scope, scrub-patterns.txt
└─ .github/workflows/icm.yml   lint --strict · AC · export --check
```

**Copy-list** — template → destination:
`CLAUDE.workspace.md` → `CLAUDE.md` · `LOG.md` → `LOG.md` · `BOARD.md` →
`BOARD.md` · `SECURITY.md` → `SECURITY.md` · `allowlist.md` → `allowlist.md`
· `gitignore` → `.gitignore` · `publish.manifest` → `publish.manifest` ·
`ci.icm.yml` → `.github/workflows/icm.yml` · `stage-CONTEXT.md` → each
stage's `CONTEXT.md`. Hand-write (no template, yours by design):
`README.public.md`, `_shared/standards.md`, `product/`'s own entry file.
Then `git init` + first commit, and once: `git init` (or clone the empty
public repo) at the manifest's `target`.

**Key stances**

- **Born publishing.** The manifest exists before the first feature, so
  publishing is never a migration — it is a Tuesday. The factory repo never
  gets a public remote; the export dir's persistent `.git` *is* the public
  history. The manifest whitelists *entry-file-free subtrees* (`dir
  product/src`, `file product/package.json`) — never `dir product` itself:
  `product/CLAUDE.md` is factory, and guardrails A+C will rightly block it.
- **Roles by function**, so a human can hold either seat on any given day:
  the lead specs and QAs adversarially and writes no feature code; the
  implementer follows the ticket exactly, deviations declared on the ticket.
- **Greppable ship chain.** Ticket ID → QA verdict row → `[QA: pass]` commit
  trailer → `Exported-From:` sha in the public repo. Any public bug traces to
  the exact factory commit and the QA that passed it.
- The LOG's `External:` line is written honestly *every session*, so the
  investor update is never composed from memory under pressure.
- GATE.md only where the owner wants forward authorization — e.g. "no billing
  code until the Stripe account is real."
- Claim classes seeded with the two things startups get burned on:
  competitor comparisons and revenue/traction claims — document + date +
  `verify-by:`, or it doesn't ship (trust-plane.md §5).

**Ladder position:** rungs 1–5 in week one. Rung 6 the day contributor #2
arrives: CI required, CODEOWNERS on SECURITY.md / allowlist.md / GATE.md /
publish.manifest.
