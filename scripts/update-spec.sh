#!/usr/bin/env bash
set -euo pipefail

COMMIT="${1:?Usage: $0 <commit-sha> [qemu-version]}"
QEMU_VERSION="${2:-}"
SPEC_FILE="${SPEC_FILE:-SPECS/libvirt.spec}"

# ── 1. Pin the commit SHA in the spec ──────────────────────────────────────
echo "==> Setting %%global commit to ${COMMIT}"
sed -i "s/^%global commit .*/%global commit ${COMMIT}/" "$SPEC_FILE"

# ── 2. Pin QEMU version if requested ──────────────────────────────────────
if [ -n "$QEMU_VERSION" ]; then
    echo "==> Setting %%global qemu_version to ${QEMU_VERSION}"
    sed -i "s/^# global qemu_version.*/%global qemu_version ${QEMU_VERSION}/" "$SPEC_FILE"
fi

# ── 3. Bump Release number ─────────────────────────────────────────────────
CURRENT_RELEASE=$(grep -m1 '^Release:' "$SPEC_FILE" \
  | sed 's/Release:[[:space:]]*//' \
  | grep -oP '^\d+')
NEW_RELEASE=$((CURRENT_RELEASE + 1))

echo "==> Bumping Release: ${CURRENT_RELEASE} -> ${NEW_RELEASE}"
sed -i "0,/^Release:[[:space:]]*${CURRENT_RELEASE}/s/^Release:[[:space:]]*${CURRENT_RELEASE}/Release: ${NEW_RELEASE}/" "$SPEC_FILE"
