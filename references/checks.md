# checks.md — the audit playbook

Check IDs are the shared vocabulary between lint output, this file, and
`.icmlint` waivers (`skip <ID>` or `skip <ID> <path-substring>` — recorded
exceptions a reviewer can see). Trust and ops checks self-skip when their
governing file is absent.

**C1** ERROR/WARN — entry file missing, or absorbing payload (>80 lines
error, >60 warn). Template: `CLAUDE.workspace.md` (AGENTS.md also accepted).
Fix: move content to a shelf, leave a pointer. The catalog holds no books.

**C2** ERROR — a numbered `NN_` folder has no CONTEXT.md contract.
Template: `stage-CONTEXT.md`. Fix: write the contract or renumber the folder
out of the pipeline.

**C3** ERROR — a contract is missing `## Inputs` / `## Process` /
`## Outputs` / `## Human check`. Fix: add the section; a stage without a
human check is not a stage boundary.

**C4** ERROR — an input path under `## Inputs` does not resolve. Fix: repair
the path, or mark runtime-produced inputs `(optional)`. Paths containing
`output/` are exempt (they exist only mid-run).

**C5** ERROR/WARN — duplicate stage numbers (order is ambiguous) / gaps in
the sequence. Fix: renumber; the numbering *is* the pipeline.

**C6** ERROR — a relative `.md` link in the entry file or root CONTEXT.md
does not resolve. Fix: repair or delete; a dead routing link strands a cold
agent.

**C7** ERROR/WARN — LOG.md missing (warn), no `## Now` or more than one
(error — a resuming session cannot tell which is current), no dated entries
(warn), newest entry without `Next:` (error), >400 lines (warn). Template:
`LOG.md`. Fix: sessions end by updating the one `## Now` and naming the next
step.

**C8** WARN — a stage's estimated context (entry file + contract + resolved
inputs) exceeds ~8k tokens — the top of the paper's healthy range. Fix:
split the stage, or push detail into a reference file the contract points at
but doesn't inline.

**T1** ERROR — `_private/` exists but is not gitignored. Fix: add the line
before anything commits; then check nothing was already tracked.

**T2** ERROR — a tracked text file matches a secret shape from
scrub-patterns.txt (the finding names the shape, never the match). Fix:
**rotate the secret first**, then scrub git history — deleting the file is
not enough. A pattern that fails to compile is itself an error: a broken
pattern is a silently bypassed check.

**T3** ERROR/WARN — an allowlist.md row that doesn't parse as
`| domain | YYYY-MM-DD | approver | scope |` (error); an `expires:` date in
the past (warn). Template: `allowlist.md`. Fix: re-clear or revoke with a
new row — the table is append-only.

**T4** ERROR — identity loaded *and* refused; loaded identity missing on
disk; loaded identity whose `**Read by:**` scope omits this workspace (scope
drift). Template: `identity.md`. Fix: widen the header deliberately, or stop
loading it — never both silently.

**T5** ERROR — GATE.md without a parseable `status:` line; a *locked* gate
with code files beneath it (`tools/` exempt). Template: `GATE.md`. Fix: lift
the gate properly (date + the owner's words) or delete the code.

**T6** WARN — a `verify-by: YYYY-MM-DD` claim baseline is past. Fix:
re-verify the claim against its source, update the snapshot date — don't
just bump the date.

**T7** WARN — SECURITY.md over 60 lines. Fix: move approvals to
allowlist.md, reference detail to a shelf. The always-loaded file holds
rules only.

**T8** WARN — `.claude/settings.local.json` exists but is missing a deny
rule the refuse blocks / `_private/` imply. Fix: run `tools/icm-scope
--write` (or `--check` in CI) — the harness ring only protects what it knows
about.

**O1** ERROR — publish.manifest names a `dir`/`file`/`readme` missing on
disk. Fix: restore the file or remove the line — the whitelist is a
structure contract, and a silently shrinking export is how process leaks
start.

If fixes keep landing in the same file, the structure is wrong — stop
patching and switch to icm-architect's restructure mode.
