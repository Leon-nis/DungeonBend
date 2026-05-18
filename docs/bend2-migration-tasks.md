# DungeonBend and Bend2

Snapshot updated on `2026-05-18` against sibling `../Bend2` after the current
repository pull.

## Build contract

- `./scripts/build.sh` remains the only supported entrypoint.
- `scripts/build.ts` now builds directly against the current `Bend2`
  `bend/src` toolchain.
- No compatibility bridge stages source into `/tmp`.
- No compiler files are copied, patched, or rewritten.
- No legacy `bend-ts`, `prelude`, `old_base`, or `BEND_PRELUDE_DIR` path is
  part of the active workflow.

## Source layout contract

- Local modules now follow the canonical `Foo/Bar/_.bend` ownership model that
  the stock Bend2 loader understands.
- Generated Dungeon modules are written to:
  - `src/Dungeon/generated_config/_.bend`
  - `src/Dungeon/generated_hero_presentation/_.bend`
  - `src/Dungeon/generated_rules/_.bend`
  - `src/Dungeon/generated_content/_.bend`
- Imports must resolve through real module owners. DungeonBend should not rely
  on ancestor fallback or prefix-only imports.

## Renderer contract

- DungeonBend remains a web showcase on the official `App/HTML` path.
- `Midum` is still the local UI layer, but it now sits above the stock Bend2
  runtime instead of behind a compiler fork.
- Keyboard handling and DOM behavior must come from app-owned markup and runtime
  behavior, not post-build JS rewrites.

## What this document no longer describes

These are intentionally no longer part of the project strategy:

- compiling against `../Bend2/old_base`
- staged syntax normalization
- owner indexing inside `scripts/build.ts`
- textual patching of `bend/src/Lang.ts`
- HTML runtime patch injection after compilation
