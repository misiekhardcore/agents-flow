#!/usr/bin/env bash
# Smoke test for bin/install — runs against a throwaway XDG_CONFIG_HOME.
set -euo pipefail

INSTALLER="$(cd "$(dirname "$0")/.." && pwd)/bin/install"
fail=0

header() { echo ""; echo "=== $1 ==="; }
pass() { echo "PASS: $1"; }
fail_check() { echo "FAIL: $1"; fail=1; }

# --- Fresh install ---
header "Test 1: Fresh install creates all 3 symlinks"
XDG_CONFIG_HOME="$(mktemp -d)"
export XDG_CONFIG_HOME
"$INSTALLER"
for dir in commands agents skills; do
  dst="$XDG_CONFIG_HOME/opencode/$dir"
  if [ ! -L "$dst" ]; then fail_check "$dst is not a symlink"; continue; fi
  target="$(readlink "$dst")"
  expected="$(cd "$(dirname "$INSTALLER")/.." && pwd)/$dir"
  if [ "$target" != "$expected" ]; then
    fail_check "$dst -> $target (expected $expected)"
  else
    pass "$dst -> $target"
  fi
done

# --- Idempotency ---
header "Test 2: Idempotent re-run"
"$INSTALLER"
link_count="$(find "$XDG_CONFIG_HOME/opencode" -maxdepth 1 -type l | wc -l)"
if [ "$link_count" -ne 3 ]; then
  fail_check "symlink count after re-run: $link_count (expected 3)"
else
  pass "symlink count: $link_count"
fi

# --- Skills resolution ---
header "Test 3: SKILL.md resolves through symlink"
if [ -f "$XDG_CONFIG_HOME/opencode/skills/preflight/SKILL.md" ]; then
  pass "skills/preflight/SKILL.md resolves through symlink"
else
  fail_check "skills/preflight/SKILL.md not found at $(ls "$XDG_CONFIG_HOME/opencode/skills/" 2>&1)"
fi

# --- Safety guard ---
header "Test 4: Safety guard against real dirs"
rm -rf "$XDG_CONFIG_HOME/opencode"
mkdir -p "$XDG_CONFIG_HOME/opencode/commands"
echo "real content" > "$XDG_CONFIG_HOME/opencode/commands/foo"
if "$INSTALLER" 2>&1; then
  fail_check "installer should have aborted"
elif [ ! -f "$XDG_CONFIG_HOME/opencode/commands/foo" ]; then
  fail_check "real dir was clobbered"
else
  pass "installer aborted, real dir preserved"
fi

# --- Uninstall ---
header "Test 5: --uninstall removes repo symlinks"
rm -rf "$XDG_CONFIG_HOME"
XDG_CONFIG_HOME="$(mktemp -d)"
"$INSTALLER" > /dev/null
"$INSTALLER" --uninstall
remaining="$(find "$XDG_CONFIG_HOME/opencode" -type l 2>/dev/null | wc -l)"
if [ "$remaining" -ne 0 ]; then
  fail_check "symlinks remaining after uninstall: $remaining (expected 0)"
else
  pass "uninstall removed all symlinks"
fi

# --- Summary ---
header "Results"
if [ "$fail" -ne 0 ]; then
  echo "FAILED — $fail check(s) failed"
else
  echo "ALL PASSED"
fi
exit "$fail"
