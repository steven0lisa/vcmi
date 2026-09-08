#!/usr/bin/env python3
"""Applies compatibility patches to the bundled mods in h3data/ after prepare_h3data.sh.

wake-of-gods 9.1.48 still references identifiers removed in newer VCMI cores.
Only the failing entry that triggers the "Mod loading failure" popup is patched;
WARN-level schema warnings are harmless and identical to what the 1.7.3 logs show.
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
H3DATA = REPO / "h3data"

PATCHES = [
    {
        # ACID_BREATH bonus type was retired in VCMI 1.8 (see lib/bonuses/BonusEnum.h);
        # the same effect is kept through the unit's SPELL_AFTER_ATTACK: spell.acidBreath
        # bonus, so dropping the stale block loses nothing.
        "file": "Mods/wake-of-gods/Mods/level8Units/content/config/creatures/hellHydra.json",
        "pattern": r'\t\t\t"acidBreath" :\n\t\t\t\{\n\t\t\t\t"type" : "ACID_BREATH",\n\t\t\t\t"val" : 25,\n\t\t\t\t"addInfo" : 20\n\t\t\t\},\n',
        "replace": "",
        "required": True,
    },
]


def main() -> int:
    failures = 0
    for patch in PATCHES:
        path = H3DATA / patch["file"]
        if not path.exists():
            print(f"SKIP (file missing): {patch['file']}")
            failures += 1 if patch["required"] else 0
            continue
        text = path.read_text(encoding="utf-8")
        new_text, count = re.subn(patch["pattern"], patch["replace"], text)
        if count:
            path.write_text(new_text, encoding="utf-8")
            print(f"PATCHED ({count}x): {patch['file']}")
        elif patch["replace"] in text or not re.search(patch["pattern"], text):
            print(f"OK (already patched or pattern absent): {patch['file']}")
        else:
            print(f"ERROR: pattern not found in {patch['file']}")
            failures += 1
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
