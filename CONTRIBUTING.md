# Contributing

Three laws govern this repo — PRs are reviewed against them before anything
else:

1. **A rule may exist as prose only if a machine check backs it.** A new
   convention arrives with its lint check (or the artifact a check can see),
   or it doesn't arrive.
2. **One home per grammar.** Any change to a machine-readable line (GATE
   `status:`, allowlist row, `Read by:`, `verify-by:`, manifest directives,
   LOG `## Now`) edits three places in one commit: the check in
   `assets/scripts/icm-lint`, the template in `assets/templates/`, and the
   row in `references/checks.md`. Drift between them is the bug this whole
   repo exists to kill.
3. **The line budget is load-bearing.** The method stays under ~2,500 lines
   including scripts and profiles. New content earns its place by cutting or
   compressing something else; `git log` remembers what we deleted.

Practical notes:

- Run `bash tests/run.sh` before pushing — it must stay green on GNU and BSD
  tools (CI runs both). New guardrails and new lint checks come **with a
  seeded-violation test**; a check nothing can trip is decoration.
- Portability floors: bash 3.2 (macOS `/bin/bash` — no `mapfile`, no
  associative arrays), Python 3.8 stdlib only, BSD grep/find (no `-P`).
- Control-plane content (forms, invariants, contract formats) belongs
  upstream in [icm-architect](https://github.com/RinDig/icm-architect) or the
  [ICM paper](https://arxiv.org/abs/2603.16021) — PRs restating it here will
  be redirected, not merged.
- Security issues: see [.github/SECURITY.md](.github/SECURITY.md) — not the
  issue tracker.
