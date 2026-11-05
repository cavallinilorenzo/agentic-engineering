#!/usr/bin/env node
// Installs this package's skills and agents into ~/.claude by copying them.
// No dependencies. Usage: see HELP below.
import { cpSync, existsSync, lstatSync, mkdirSync, readFileSync, readdirSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { homedir } from "node:os";
import { createInterface } from "node:readline/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const HELP = `agentic-engineering: skills and agents for Claude Code

Usage:
  npx agentic-engineering@latest [install] [options]
  npx agentic-engineering@latest uninstall [--global | --project] [--dry-run]

  install     copy the chosen skills and the agents to <scope>/skills and
              <scope>/agents (default; running it again updates).
              In a terminal it asks for the scope and the skills.
  uninstall   remove only what a previous install put there

Options:
  --global        install in ~/.claude (every project)
  --project       install in .claude of the current repo (this project only)
  --skills=a,b    install only these skills; the others this tool installed
                  earlier in the same scope are removed
  --all           install every skill, without asking
  --yes, -y       ask nothing: global scope and all skills unless flags say otherwise
  --retire        also move the skills and agents this set replaces to the
                  backup (global scope only)
  --dry-run       show what would happen, touch nothing

Anything replaced or moved goes to ~/.claude/backups/agentic-engineering-<timestamp>.`;

// Superseded by this set. Keep in step with LEGACY_* in scripts/install.sh (tests check it).
export const LEGACY_SKILLS = "ask-matt code-review diagnosing-bugs grill-me grill-with-docs grilling implement implement-spec improve-codebase-architecture pr setup-matt-pocock-skills to-spec to-tickets wayfinder impeccable".split(" ");
export const LEGACY_AGENTS = "code-reviewer.md security-auditor.md test-engineer.md web-performance-auditor.md impeccable-asset-producer.md impeccable-documenter.md impeccable-finish-reviewer.md impeccable-manual-edit-applier.md".split(" ");

const pkgRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
const stamp = new Date().toISOString().replace(/\D/g, "").slice(0, 14);

const args = process.argv.slice(2);
const flags = new Set(args.filter((a) => a.startsWith("-") && !a.startsWith("--skills=")));
const skillsArg = args.find((a) => a.startsWith("--skills="));
const command = args.find((a) => !a.startsWith("-")) ?? "install";
const dry = flags.has("--dry-run");
const known = new Set(["--retire", "--dry-run", "--global", "--project", "--all", "--yes", "-y", "--help", "-h"]);
if (flags.has("--help") || flags.has("-h") || ![...flags].every((f) => known.has(f)) || !["install", "uninstall"].includes(command) || (flags.has("--global") && flags.has("--project"))) {
  console.error(HELP);
  process.exit(flags.has("--help") || flags.has("-h") ? 0 : 2);
}

function projectRoot() {
  try { return execFileSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim(); } catch { return process.cwd(); }
}

const interactive = process.stdin.isTTY && process.stdout.isTTY && !flags.has("--yes") && !flags.has("-y");
const rl = interactive ? createInterface({ input: process.stdin, output: process.stdout }) : null;

// Scope: ~/.claude for every project, or .claude of the current repo.
let scope = flags.has("--global") ? "global" : flags.has("--project") ? "project" : null;
if (!scope && interactive) {
  const a = (await rl.question(`Where to install?\n  1) Global: ~/.claude, every project\n  2) This repo only: ${join(projectRoot(), ".claude")}\n> [1] `)).trim();
  scope = a === "2" ? "project" : "global";
}
scope ??= "global";
const claude = scope === "project" ? join(projectRoot(), ".claude") : join(homedir(), ".claude");
const manifestPath = join(claude, "agentic-engineering.json");
const backup = join(claude, "backups", `agentic-engineering-${stamp}`);

const exists = (p) => existsSync(p) || isLink(p);
const isLink = (p) => { try { return lstatSync(p).isSymbolicLink(); } catch { return false; } };
const names = (dir, onlyDirs) =>
  readdirSync(join(pkgRoot, dir), { withFileTypes: true })
    .filter((e) => (onlyDirs ? e.isDirectory() : e.isFile() && e.name.endsWith(".md")))
    .map((e) => e.name);

function readManifest() {
  try { return JSON.parse(readFileSync(manifestPath, "utf8")); } catch { return { skills: [], agents: [] }; }
}

function moveAway(path, kind) {
  console.log(`${dry ? "would move" : "moved "} ${path} -> ${join(backup, kind)}/`);
  if (dry) return;
  mkdirSync(join(backup, kind), { recursive: true });
  renameSync(path, join(backup, kind, path.split("/").pop()));
}

function put(src, dest, kind, owned) {
  if (exists(dest)) {
    if (owned && !isLink(dest)) {
      console.log(`${dry ? "would update" : "updated"} ${dest}`);
      if (!dry) rmSync(dest, { recursive: true, force: true });
    } else {
      moveAway(dest, kind);
      console.log(`${dry ? "would copy" : "copied"} ${dest}`);
    }
  } else {
    console.log(`${dry ? "would copy" : "copied"} ${dest}`);
  }
  if (dry) return;
  mkdirSync(dirname(dest), { recursive: true });
  cpSync(src, dest, { recursive: true });
}

// Which skills to install: --skills, else a numbered prompt, else all.
async function chooseSkills(all, old) {
  if (skillsArg) {
    const want = skillsArg.slice("--skills=".length).split(",").map((x) => x.trim()).filter(Boolean);
    const bad = want.filter((x) => !all.includes(x));
    if (bad.length) { console.error(`Unknown skill: ${bad.join(", ")}\nAvailable: ${all.join(", ")}`); process.exit(2); }
    return all.filter((x) => want.includes(x));
  }
  if (!interactive || flags.has("--all")) return all;
  const had = new Set(old.skills);
  console.log("\nSkills (\u2713 = already installed here):");
  all.forEach((n, i) => console.log(`  ${String(i + 1).padStart(2)}) ${n}${had.has(n) ? " \u2713" : ""}`));
  const a = (await rl.question("Numbers or ranges, e.g. 1,3,5-8. Enter or 'all' for every skill.\n> ")).trim().toLowerCase();
  if (a === "" || a === "all") return all;
  const picked = new Set();
  for (const part of a.split(/[\s,]+/).filter(Boolean)) {
    const m = part.match(/^(\d+)(?:-(\d+))?$/);
    const lo = m && Number(m[1]), hi = m && Number(m[2] ?? m[1]);
    if (!m || lo < 1 || hi > all.length || lo > hi) { console.error(`Not a valid choice: ${part}`); process.exit(2); }
    for (let i = lo; i <= hi; i++) picked.add(all[i - 1]);
  }
  return all.filter((n) => picked.has(n));
}

async function install() {
  const old = readManifest();
  if (flags.has("--retire") && scope === "global") {
    for (const n of LEGACY_SKILLS) if (exists(join(claude, "skills", n))) moveAway(join(claude, "skills", n), "skills");
    for (const n of LEGACY_AGENTS) if (exists(join(claude, "agents", n))) moveAway(join(claude, "agents", n), "agents");
  }
  const skills = await chooseSkills(names("skills", true), old);
  const agents = names("agents", false);
  if (rl) rl.close();
  if (!skills.length) { console.error("No skill chosen, nothing to do."); process.exit(2); }
  console.log(`\nInstalling ${skills.length} skills and ${agents.length} agents in ${claude}\n`);
  for (const n of skills) put(join(pkgRoot, "skills", n), join(claude, "skills", n), "skills", old.skills.includes(n));
  for (const n of agents) put(join(pkgRoot, "agents", n), join(claude, "agents", n), "agents", old.agents.includes(n));
  // Stable path for the SessionStart hook described in the README. Global only: the hook lives in ~/.claude/settings.json.
  if (scope === "global") {
    const script = join(claude, "agentic-engineering", "clean-worktrees.sh");
    console.log(`${dry ? "would copy" : "copied"} ${script}`);
    if (!dry) {
      mkdirSync(dirname(script), { recursive: true });
      cpSync(join(pkgRoot, "scripts", "clean-worktrees.sh"), script);
    }
  }
  // Drop what an earlier version installed and this one no longer ships.
  for (const n of old.skills.filter((x) => !skills.includes(x))) remove(join(claude, "skills", n));
  for (const n of old.agents.filter((x) => !agents.includes(x))) remove(join(claude, "agents", n));
  if (!dry) {
    const { version } = JSON.parse(readFileSync(join(pkgRoot, "package.json"), "utf8"));
    mkdirSync(claude, { recursive: true });
    writeFileSync(manifestPath, JSON.stringify({ version, skills, agents }, null, 2) + "\n");
  }
  console.log(dry ? "\nNothing changed. Run without --dry-run to do this." : `\nDone. Open a new Claude Code session${scope === "global" ? ", then run /setup in each repo" : ""}.`);
}

function remove(path) {
  if (!exists(path)) return;
  console.log(`${dry ? "would remove" : "removed"} ${path}`);
  if (!dry) rmSync(path, { recursive: true, force: true });
}

function uninstall() {
  const m = readManifest();
  for (const n of m.skills) remove(join(claude, "skills", n));
  for (const n of m.agents) remove(join(claude, "agents", n));
  if (scope === "global") remove(join(claude, "agentic-engineering"));
  remove(manifestPath);
}

if (command === "install") await install();
else { rl?.close(); uninstall(); }
