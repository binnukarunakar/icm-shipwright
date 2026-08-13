# AGENTS.md — the any-agent story

This file is a pointer: read [SKILL.md](SKILL.md). One entry is generated or
trivial and the other is canonical — never two hand-maintained copies
(icm-architect's rule, kept).

Portability notes for non-Claude agents and CI:

- Workspaces may use `AGENTS.md` as their entry file instead of `CLAUDE.md`;
  `icm-lint` (check C1) accepts either.
- `## Identities loaded` lists are plain "read these first" paths. Claude
  Code users may convert them to `@`-imports — an optimization, never a
  dependency.
- `icm-scope` output is the **only harness-coupled artifact** in this repo
  (Claude Code `permissions.deny`). Other harnesses: feed the same deny list
  into your own permission config.
- Everything else is plain files plus two scripts whose interface is exit
  codes — `icm-lint` (Python 3.8+, stdlib) and `icm-export.sh` (bash 3.2+)
  run identically under any agent, any CI, or no agent at all.
