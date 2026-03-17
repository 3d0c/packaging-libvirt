#!/usr/bin/env bash
set -euo pipefail

COMMIT="${1:?Usage: $0 <commit-sha>}"
UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/NVIDIA/libvirt.git}"
SPEC_FILE="${SPEC_FILE:-SPECS/libvirt.spec}"
SOURCES_DIR="${SOURCES_DIR:-SOURCES}"

VERSION=$(grep -m1 '^Version:' "$SPEC_FILE" | awk '{print $2}')
EXTRACT_DIR="libvirt-${VERSION}"
TARBALL_NAME="libvirt-${VERSION}.tar.xz"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

echo "==> Cloning NVIDIA/libvirt..."
git clone --filter=blob:none "$UPSTREAM_REPO" "$WORKDIR/src"

pushd "$WORKDIR/src" > /dev/null
echo "==> Checking out ${COMMIT}..."
git checkout "$COMMIT"
popd > /dev/null

echo "==> Preparing source tree as ${EXTRACT_DIR}/..."
mv "$WORKDIR/src" "$WORKDIR/${EXTRACT_DIR}"

find "$WORKDIR/${EXTRACT_DIR}" -name '.git' -exec rm -rf {} + 2>/dev/null || true

echo "==> Creating ${TARBALL_NAME}..."
tar -C "$WORKDIR" -cf - "${EXTRACT_DIR}" | xz -T0 -3 > "${SOURCES_DIR}/${TARBALL_NAME}"

echo "==> Done: ${SOURCES_DIR}/${TARBALL_NAME}"
ls -lh "${SOURCES_DIR}/${TARBALL_NAME}"
