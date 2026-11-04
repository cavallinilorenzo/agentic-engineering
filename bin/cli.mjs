#!/usr/bin/env node
// Installs this package's skills and agents into ~/.claude by copying them.
// No dependencies. Usage: see HELP below.
import { cpSync, existsSync, lstatSync, mkdirSync, readFileSync, readdirSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const HELP = `agentic-engineering: skills and agents for Claude Code

Usage:
  npx agentic-engineering@latest [install] [--retire] [--dry-run]
  npx agentic-engineering@latest uninstall [--dry-run]

  install     copy skills to ~/.claude/skills and agents to ~/.claude/agents
              (default; running it again updates)
  uninstall   remove only what a previous install put there
  --retire    also move the skills and agents this set replaces to the backup
  --dry-run   show what would happen, touch nothing

Anything replaced or moved goes to ~/.claude/backups/agentic-engineering-<timestamp>.`;

// Superseded by this set. Keep in step with LEGACY_* in scripts/install.sh (tests check it).
export const LEGACY_SKILLS = "ask-matt code-review diagnosing-bugs grill-me grill-with-docs grilling implement implement-spec improve-codebase-architecture pr setup-matt-pocock-skills to-spec to-tickets wayfinder impeccable".split(" ");
export const LEGACY_AGENTS = "code-reviewer.md security-auditor.md test-engineer.md web-performance-auditor.md impeccable-asset-producer.md impeccable-documenter.md impeccable-finish-reviewer.md impeccable-manual-edit-applier.md".split(" ");

const pkgRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
const claude = join(homedir(), ".claude");
const manifestPath = join(claude, "agentic-engineering.json");
const stamp = new Date().toISOString().replace(/\D/g, "").slice(0, 14);
const backup = join(claude, "backups", `agentic-engineering-${stamp}`);

const args = process.argv.slice(2);
const flags = new Set(args.filter((a) => a.startsWith("-")));
const command = args.find((a) => !a.startsWith("-")) ?? "install";
const dry = flags.has("--dry-run");
const known = new Set(["--retire", "--dry-run", "--help", "-h"]);
if (flags.has("--help") || flags.has("-h") || ![...flags].every((f) => known.has(f)) || !["install", "uninstall"].includes(command)) {
  console.error(HELP);
  process.exit(flags.has("--help") || flags.has("-h") ? 0 : 2);
}

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

function install() {
  const old = readManifest();
  if (flags.has("--retire")) {
    for (const n of LEGACY_SKILLS) if (exists(join(claude, "skills", n))) moveAway(join(claude, "skills", n), "skills");
    for (const n of LEGACY_AGENTS) if (exists(join(claude, "agents", n))) moveAway(join(claude, "agents", n), "agents");
  }
  const skills = names("skills", true);
  const agents = names("agents", false);
  for (const n of skills) put(join(pkgRoot, "skills", n), join(claude, "skills", n), "skills", old.skills.includes(n));
  for (const n of agents) put(join(pkgRoot, "agents", n), join(claude, "agents", n), "agents", old.agents.includes(n));
  // Stable path for the SessionStart hook described in the README.
  const script = join(claude, "agentic-engineering", "clean-worktrees.sh");
  console.log(`${dry ? "would copy" : "copied"} ${script}`);
  if (!dry) {
    mkdirSync(dirname(script), { recursive: true });
    cpSync(join(pkgRoot, "scripts", "clean-worktrees.sh"), script);
  }
  // Drop what an earlier version installed and this one no longer ships.
  for (const n of old.skills.filter((x) => !skills.includes(x))) remove(join(claude, "skills", n));
  for (const n of old.agents.filter((x) => !agents.includes(x))) remove(join(claude, "agents", n));
  if (!dry) {
    const { version } = JSON.parse(readFileSync(join(pkgRoot, "package.json"), "utf8"));
    writeFileSync(manifestPath, JSON.stringify({ version, skills, agents }, null, 2) + "\n");
  }
  console.log(dry ? "\nNothing changed. Run without --dry-run to do this." : "\nDone. Open a new Claude Code session, then run /setup in each repo.");
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
  remove(join(claude, "agentic-engineering"));
  remove(manifestPath);
}

if (command === "install") install();
else uninstall();
