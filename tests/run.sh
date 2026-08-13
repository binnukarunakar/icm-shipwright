#!/usr/bin/env bash
# tests/run.sh — fixture tests for icm-shipwright's scripts.
#
# Builds a workspace from the shipped templates, proves it lints clean, then
# seeds one violation per lint check and one attack per export guardrail and
# proves each one trips. The guardrails are only trustworthy because this
# file exists. Run: bash tests/run.sh   (bash 3.2+, python3, rsync, git)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$ROOT/assets/templates"; S="$ROOT/assets/scripts"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/icm-shipwright-test.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
WS="$WORK/ws"; EXP="$WORK/export"
PASS=0; FAIL=0
ok() { PASS=$((PASS+1)); echo "ok   $1"; }
no() { FAIL=$((FAIL+1)); echo "FAIL $1"; printf '%s\n' "${2:-}" | head -4; }
lint() { python3 "$WS/tools/icm-lint" "$WS" 2>/dev/null; }
exp() { (cd "$WS" && bash tools/icm-export.sh . "$@" 2>&1); }
grepq() { out="$1"; shift; case "$out" in *"$1"*) return 0;; *) return 1;; esac; }
want() { out="$($1)"; if grepq "$out" "$2"; then ok "$3"; else no "$3" "$out"; fi; }

# ── fixture: a workspace built from the shipped templates ────────────────────
mkdir -p "$WS"/{stages/01_research/output,stages/02_script/output,_shared,tools,identities,src,docs/public,_private}
cp "$S/icm-lint" "$S/icm-export.sh" "$S/icm-scope" "$S/scrub-patterns.txt" "$WS/tools/"
cp "$T/SECURITY.md" "$WS/SECURITY.md"
cp "$T/gitignore" "$WS/.gitignore"
cat > "$WS/CLAUDE.md" <<'EOF'
# demo-studio — script-to-animation pipeline for weekly explainers

## Identities loaded
- identities/creator.md

## Identities REFUSED
- identities/legal.md
Refusal script: "That request reads legal, which this workspace does not load."

## Routing
| Task domain | Go to |
|---|---|
| new episode | `stages/01_research/CONTEXT.md` |
| status | `LOG.md` `## Now` |

## Resume
Read this file, then LOG.md `## Now` + the top entry.

Security: read SECURITY.md (always); allowlist.md before any fetch.
EOF
printf '# Identity: creator\n\n**Read by:** ws, demo-studio\n\n## Hard rules\n- none\n\n## What this identity does NOT do\n- legal copy\n' > "$WS/identities/creator.md"
printf '# Identity: legal\n\n**Read by:** legal-ws\n\n## What this identity does NOT do\n- marketing copy\n' > "$WS/identities/legal.md"
cat > "$WS/LOG.md" <<'EOF'
# LOG — demo-studio

## Now
Status: Sprint 1 open
Next: draft episode 2 script
External: Episode 1 shipped; episode 2 research done.

## 2026-08-10 — episode 2 research
Wrote stages/01_research/output/research.md.
D-001: 90-second cap — retention — scripts stay under 240 words
Next: draft episode 2 script
EOF
cat > "$WS/allowlist.md" <<'EOF'
# Egress allowlist — append-only

| Domain | Date | Approver | Scope |
|---|---|---|---|
| api.example.com | 2026-08-12 | owner | read-only. expires:2099-01-01 |
| sketchy.example | 2026-08-12 | owner | REFUSED — unverified |

Everything else: BLOCKED until a row exists.
EOF
mkcontract() { cat > "$1" <<EOF
# $2 — $3

One job: $3.

## Inputs
- Working (this run): $4
- Reference (every run): ../../_shared/voice.md

## Process
1. Do the job.

## Outputs
- out.md → output/

## Human check
Read it.
EOF
}
mkcontract "$WS/stages/01_research/CONTEXT.md" 01_research "gather evidence" "brief.md (optional)"
mkcontract "$WS/stages/02_script/CONTEXT.md" 02_script "write the script" "../01_research/output/research.md"
echo "voice: warm, concrete" > "$WS/_shared/voice.md"
echo "console.log('hi')" > "$WS/src/index.js"
echo '{"name":"demo"}' > "$WS/package.json"
echo "# Demo Studio" > "$WS/README.public.md"
echo "usage notes" > "$WS/docs/public/notes.md"
printf 'target %s\ndir src\ndir docs/public\nfile package.json\noptional CHANGELOG.md\nnever RESEARCH.md\nreadme README.public.md\n' "$EXP" > "$WS/publish.manifest"
(cd "$WS" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -qm fixture) >/dev/null 2>&1

# ── lint: clean fixture, then one seeded violation per check ─────────────────
out=$(lint); grepq "$out" "0 errors, 0 warnings" && ok "lint: template fixture is clean" || no "lint clean" "$out"
mkdir -p "$WS/stages/03_edit";                          want lint "ERROR C2" "C2 stage without contract"; rmdir "$WS/stages/03_edit"
cp "$WS/stages/02_script/CONTEXT.md" "$WORK/c.bak"
sed -i.x '/## Human check/,$d' "$WS/stages/02_script/CONTEXT.md";  want lint "ERROR C3" "C3 missing section"
sed -e 's|voice.md|missing.md|' "$WORK/c.bak" > "$WS/stages/02_script/CONTEXT.md"; want lint "ERROR C4" "C4 unresolvable input"
cp "$WORK/c.bak" "$WS/stages/02_script/CONTEXT.md"; rm -f "$WS/stages/02_script/CONTEXT.md.x"
mkdir -p "$WS/stages/02_dupe" && cp "$WORK/c.bak" "$WS/stages/02_dupe/CONTEXT.md"; want lint "ERROR C5" "C5 duplicate number"; rm -rf "$WS/stages/02_dupe"
mv "$WS/stages/02_script" "$WS/stages/04_script";       want lint "WARN C5" "C5 numbering gap"; mv "$WS/stages/04_script" "$WS/stages/02_script"
mkdir -p "$WS/stages/001_odd";                          want lint "WARN C5" "C5 off-convention stage name"; rmdir "$WS/stages/001_odd"
echo '[dead](nope.md)' >> "$WS/CLAUDE.md";              want lint "ERROR C6" "C6 broken routing link"; sed -i.x '$d' "$WS/CLAUDE.md"
mkdir -p "$WS/docs/sub" && echo hi > "$WS/docs/sub/my guide.md"
echo '[g](docs/sub/my%20guide.md)' >> "$WS/CLAUDE.md"
out=$(lint); grepq "$out" "ERROR C6" && no "C6 percent-encoded link resolves" "$out" || ok "C6 percent-encoded link resolves"
sed -i.x '$d' "$WS/CLAUDE.md"; rm -rf "$WS/docs/sub"
python3 -c "open('$WS/CLAUDE.md','a').write('- pad\n'*70)"; want lint "ERROR C1" "C1 oversized entry"; sed -i.x '/^- pad$/d' "$WS/CLAUDE.md"
mkdir -p "$WS/sub-ws" && printf '# sub\n' > "$WS/sub-ws/CLAUDE.md"; want lint "nested workspace" "C1 nested workspace surfaced"; rm -rf "$WS/sub-ws"
sed -i.x 's/^Next: draft episode 2 script$//' "$WS/LOG.md"; want lint "ERROR C7" "C7 entry without Next:"; mv "$WS/LOG.md.x" "$WS/LOG.md"
printf '\n## Now\nStatus: stale duplicate\n' >> "$WS/LOG.md"; want lint "ERROR C7" "C7 duplicate ## Now"; sed -i.x '/^Status: stale duplicate$/d; /^## Now$/{x;/./d;x;}' "$WS/LOG.md"
python3 - "$WS/LOG.md" <<'EOF'
import sys
p=sys.argv[1]; t=open(p).read()
i=t.rfind("\n## Now\nStatus: stale duplicate\n")
if i==-1: i=t.rfind("\n## Now\n")
open(p,'w').write(t[:i] if i>len(t)//2 else t)
EOF
out=$(lint); grepq "$out" "0 errors" && ok "C7 duplicate cleanup verified" || no "C7 cleanup" "$out"
# C8: a bloated reference input pushes the stage context past 8k tokens
python3 -c "open('$WS/_shared/big.md','w').write('x '*20000)"
printf -- '- Reference (every run): ../../_shared/big.md\n' >> "$WS/stages/01_research/CONTEXT.md.c8" 2>/dev/null || true
cp "$WS/stages/01_research/CONTEXT.md" "$WORK/c8.bak"
sed -i.x 's|- Reference (every run): ../../_shared/voice.md|- Reference (every run): ../../_shared/big.md|' "$WS/stages/01_research/CONTEXT.md"
want lint "WARN C8" "C8 stage context over 8k tokens"
cp "$WORK/c8.bak" "$WS/stages/01_research/CONTEXT.md"; rm -f "$WS/_shared/big.md" "$WS/stages/01_research/CONTEXT.md.x" "$WS/stages/01_research/CONTEXT.md.c8"
mv "$WS/.gitignore" "$WORK/gi.bak";                     want lint "ERROR T1" "T1 _private not gitignored"; mv "$WORK/gi.bak" "$WS/.gitignore"
echo 'k = "sk-abcdefghijklmnopqrstuvwx"' > "$WS/src/c.md"; want lint "ERROR T2" "T2 secret shape"
echo 'skip T2' > "$WS/.icmlint";                        want lint "waived" "waiver is recorded"; rm "$WS/.icmlint"
echo 'k = "sk-abcdefghijklmnopqrstuvwx"' > "$WS/src/c2.md"
printf 'skip T2 src/c.md\n' > "$WS/.icmlint"
out=$(lint); grepq "$out" "src/c2.md" && grepq "$out" "waived" && ok "per-path waiver waives only its path" || no "per-path waiver" "$out"
rm "$WS/src/c.md" "$WS/src/c2.md" "$WS/.icmlint"
printf '| b.example | nodate | o | x |\n' >> "$WS/allowlist.md"; want lint "ERROR T3" "T3 malformed row"; sed -i.x '/b.example/d' "$WS/allowlist.md"
printf '| o.example | 2026-01-01 | o | x. expires:2026-02-01 |\n' >> "$WS/allowlist.md"; want lint "WARN T3" "T3 expired clearance"; sed -i.x '/o.example/d' "$WS/allowlist.md"
printf '| p.example | 2026-08-12 | o | read \\| write |\n' >> "$WS/allowlist.md"
out=$(lint); grepq "$out" "ERROR T3" && no "T3 escaped pipe accepted" "$out" || ok "T3 escaped pipe accepted"
sed -i.x '/p.example/d' "$WS/allowlist.md"; rm -f "$WS/allowlist.md.x"
sed -i.x 's|- identities/legal.md|- identities/creator.md|' "$WS/CLAUDE.md"; want lint "ERROR T4" "T4 loaded and refused"; mv "$WS/CLAUDE.md.x" "$WS/CLAUDE.md"
sed -i.x 's|\*\*Read by:\*\* ws, demo-studio|**Read by:** elsewhere|' "$WS/identities/creator.md"; want lint "ERROR T4" "T4 scope drift"; mv "$WS/identities/creator.md.x" "$WS/identities/creator.md"
printf '<!--\n## Identities loaded\n- identities/ghost.md\n-->\n' >> "$WS/CLAUDE.md"
out=$(lint); grepq "$out" "ERROR T4" && no "T4 ignores commented blocks" "$out" || ok "T4 ignores commented blocks"
python3 - "$WS/CLAUDE.md" <<'EOF'
import sys
p=sys.argv[1]; t=open(p).read()
open(p,'w').write(t.replace("<!--\n## Identities loaded\n- identities/ghost.md\n-->\n",""))
EOF
mkdir -p "$WS/gated" && printf 'status: locked\n' > "$WS/gated/GATE.md" && echo 'x=1' > "$WS/gated/app.py"; want lint "ERROR T5" "T5 locked gate with code"
printf 'status: lifted someday\n' > "$WS/gated/GATE.md"; want lint "ERROR T5" "T5 malformed status"; rm -rf "$WS/gated"
echo 'baseline. verify-by: 2026-01-01' > "$WS/docs/claim.md"; want lint "WARN T6" "T6 stale verify-by"; rm "$WS/docs/claim.md"
python3 -c "open('$WS/SECURITY.md','a').write('- r\n'*40)"; want lint "WARN T7" "T7 bloated SECURITY"; sed -i.x '/^- r$/d' "$WS/SECURITY.md"
mkdir -p "$WS/.claude" && echo '{"permissions":{"deny":[]}}' > "$WS/.claude/settings.local.json"
want lint "WARN T8" "T8 deny rules out of date"; rm -rf "$WS/.claude"
sed -i.x 's|file package.json|file missing.json|' "$WS/publish.manifest"; want lint "ERROR O1" "O1 manifest names missing path"; mv "$WS/publish.manifest.x" "$WS/publish.manifest"
find "$WS" -name '*.x' -delete
out=$(lint); grepq "$out" "0 errors, 0 warnings" && ok "lint: fixture recleans to zero" || no "lint reclean" "$out"

# ── export: clean run, guardrails, attacks, fail-closed, --check ─────────────
out=$(exp); grepq "$out" "Exported-From:" && ok "export: clean run + provenance" || no "export clean" "$out"
head -1 "$EXP/README.md" | grep -q "Demo Studio" && ok "export: README swap" || no "README swap"
touch "$WS/src/LOG.md";           want exp "GUARDRAIL A" "A internal filename"; rm "$WS/src/LOG.md"
echo x > "$WS/src/RESEARCH.md";   want exp "GUARDRAIL A" "A never-entry (name form)"; rm "$WS/src/RESEARCH.md"
cp "$WS/publish.manifest" "$WORK/m.bak"
printf 'never docs/public/notes.md\n' >> "$WS/publish.manifest"
want exp "GUARDRAIL A" "A never-entry (path form)"
cp "$WORK/m.bak" "$WS/publish.manifest"
echo 't="ghp_ABCDEFGHIJKLMNOP1234"' > "$WS/src/k.js"; want exp "GUARDRAIL B" "B secret shape"; rm "$WS/src/k.js"
echo 'see SPRINT board' > "$WS/docs/public/h.md"; want exp "GUARDRAIL C" "C internal-doc reference"; rm "$WS/docs/public/h.md"
echo 'works with CLAUDE.md workspaces' > "$WS/docs/public/tool.md"
want exp "GUARDRAIL C" "C blocks CLAUDE.md mention without allow-ref"
printf 'allow-ref CLAUDE.md\n' >> "$WS/publish.manifest"
out=$(exp); grepq "$out" "Exported-From:" && ok "C allow-ref records the exception" || no "C allow-ref" "$out"
cp "$WORK/m.bak" "$WS/publish.manifest"; rm "$WS/docs/public/tool.md"
echo 'call (212) 867-5309' > "$WS/src/p.md"; want exp "GUARDRAIL D" "D phone shape"; rm "$WS/src/p.md"
echo 'call 212-555-0123' > "$WS/src/p.md"; out=$(exp); grepq "$out" "GUARDRAIL D" && no "D 555 exchange allowed" "$out" || ok "D 555 exchange allowed"; rm "$WS/src/p.md"
echo 'fax 555-0100 office 212-867-5309' > "$WS/src/p.md"; want exp "GUARDRAIL D" "D real number beside a 555 does not hide"; rm "$WS/src/p.md"
echo 'me@gmail.com' > "$WS/src/p.md"; want exp "GUARDRAIL D" "D consumer email"; rm "$WS/src/p.md"
ln -s ../../ "$WS/src/l"; want exp "GUARDRAIL E" "E symlink escape"; rm "$WS/src/l"
printf 'target %s\ndir *\nreadme README.public.md\n' "$EXP" > "$WS/publish.manifest"; want exp 'missing: *' "attack: glob stays literal"
printf 'target %s\ndir ../../\nreadme README.public.md\n' "$EXP" > "$WS/publish.manifest"; want exp "unsafe path" "attack: dir traversal refused"
printf 'target ..\ndir src\nreadme README.public.md\n' > "$WS/publish.manifest"; want exp "absolute path" "attack: relative target refused"
mkdir -p "$WORK/foreign" && echo precious > "$WORK/foreign/data.txt"
printf 'target %s\ndir src\nreadme README.public.md\n' "$WORK/foreign" > "$WS/publish.manifest"; want exp "refusing to wipe" "attack: foreign dir not wiped"
test -f "$WORK/foreign/data.txt" && ok "attack: foreign data intact" || no "attack: foreign data intact"
printf 'target %s\ndir src\nreadme README.public.md\n' "$WORK" > "$WS/publish.manifest"; want exp "contains the workspace" "attack: ancestor target refused"
cp "$WORK/m.bak" "$WS/publish.manifest"
cp "$WS/tools/scrub-patterns.txt" "$WORK/p.bak"
exp >/dev/null
printf 'bad\t([unclosed\n' > "$WS/tools/scrub-patterns.txt"; want "exp --check" "failed to run" "fail-closed: invalid regex"
printf '# none\n' > "$WS/tools/scrub-patterns.txt";          want "exp --check" "no usable patterns" "fail-closed: empty pattern file"
printf 'k sk-[a-z]{16,}\n' > "$WS/tools/scrub-patterns.txt"; want "exp --check" "no TAB" "fail-closed: tab-less pattern line"
cp "$WORK/p.bak" "$WS/tools/scrub-patterns.txt"
exp >/dev/null; echo 'x AKIAABCDEFGHIJKLMNOP' > "$EXP/src/oops.md"
want "exp --check" "GUARDRAIL B" "--check catches post-staging tamper"; rm "$EXP/src/oops.md"
out=$(exp --check); grepq "$out" "guardrails green" && ok "--check green on clean export" || no "--check clean" "$out"

# ── icm-scope ────────────────────────────────────────────────────────────────
out=$(python3 "$WS/tools/icm-scope" "$WS" 2>/dev/null)
grepq "$out" 'Read(./identities/legal.md)' && grepq "$out" 'Read(./_private/**)' && ok "scope: deny rules from refuse block + _private" || no "scope stdout" "$out"
printf -- '- ~/global/identities/x.md\n' >> "$WS/CLAUDE.md.tmp" 2>/dev/null || true
python3 - "$WS/CLAUDE.md" <<'EOF'
import sys
p=sys.argv[1]; t=open(p).read()
t=t.replace("- identities/legal.md","- identities/legal.md\n- ~/global/identities/x.md")
open(p,'w').write(t)
EOF
out=$(python3 "$WS/tools/icm-scope" "$WS" 2>/dev/null)
grepq "$out" 'Read(~/global/identities/x.md)' && ok "scope: ~/ rule stays home-relative" || no "scope ~/ rule" "$out"
python3 - "$WS/CLAUDE.md" <<'EOF'
import sys
p=sys.argv[1]; t=open(p).read()
open(p,'w').write(t.replace("\n- ~/global/identities/x.md",""))
EOF
rm -f "$WS/CLAUDE.md.tmp"
python3 "$WS/tools/icm-scope" "$WS" --check >/dev/null 2>&1
[ $? -eq 1 ] && ok "scope: --check flags missing rules" || no "scope --check missing"
mkdir -p "$WS/.claude" && echo '{"permissions":{"allow":["Bash(ls)"]},"model":"opus"}' > "$WS/.claude/settings.local.json"
python3 "$WS/tools/icm-scope" "$WS" --write >/dev/null
python3 - "$WS" <<'EOF' && ok "scope: --write merges, preserves keys" || echo "FAIL scope merge"
import json, sys
cfg = json.load(open(sys.argv[1] + "/.claude/settings.local.json"))
assert cfg["model"] == "opus" and "Bash(ls)" in cfg["permissions"]["allow"]
assert "Read(./_private/**)" in cfg["permissions"]["deny"]
EOF
python3 "$WS/tools/icm-scope" "$WS" --check >/dev/null 2>&1 && ok "scope: --check green after --write" || no "scope --check green"
echo '"a string"' > "$WS/.claude/settings.local.json"
python3 "$WS/tools/icm-scope" "$WS" --write >/dev/null 2>&1
[ $? -eq 2 ] && grep -q 'a string' "$WS/.claude/settings.local.json" && ok "scope: refuses to clobber malformed config" || no "scope clobber guard"

echo
echo "tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
