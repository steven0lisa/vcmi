#!/usr/bin/env bash
# Collects Heroes III data files and community mods into h3data/ so that a
# build with -DENABLE_BUNDLED_H3DATA=ON ships a ready-to-play package.
#
# Usage:
#   ./prepare_h3data.sh <source dir>
#
# The source dir must be a VCMI "data root" layout - Data/, Maps/ and Mp3/
# subdirectories (Mods/ optional). Both a VCMI user dir
# (e.g. "~/Library/Application Support/vcmi" on macOS) and a HoMM3 Complete
# install dir (Data/ Maps/ Mp3/ from the game) work.
#
# h3data/ is git-ignored: these files are copyrighted by Ubisoft / mod authors
# and must never be committed or pushed.
set -euo pipefail

SRC="${1:?Usage: $0 <dir containing Data/ Maps/ Mp3/ [Mods/] - e.g. ~/Library/Application Support/vcmi>}"
[ -d "$SRC/Data" ] || { echo "ERROR: $SRC/Data not found"; exit 1; }

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEST="$REPO_ROOT/h3data"
mkdir -p "$DEST"

for d in Data Maps Mp3 Mods; do
	if [ -d "$SRC/$d" ]; then
		echo "Copying $SRC/$d -> $DEST/$d"
		rm -rf "$DEST/$d"
		cp -a "$SRC/$d" "$DEST/$d"
	fi
done

echo "Applying mod compatibility patches"
python3 "$(dirname "$0")/apply_mod_patches.py"

echo "Done. Contents of $DEST:"
du -sh "$DEST"/*
