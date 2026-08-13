# Department: software engineering

The startup profile hardened, applied per product repo. Same skeleton, five
deltas — each one moves a convention into an enforcement point:

- **QA trailers flip from convention to CI-required.** The documented grep
  over the push range (ci.icm.yml's trailing comment) becomes an enabled
  workflow step: a code commit without `[QA: pass]` fails the build.
- **Publish runs only in CI.** Humans never push the export from a laptop;
  `icm-export.sh` + `--check` run as the pipeline, and the release job pushes
  the export. Branch protection on `main` is assumed.
- **CODEOWNERS maps board roles to real reviewers** — the lead seat on
  BOARD.md and the required reviewer in git are the same person, so the
  working agreement and the merge gate cannot disagree.
- **GATE.md is standard on production deploys and data-touching
  migrations.** Each release lifts it explicitly — `status: lifted
  YYYY-MM-DD "release approved: v1.4"` — so "who authorized this deploy"
  is a grep, not a meeting.
- **Standards live in `_org/standards/`** and are loaded only by code
  workspaces. Per-repo deviations go in an Overrides block that must cite
  the standing ruling ticket (`R-n`) that earned them — an exception without
  a ruling is a lint-visible smell in review.

**Target tree**

```
departments/engineering/<product>/
├─ CLAUDE.md            loads _org/standards/; Overrides cite R-n rulings
├─ LOG.md · BOARD.md    tickets <PREFIX>-n, QA log, standing rulings
├─ src/ …               the product
├─ GATE.deploy.md       lifted per release, date + quote
├─ publish.manifest · README.public.md
├─ tools/               all four script assets
└─ .github/workflows/icm.yml   with the QA-trailer step enabled
```

**Ladder:** born at rung 6.
