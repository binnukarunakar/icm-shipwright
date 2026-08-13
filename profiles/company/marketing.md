# Department: marketing

**Form.** Umbrella — one brand factory over several content pipelines
(blog, social, email, video — each a Pipeline with stage contracts and its
own human gates; design them with icm-architect).

**Distinctives**

- **claims.md is the center of gravity.** Claim classes — pricing,
  benchmarks, comparative ("faster than X"), testimonial, regulated-industry
  — each cite-or-refuse: document + date, dated as-of baselines,
  `verify-by:` dates the lint flags when stale (trust-plane.md §5).
  Benchmarks additionally cite a committed reproducible run. Marketing is
  where unverifiable claims turn into legal exposure; the ledger is the
  defense.
- **Identity refuse blocks run both ways:** the brand voice never appears in
  legal or HR documents, and the legal register never appears in ads. The
  marketing workspace refuses `_org/identities/legal.md` and `hr.md` by
  block; icm-scope makes the refusal a permission error.
- **Nothing publishes except through icm-export.sh**, with a
  marketing-specific `never` list: briefs, performance data, audience
  research — the campaign can ship while the strategy cannot.
- **The final Human check in every pipeline names the approving human**, and
  the QA-log row is the publish gate: no row, no post.
- Every outbound artifact passes the export PII guardrail — a customer quote
  with a personal email in it fails the run.

**Target tree**

```
departments/marketing/
├─ CLAUDE.md            umbrella map; refuses legal/hr identities
├─ LOG.md
├─ _shared/             brand factory: voice.md, positioning.md, claims.md
├─ 01_blog/ 02_social/ 03_video/   pipelines (own contracts, own gates)
├─ publish.manifest     never: briefs/, performance/, research/
└─ tools/
```

**Ladder:** rungs 2–5; rung 6 when a second marketer or an agency joins.
