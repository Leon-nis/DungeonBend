#!/bin/sh
set -eu

bend_dir="${BEND_DIR:-../Bend2}"

if [ -f "$bend_dir/bend-ts/src/Bend.ts" ]; then
  echo "Legacy Bend2 layout detected at $bend_dir. DungeonBend now requires the current bend/src layout." >&2
  exit 1
fi

if [ ! -f "$bend_dir/bend/src/CLI.ts" ]; then
  echo "Current Bend2 CLI not found. Set BEND_DIR to a checkout that contains bend/src/CLI.ts or keep ../Bend2 next to this repo." >&2
  exit 1
fi

bun scripts/build.ts
