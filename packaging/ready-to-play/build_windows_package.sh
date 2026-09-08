#!/usr/bin/env bash
# Build the Windows ready-to-play installer from a CI-produced zip.
#
# Usage:
#   ./build_windows_package.sh <path-to-VCMI-windows-zip> [version]
#
# Steps:
#   1. unzip the CI artifact (clean VCMI build for Windows x64)
#   2. inject bundled HoMM3 data + community mods from h3data/
#   3. verify the pre-seeded config files made it through the CI install rules
#   4. compile the NSIS installer (makensis must be installed, e.g. `brew install makensis`)
set -euo pipefail

ZIP="${1:?Usage: $0 <vcmi-windows-zip> [version]}"
VERSION="${2:-1.8.0}"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$REPO_ROOT/out/win-staging"
DIST="$REPO_ROOT/out/win-dist"
[ -d "$REPO_ROOT/h3data/Data" ] || { echo "ERROR: h3data/ empty - run prepare_h3data.sh first"; exit 1; }

rm -rf "$WORK" "$DIST"
mkdir -p "$WORK" "$DIST"

echo "==> Unzipping $ZIP"
unzip -q "$ZIP" -d "$WORK/payload"
# CI zips sometimes nest a single directory - flatten to the payload root
if [ "$(ls -A "$WORK/payload" | wc -l | tr -d ' ')" = "1" ] && [ -d "$WORK/payload"/* ]; then
    mv "$WORK/payload"/*/* "$WORK/payload/"
fi
ls "$WORK/payload" | head -5

echo "==> Verifying pre-seeded config"
for f in config/settings.json config/defaultMods.json; do
    if [ ! -f "$WORK/payload/$f" ]; then
        echo "  missing $f in CI zip, copying from packaging/ready-to-play"
        mkdir -p "$WORK/payload/config"
        cp "$REPO_ROOT/packaging/ready-to-play/$f" "$WORK/payload/$f"
    fi
done
python3 -c "import json;print('  updateOnStartup =', json.load(open('$WORK/payload/config/settings.json'))['launcher']['updateOnStartup'])"

echo "==> Injecting HoMM3 data and mods"
for d in Data Maps Mp3 Mods; do
    [ -d "$REPO_ROOT/h3data/$d" ] || continue
    rm -rf "$WORK/payload/$d"
    cp -a "$REPO_ROOT/h3data/$d" "$WORK/payload/$d"
done
du -sh "$WORK/payload"

echo "==> Building NSIS installer"
(cd "$REPO_ROOT" && makensis -V2 \
    -DINPUT_DIR="$WORK/payload" \
    -DVERSION="$VERSION" \
    packaging/ready-to-play/windows-installer.nsi)

OUT="$DIST/VCMI-ReadyToPlay-Windows-x64.exe"
mv "$REPO_ROOT/VCMI-ReadyToPlay-Windows-x64.exe" "$OUT"
echo "==> Done: $OUT ($(du -h "$OUT" | cut -f1))"
