#!/usr/bin/env bash
set -euo pipefail

# Build a local macOS .dmg of the desktop app with auto-update disabled.
# The frontend skips the periodic update poll (VITE_OPENJARVIS_NO_UPDATER)
# and the updater plugin gets no endpoints (tauri.local.conf.json), so the
# app never fetches new versions. Update by pulling and re-running this.
# Usage: ./scripts/build-local-dmg.sh

if [ "$(uname)" != "Darwin" ]; then
  echo "Error: this script only builds macOS .dmg bundles"
  exit 1
fi

for cmd in cargo npm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' is required but not installed"
    exit 1
  fi
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/frontend"

if [ ! -d node_modules ]; then
  npm ci
fi

export VITE_OPENJARVIS_NO_UPDATER=1

npx tauri build --bundles app,dmg --config src-tauri/tauri.local.conf.json

DMG_DIR="$REPO_ROOT/frontend/src-tauri/target/release/bundle/dmg"
echo
echo "Done. DMG:"
ls -1 "$DMG_DIR"/*.dmg
