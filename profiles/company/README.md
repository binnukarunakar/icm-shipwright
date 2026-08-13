# Profile: company workstation

**Risk model.** Many principals. The two threats that define this tier:
**self-approval** (a person or agent editing the audit surface they are
audited by) and **cross-department bleed** (a marketing session reading HR
records). Plus auditability and onboarding at scale. This is the only
profile where the full tax is charged, because only here is it owed —
smaller teams should take the startup profile and climb.

**Root governance tree**

```
corp/
├─ CLAUDE.md               department routing table + decision rule for new
│                          work + authority ordering
├─ _org/
│  ├─ identities/          per-department roles, each with **Read by:** scopes
│  │                       and a "does NOT do" section
│  ├─ SECURITY.md          + allowlist.md — approver column carries ROLES,
│  │                       not names; every row has expires:
│  └─ standards/           rule packs, loaded only by declaring workspaces
├─ departments/<dept>/     each a workspace entering the ladder at rung 2–3
├─ .github/workflows/icm.yml
└─ CODEOWNERS
```

**Governance rules**

- All changes to `_org/**` land by PR only. CODEOWNERS, verbatim:

  ```
  _org/**              @governance-owner
  **/GATE.md           @governance-owner
  **/publish.manifest  @governance-owner
  **/allowlist.md      @governance-owner
  ```

- No session self-approves: the approver on an allowlist row and the lifter
  of a gate are never the requester.
- Allowlist expiry is mandatory (default 90 days) — clearances are leases,
  not grants.
- Every clearance and gate-lift also lands as a `D-nnn` line in the owning
  LOG.md, linking session and commit — the decision trail is greppable.
- `icm-scope --write` per department keeps a session working in one
  department from reading another's `_private/` at the harness level.

**Copy-list.** Departments instantiate with the startup profile's copy-list
(template → destination table there), swapping in their variant doc's
distinctives; the root additionally hand-writes `_org/` (identities,
SECURITY + allowlist, standards packs) and `CODEOWNERS` from the snippet
above.

**Onboarding contract.** A new teammate reads the root entry file, their
department's entry file, and runs `tools/icm-lint .` — the findings walk *is*
the orientation tour. Productive in one day; that is rung 6's promotion test.

**Ladder position:** departments enter at rungs 2–3; the root is born at
rung 6.

Department variants: [business-ops.md](business-ops.md) ·
[engineering.md](engineering.md) · [marketing.md](marketing.md)
