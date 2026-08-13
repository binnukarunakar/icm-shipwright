# Security policy

This repo ships scripts people run as trust boundaries (`icm-export.sh`
decides what leaves a private tree; `icm-lint` decides what counts as clean;
`icm-scope` writes harness permission config). A bypass of any guardrail —
a manifest value that escapes the whitelist, a pattern that fails open, a
path that reaches outside the export — is a security bug, not a nit.

**Report privately** via GitHub's *Security → Report a vulnerability*
(private advisory) on this repository. Do not open a public issue for a
bypass. Reports get a response within a week; a confirmed bypass ships with
a regression test in `tests/run.sh` alongside the fix.

Scope: three local scripts that read a workspace and write only to the
export target or `.claude/settings.local.json`. Nothing makes network calls
or executes workspace content. Only the latest tagged release is supported.
