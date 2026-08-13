# Egress allowlist — append-only

| Domain | Date | Approver | Scope |
|---|---|---|---|
| api.example.com | 2026-08-12 | {{owner}} | read-only; docs pages only. expires:2027-02-08 |
| sketchy.example | 2026-08-12 | {{owner}} | REFUSED — unverified domain |

Everything else: BLOCKED until a row exists.
Rows are append-only — replace the two example rows, then only add. A recorded
clearance is never re-asked; an expired one is re-cleared or revoked with a
new row.
