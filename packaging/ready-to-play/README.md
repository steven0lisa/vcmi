# Ready-to-play packaging

This directory turns a normal VCMI build into a package that works out of the
box: Heroes III data files, maps, music and a set of community mods are
bundled inside the app itself, the launcher setup wizard is skipped and the
startup update check is disabled.

## How it works

- `config/settings.json` (installed into the package data root) is merged as
  the base layer of user settings (`JsonUtils::assembleFromFiles` merges every
  `config/settings.json` found in data roots; the user's own file wins).
  It sets `launcher.updateOnStartup=false`, `launcher.setupCompleted=true` and
  `video.showIntro=false`.
- `config/defaultMods.json` is read by `ModsPresetState::createInitialPreset()`
  on first run to pre-enable the bundled community mods.
- Heroes III files (`Data/`, `Maps/`, `Mp3/`) and extra mods live in
  `h3data/` (git-ignored, **never commit** - copyrighted content) and are
  installed into the package data root when `ENABLE_BUNDLED_H3DATA=ON`.

Data roots searched by VCMI: macOS `<VCMI.app>/Contents/Resources/Data` plus
`~/Library/Application Support/vcmi` (user files override bundled files);
Windows the install dir (next to the exe) plus `Documents\My Games\vcmi`.

## Build a ready-to-play package

```bash
# 1. Provide the data (once):
packaging/ready-to-play/prepare_h3data.sh "$HOME/Library/Application Support/vcmi"

# 2. Configure with the packaging options (macOS example):
cmake --preset macos-arm-conan-ninja-release \
  -DENABLE_BUNDLED_H3DATA=ON \
  -DBUNDLE_MAIN_EXECUTABLE=client \
  -DPACKAGE_FILE_NAME=VCMI-ReadyToPlay-macOS
```

`BUNDLE_MAIN_EXECUTABLE=client` makes the macOS bundle open straight into the
game (the launcher is still installed for mod management). Windows builds keep
their normal layout; the Windows NSIS wrapper in this directory points the
shortcuts at `VCMI_client.exe`.
