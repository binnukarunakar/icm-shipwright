#!/usr/bin/env bash
# icm-export.sh — whitelist publisher for one ICM workspace.
#
# The workspace is the factory; the export is the product. Only what
# publish.manifest lists ever ships, and the export does not exist until every
# guardrail passes. The factory repo never gets a public remote: the export
# dir keeps its own persistent .git, so repeated exports build one continuous
# public history.
#
# Usage: icm-export.sh [WORKSPACE] [--check]
#        --check  re-run the guardrails on the existing export, stage nothing
#                 (this is the CI job — it closes the edit-after-export hole)
# Deps:  bash 3.2+, rsync, grep, find, git. Exit 0 clean, 1 blocked.
set -euo pipefail
for dep in rsync grep find git; do
  command -v "$dep" >/dev/null 2>&1 || { echo "FAIL: missing dependency: $dep"; exit 1; }
done

CHECK=0
WS="."
for a in "$@"; do case "$a" in --check) CHECK=1;; *) WS="$a";; esac; done
WS="$(cd "$WS" && pwd -P)"
MANIFEST="$WS/publish.manifest"
[ -f "$MANIFEST" ] || { echo "FAIL: no publish.manifest in $WS"; exit 1; }
PATTERNS="$(cd "$(dirname "$0")" && pwd)/scrub-patterns.txt"

# ── parse the manifest (grammar: target/dir/file/optional/never/readme) ──────
# No `set -- $line`: unquoted expansion would word-split AND glob-expand
# manifest values against the cwd — a whitelist that silently widens itself.
TARGET="${TMPDIR:-/tmp}/$(basename "$WS")-export"
DIRS=(); FILES=(); OPTIONAL=(); NEVER=(); ALLOWREF=(); README=""
safe_rel() {  # refuse traversal and absolute paths in whitelist values
  case "$1" in */../*|../*|*/..|..|/*) echo "FAIL: unsafe path in manifest: $1"; exit 1;; esac
}
while IFS= read -r line; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}"
  [ -n "$line" ] || continue
  key="${line%% *}"; val="${line#* }"
  [ "$key" != "$line" ] || continue
  val="${val#"${val%%[![:space:]]*}"}"
  [ -n "$val" ] || continue
  case "$key" in
    target)   TARGET="$val";;
    dir)      safe_rel "$val"; DIRS+=("$val");;
    file)     safe_rel "$val"; FILES+=("$val");;
    optional) safe_rel "$val"; OPTIONAL+=("$val");;
    never)    safe_rel "$val"; NEVER+=("$val");;
    allow-ref) ALLOWREF+=("$val");;   # exempt ONE built-in name from guardrail C
    readme)   safe_rel "$val"; README="$val";;
  esac
done < "$MANIFEST"

# The target is fed to a wipe below — validate it hard.
case "$TARGET" in
  /*) ;; *) echo "FAIL: target must be an absolute path: $TARGET"; exit 1;;
esac
case "$TARGET" in */../*|*/..) echo "FAIL: unsafe target: $TARGET"; exit 1;; esac
[ "$TARGET" != "/" ] || { echo "FAIL: target cannot be /"; exit 1; }
TPHYS="$(cd "$TARGET" 2>/dev/null && pwd -P || echo "$TARGET")"
case "$WS/" in "$TPHYS"/*) echo "FAIL: target contains the workspace — refusing"; exit 1;; esac

if [ "$CHECK" -eq 0 ]; then
  # ── stage: wipe everything except the persistent .git ──────────────────────
  # A `.icm-export` marker proves the dir is ours to wipe. First export: the
  # dir must be empty (a fresh clone of an empty public repo counts as empty).
  [ ${#DIRS[@]} -gt 0 ] || [ ${#FILES[@]} -gt 0 ] || { echo "FAIL: manifest ships nothing"; exit 1; }
  mkdir -p "$TARGET"
  if [ ! -e "$TARGET/.icm-export" ] && \
     [ -n "$(find "$TARGET" -mindepth 1 -maxdepth 1 ! -name .git ! -name .icm-export | head -1)" ]; then
    echo "FAIL: $TARGET is non-empty and not a previous icm export — refusing to wipe it"; exit 1
  fi
  find "$TARGET" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
  : > "$TARGET/.icm-export"
  for d in ${DIRS[@]+"${DIRS[@]}"}; do
    [ -d "$WS/$d" ] || { echo "FAIL: whitelisted dir missing: $d"; exit 1; }
    mkdir -p "$TARGET/$d"
    rsync -a --exclude .DS_Store --exclude node_modules --exclude dist \
          --exclude coverage --exclude '.env' --exclude '.env.*' \
          "$WS/$d/" "$TARGET/$d/"
  done
  for f in ${FILES[@]+"${FILES[@]}"}; do
    [ -f "$WS/$f" ] || { echo "FAIL: whitelisted file missing: $f"; exit 1; }
    mkdir -p "$TARGET/$(dirname "$f")"; cp "$WS/$f" "$TARGET/$f"
  done
  for f in ${OPTIONAL[@]+"${OPTIONAL[@]}"}; do
    [ -f "$WS/$f" ] && { mkdir -p "$TARGET/$(dirname "$f")"; cp "$WS/$f" "$TARGET/$f"; } || true
  done
  # README swap: the hand-kept public README ships; the internal one cannot.
  [ -n "$README" ] || { echo "FAIL: manifest has no 'readme' line (the internal README must never ship)"; exit 1; }
  [ -f "$WS/$README" ] || { echo "FAIL: readme missing: $README"; exit 1; }
  cp "$WS/$README" "$TARGET/README.md"
  printf '%s\n' node_modules/ dist/ .env '.env.*' .DS_Store .icm-export > "$TARGET/.gitignore"
else
  [ -d "$TARGET" ] || { echo "FAIL: --check but no export at $TARGET"; exit 1; }
fi

# ── guardrails — every family fails non-zero ────────────────────────────────
FAILED=0
fail() { echo "GUARDRAIL $1 FAIL: $2"; FAILED=1; }

# A — internal names absent by FILENAME (built-ins + every 'never' entry).
#     A slashed 'never' entry is a path: -name would silently never match it.
for name in CLAUDE.md AGENTS.md CONTEXT.md LOG.md BOARD.md GATE.md SECURITY.md \
            allowlist.md publish.manifest .icmlint _private ${NEVER[@]+"${NEVER[@]}"}; do
  case "$name" in
    */*) hits=$(find "$TARGET" -path "$TARGET/$name" ! -path "$TARGET/.git/*" | head -3);;
    *)   hits=$(find "$TARGET" -name "$name" ! -path "$TARGET/.git/*" | head -3);;
  esac
  [ -z "$hits" ] || fail A "internal name staged (the whitelist drifted): $hits"
done

# B — secret shapes, one pattern per line from the shared scrub file.
#     Fails CLOSED: a pattern that will not run, a tab-less line, or an empty
#     file each block the export — never "clean by accident". grep -e is
#     mandatory: PEM patterns start with '-' and would otherwise parse as flags.
TAB="$(printf '\t')"
APPLIED=0
[ -f "$PATTERNS" ] || fail B "no scrub-patterns.txt next to this script — copy assets/scripts/scrub-patterns.txt into tools/; refusing to ship unscanned"
if [ -f "$PATTERNS" ]; then
  while IFS= read -r pline; do
    pline="${pline%$'\r'}"
    case "$pline" in ''|'#'*) continue;; esac
    case "$pline" in *"$TAB"*) ;; *) fail B "pattern line has no TAB separator: $pline"; continue;; esac
    label="${pline%%"$TAB"*}"; pat="${pline#*"$TAB"}"
    rc=0; hits=$(grep -rlE -e "$pat" "$TARGET" --exclude-dir=.git 2>/dev/null) || rc=$?
    if [ "$rc" -ge 2 ]; then
      fail B "pattern '$label' failed to run (grep exit $rc) — a broken pattern is a bypassed guardrail"
    elif [ -n "$hits" ]; then
      fail B "secret shape '$label' in: $(printf '%s\n' "$hits" | head -3)"
    fi
    APPLIED=$((APPLIED+1))
  done < "$PATTERNS"
  [ "$APPLIED" -ge 1 ] || fail B "scrub-patterns.txt contains no usable patterns — refusing to ship unscanned"
fi

# C — internal doc names referenced in CONTENT (a shipped file that merely
#     points at the board leaks the process). A product that legitimately
#     documents a name (a dev tool's README mentioning CLAUDE.md) records the
#     exception in the manifest: `allow-ref CLAUDE.md` — reviewable, fail-closed.
C_PAT=""
for n in 'CLAUDE\.md' 'AGENTS\.md' 'LOG\.md' 'BOARD\.md' 'GATE\.md' 'SPRINT' 'publish\.manifest' '_private/'; do
  plain="${n//\\/}"; skip=0
  for a in ${ALLOWREF[@]+"${ALLOWREF[@]}"}; do [ "$a" = "$plain" ] && skip=1; done
  [ "$skip" -eq 1 ] || C_PAT="${C_PAT:+$C_PAT|}$n"
done
if [ -n "$C_PAT" ]; then
  rc=0; hits=$(grep -rlE -e "$C_PAT" "$TARGET" --exclude-dir=.git 2>/dev/null) || rc=$?
  if [ "$rc" -ge 2 ]; then fail C "grep failed (exit $rc) — a broken check is a bypassed guardrail"
  elif [ -n "$hits" ]; then fail C "shipped content references internal docs: $(printf '%s\n' "$hits" | head -3)"; fi
fi

# D — PII: US phone shapes and consumer email domains. Only 555 as the
#     EXCHANGE (the reserved fictional range) is exempt — not any line that
#     happens to contain 555 somewhere.
rc=0; raw=$(grep -rInE '(\+1[-. ]?)?\(?[0-9]{3}\)?[-. ][0-9]{3}[-. ][0-9]{4}' \
       "$TARGET" --exclude-dir=.git 2>/dev/null) || rc=$?
[ "$rc" -lt 2 ] || fail D "phone grep failed (exit $rc) — a broken check is a bypassed guardrail"
hits=$(printf '%s\n' "$raw" | grep -vE '(^|[^0-9])[0-9]{3}[-. )]+555[-. ][0-9]{4}' | grep -E '[0-9]{3}[-. ][0-9]{4}' | head -3) || true
[ -z "$hits" ] || fail D "phone-number shape: $hits"
rc=0; hits=$(grep -rInE '[A-Za-z0-9._%+-]+@(gmail|yahoo|outlook|hotmail|proton|protonmail|icloud)\.' \
       "$TARGET" --exclude-dir=.git 2>/dev/null) || rc=$?
[ "$rc" -lt 2 ] || fail D "email grep failed (exit $rc) — a broken check is a bypassed guardrail"
hits=$(printf '%s\n' "$hits" | head -3)
[ -z "$hits" ] || fail D "consumer email address: $hits"

# E — no symlink may reach back into the factory. Resolve physically (pwd -P):
#     logical paths differ across symlinked tmp dirs (macOS /var → /private/var),
#     and dirname alone under-resolves directory targets by one level.
RT="$(cd "$TARGET" && pwd -P)"
while IFS= read -r l; do
  tgt="$(readlink "$l")"
  case "$tgt" in /*) abs="$tgt";; *) abs="$(dirname "$l")/$tgt";; esac
  if rp="$(cd "$abs" 2>/dev/null && pwd -P)"; then :
  elif rp="$(cd "$(dirname "$abs")" 2>/dev/null && pwd -P)"; then rp="$rp/$(basename "$abs")"
  else rp="OUTSIDE"
  fi
  case "$rp/" in "$RT"/*) ;; *) fail E "symlink escapes the export: $l";; esac
done < <(find "$TARGET" -type l ! -path "$TARGET/.git/*")

if [ "$FAILED" -ne 0 ]; then
  echo
  echo "EXPORT BLOCKED — the staged tree at $TARGET is dirty; do not push it."
  echo "Fix the source (or the manifest whitelist), never the export."
  exit 1
fi

# ── summary + provenance ─────────────────────────────────────────────────────
[ "$CHECK" -eq 1 ] && { echo "OK: guardrails green on existing export at $TARGET"; exit 0; }
SHA="$(git -C "$WS" rev-parse --short HEAD 2>/dev/null || echo untracked)"
[ "$SHA" != "untracked" ] || echo "WARNING: the workspace is not a git repo — no provenance. git init + commit before publishing for real."
echo "── export tree (two levels) ──"
find "$TARGET" -maxdepth 2 -name .git -prune -o -print | sed "s|$TARGET|.|" | sort
echo "── every .md that ships ──"
find "$TARGET" -name .git -prune -o -name '*.md' -print | sed "s|$TARGET|.|" | sort
echo
echo "OK: $(find "$TARGET" -type f ! -path "$TARGET/.git/*" | wc -l | tr -d ' ') files staged at $TARGET (source commit: $SHA)"
echo "Review it, then commit + push from inside it. Suggested trailer:"
echo "  Exported-From: $SHA"
