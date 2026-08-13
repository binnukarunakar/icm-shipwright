# Department: business operations

**Form.** Record library (vendors, contracts, filings, hires — every record
stamped from `_templates/`) plus a small context map of handoffs between
functions. Nothing "runs to completion"; records accumulate and get looked
up.

**Distinctives**

- **compliance-flags.md** is the center of gravity: a status table (EIN,
  state registrations, insurance, DPA, 501(c)(3), …) where any TBD row
  **blocks dependent artifact generation** — no tax-deductibility language
  while 501(c)(3) is TBD, no "fully insured" line while the certificate
  row is empty. Every row carries a dated last-verified column with a
  `verify-by:` date, so a TBD cannot sit stale past lint T6.
- Approvals are recorded per record, with named principals — a record
  without its approval line is not Done.
- `_private/` holds PII under **derive-then-consume**: runbooks and agents
  read rules compiled into `_config/`, never the raw records (trust-plane.md
  §4).
- Citation-required claims for anything regulatory: document + date +
  `verify-by:` (trust-plane.md §5).
- **No code, no publish path.** This department has no publish.manifest by
  design — nothing ships publicly from ops — and lint O1 self-skips.

**Target tree**

```
departments/business-ops/
├─ CLAUDE.md            entry + routing to records
├─ LOG.md
├─ compliance-flags.md  the blocking table
├─ _templates/          record stamps: vendor/, filing/, hire/
├─ records/<slug>/      stamped, uniform, approval line each
└─ _private/            raw PII — derive-then-consume only
```

**Copy:** CLAUDE.workspace.md, LOG.md, identity.md (the ops role),
stage-CONTEXT.md (as the record-stamp contract). **Ladder:** rungs 2–4;
rung 5 never.
