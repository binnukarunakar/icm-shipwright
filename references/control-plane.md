# Control plane — what shipwright adds to the canon

The canon is not restated here. ICM's five layers (L0 entry file → L1 root
routing → L2 stage contracts → L3 factory references → L4 per-run product),
its ten invariants, and the five forms (Pipeline, Umbrella, Record library,
Knowledge bundle, Context map) are defined by the paper (Van Clief &
McDermott, arXiv:2603.16021) and implemented by RinDig's **icm-architect**
skill. For form selection, contract writing, and restructuring, use
icm-architect — this file carries only the three deltas shipwright adds on
top, learned from a multi-year production deployment.

## Delta 1 — Authority ordering

Structure answers "where do I go"; it does not answer "which file wins when
two disagree." Every workspace entry file therefore carries one declaration:

> LOG.md `## Now` = current state; git log = what shipped; CONTEXT.md = how
> the system works; BOARD.md (when present) = what is built. On conflict, the
> loser gets fixed this session.

And its corollary: **if the files disagree with the user, the files are
stale — fix them, don't argue.** Without this line, a confused session picks
its own authority; the observed failure mode is a fresh session "correcting"
a status file backwards and unwinding weeks of recorded state.

`## Now` never duplicates what the filesystem can derive — invariant 9
stands: *this run's* status stays a scan of `stages/*/output/`, and the
entry file routes "status (this run)" there. `## Now` records only what no
scan can produce: the named next step, decisions, and the shareable
project-level summary.

## Delta 2 — Anti-drift guards

After any incident where a session mis-derived state, the entry file gains a
short section:

```
## Facts a fresh session must not re-derive
- The architecture phase is CLOSED; 13 feature commits exist. Do not
  "re-finalize" it — the board is the authority on what is built.
```

Three to six bullets, added only after a *real* failure, never speculatively.
A guard written in advance is a guess; a guard written after an incident is
a scar, and scars are load-bearing.

## Delta 3 — Machine-readable status lines

The joint between planes, and the reason validation-as-code is possible at
all: every governed fact gets **exactly one greppable line inside the human
file that owns it** — never a separate config to keep in sync.

| Fact | Line | Lives in | Lint |
|---|---|---|---|
| gate state | `status: locked` / `status: lifted YYYY-MM-DD "quote"` | GATE.md | T5 |
| current state | `## Now` block | LOG.md | C7 |
| egress clearance | `\| domain \| date \| approver \| scope \|` row | allowlist.md | T3 |
| identity scope | `**Read by:** <paths>` | identities/*.md | T4 |
| claim freshness | `verify-by: YYYY-MM-DD` | any .md | T6 |
| what ships | `dir` / `file` / `readme` lines | publish.manifest | O1 |

Prose is for humans; the one greppable line is for the checks. When you add
a governed fact, design its line before you write its paragraph.

## Resume protocol

Two reads: the entry file, then LOG.md `## Now` plus the top entry. Close
every session by updating `## Now` and appending an entry that ends with a
named next step. A workspace where resuming takes more than two reads has a
routing file absorbing payload — fix the structure, not the summary.
