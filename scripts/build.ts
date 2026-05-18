import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as process from "node:process";
import { generateDungeonConfig } from "./dungeon-data.ts";

type BendRepo = {
  repoRoot: string;
  cliPath: string;
};

type BuildTarget = {
  entry: string;
  output: string;
};

const BUILD_TARGETS: BuildTarget[] = [
  { entry: "src/main.bend", output: "index.html" },
  { entry: "src/ui_test.bend", output: "ui-test/index.html" },
];

async function pathExists(target: string): Promise<boolean> {
  try {
    await fs.access(target);
    return true;
  } catch {
    return false;
  }
}

async function resolveBendRepo(cwd: string): Promise<BendRepo> {
  const candidates = [
    process.env.BEND_DIR ? path.resolve(cwd, process.env.BEND_DIR) : null,
    path.resolve(cwd, "../Bend2"),
  ].filter((value): value is string => value !== null);

  for (const repoRoot of candidates) {
    const cliPath = path.join(repoRoot, "bend", "src", "CLI.ts");
    if (await pathExists(cliPath)) {
      return { repoRoot, cliPath };
    }

    if (await pathExists(path.join(repoRoot, "bend-ts", "src", "Bend.ts"))) {
      throw new Error(
        `Legacy Bend2 layout detected at ${repoRoot}. DungeonBend now requires bend/src/CLI.ts from the current repository layout.`,
      );
    }
  }

  throw new Error(
    "Current Bend2 repo not found. Set BEND_DIR to a checkout that contains bend/src/CLI.ts or keep ../Bend2 next to this repo.",
  );
}

function runOrThrow(args: string[], cwd: string): void {
  const proc = Bun.spawnSync(args, {
    cwd,
    env: process.env,
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
  });
  if (proc.exitCode !== 0) {
    throw new Error(`Command failed with exit code ${proc.exitCode}: ${args.join(" ")}`);
  }
}

async function ensureGeneratedTargets(cwd: string): Promise<void> {
  await Promise.all([
    fs.mkdir(path.join(cwd, "src", "Dungeon", "generated_config"), { recursive: true }),
    fs.mkdir(path.join(cwd, "src", "Dungeon", "generated_hero_presentation"), { recursive: true }),
    fs.mkdir(path.join(cwd, "src", "Dungeon", "generated_rules"), { recursive: true }),
    fs.mkdir(path.join(cwd, "src", "Dungeon", "generated_content"), { recursive: true }),
  ]);
}

async function copyAssets(cwd: string, outDir: string): Promise<void> {
  const outAssets = path.join(outDir, "assets");
  await fs.mkdir(outAssets, { recursive: true });
  await fs.cp(path.join(cwd, "assets"), outAssets, { recursive: true, force: true });
}

async function buildTarget(cwd: string, bend: BendRepo, outDir: string, target: BuildTarget): Promise<void> {
  const outputPath = path.join(outDir, target.output);
  await fs.mkdir(path.dirname(outputPath), { recursive: true });
  runOrThrow([process.execPath, bend.cliPath, target.entry, "-o", outputPath], cwd);
  process.stdout.write(`Built ${outputPath}\n`);
}

async function main(): Promise<void> {
  const cwd = process.cwd();
  const outDir = path.resolve(cwd, process.env.OUT_DIR ?? "dist");
  const bend = await resolveBendRepo(cwd);

  await ensureGeneratedTargets(cwd);
  await generateDungeonConfig(cwd);
  runOrThrow([process.execPath, path.join(cwd, "scripts", "generate-dungeon-view-css.ts")], cwd);

  await fs.mkdir(outDir, { recursive: true });
  await Promise.all(BUILD_TARGETS.map((target) => buildTarget(cwd, bend, outDir, target)));
  await copyAssets(cwd, outDir);
  await Bun.write(path.join(outDir, ".nojekyll"), "");
}

await main();
