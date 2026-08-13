# LOG — {{WORKSPACE_NAME}}

## Now
Status: {{one line — what state the work is in}}
Next: {{the single named next step}}
External: {{one shareable paragraph — safe to paste into an update as-is}}
<!-- ## Now is the only block a resuming session must read. If the user
     disagrees with it, it is stale — fix it, don't argue. Keep under 15 lines. -->

## 2026-01-15 — {{session title}}
{{What happened, in past tense, with paths.}}
D-001: {{decision}} — {{why}} — {{consequence}}
Next: {{named step}}

<!-- Newest entry first. Every entry ends with Next:. Decisions are inline
     D-nnn lines; the index is `grep -h "D-[0-9]" LOG.md logs/*.md`, never a
     hand-built list. Past 400 lines, move old entries to logs/YYYY-MM.md. -->
