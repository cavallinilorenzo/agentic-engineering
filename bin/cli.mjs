#!/usr/bin/env node
// Installs this package's skills (and, for Claude Code, its agents) by copying them.
// No dependencies. Usage: see HELP below.
import { cpSync, existsSync, lstatSync, mkdirSync, readFileSync, readdirSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const HELP = `agentic-engineering: skills and agents for coding agents

Usage:
  npx agentic-engineering@latest [install] [options]
  npx agentic-engineering@latest uninstall [--tool=...] [--global | --project] [--dry-run]

  install     copy the chosen skills (and, for Claude Code, the agents) to
              <scope>/skills and <scope>/agents (default; running it again updates).
              In a terminal it asks for the tool, the scope and the skills.
  uninstall   remove only what a previous install put there

Options:
  --tool=claude       Claude Code, default (OpenCode reads it too):
                      ~/.claude or .claude of the current repo
  --tool=antigravity  Antigravity, skills only:
                      ~/.gemini/config or .agents of the current repo
  --global        install for every project
  --project       install in the current repo only
  --skills=a,b    install only these skills; the others this tool installed
                  earlier in the same scope are removed
  --all           install every skill, without asking
  --yes, -y       ask nothing: global scope and all skills unless flags say otherwise
  --retire        also move the skills and agents this set replaces to the
                  backup (global scope only)
  --dry-run       show what would happen, touch nothing

Anything replaced or moved goes to <scope>/backups/agentic-engineering-<timestamp>.`;

// Superseded by this set. Keep in step with LEGACY_* in scripts/install.sh (tests check it).
export const LEGACY_SKILLS = "ask-matt code-review diagnosing-bugs grill-me grill-with-docs grilling implement implement-spec improve-codebase-architecture pr setup-matt-pocock-skills to-spec to-tickets wayfinder impeccable".split(" ");
export const LEGACY_AGENTS = "code-reviewer.md security-auditor.md test-engineer.md web-performance-auditor.md impeccable-asset-producer.md impeccable-documenter.md impeccable-finish-reviewer.md impeccable-manual-edit-applier.md".split(" ");

const pkgRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
const stamp = new Date().toISOString().replace(/\D/g, "").slice(0, 14);

const args = process.argv.slice(2);
const flags = new Set(args.filter((a) => a.startsWith("-") && !a.startsWith("--skills=") && !a.startsWith("--tool=")));
const skillsArg = args.find((a) => a.startsWith("--skills="));
const toolArg = args.find((a) => a.startsWith("--tool="))?.slice("--tool=".length);
const command = args.find((a) => !a.startsWith("-")) ?? "install";
const dry = flags.has("--dry-run");
const known = new Set(["--retire", "--dry-run", "--global", "--project", "--all", "--yes", "-y", "--help", "-h"]);

// Where each tool reads skills. Agents and the worktree hook use Claude Code's format only.
const TOOLS = {
  claude: { label: "Claude Code", hint: "~/.claude, also read by OpenCode", global: () => join(homedir(), ".claude"), project: () => join(projectRoot(), ".claude"), agents: true },
  antigravity: { label: "Antigravity", hint: "~/.gemini/config, skills only", global: () => join(homedir(), ".gemini", "config"), project: () => join(projectRoot(), ".agents"), agents: false },
};
if (flags.has("--help") || flags.has("-h") || ![...flags].every((f) => known.has(f)) || !["install", "uninstall"].includes(command) || (flags.has("--global") && flags.has("--project")) || (toolArg !== undefined && !TOOLS[toolArg])) {
  console.error(HELP);
  process.exit(flags.has("--help") || flags.has("-h") ? 0 : 2);
}

function projectRoot() {
  try { return execFileSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim(); } catch { return process.cwd(); }
}

const interactive = process.stdin.isTTY && process.stdout.isTTY && !flags.has("--yes") && !flags.has("-y");
// The pretty prompts are loaded only in a terminal, so piped runs and tests need no dependency.
const ui = interactive ? await import("@clack/prompts") : null;
const lines = [];
const tilde = (m) => m.replaceAll(homedir(), "~");
// In a terminal, plain copies are summarised; only backups, updates and removals are listed.
const say = (m) => (ui ? (/^(would copy|copied)\b/.test(m) || lines.push(tilde(m))) : console.log(m));
const ask = (v) => { if (ui.isCancel(v)) { ui.cancel("Cancelled, nothing changed."); process.exit(0); } return v; };

const BANNER = String.raw`
 █████╗  ██████╗ ███████╗███╗   ██╗████████╗██╗ ██████╗
██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██║██╔════╝
███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║██║
██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║██║
██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   ██║╚██████╗
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝ ╚═════╝`;
if (ui && command === "install") {
  console.log(`\x1b[36m${BANNER}\x1b[0m\n\x1b[2m  engineering: skills and agents for coding agents\x1b[0m\n`);
  ui.intro("agentic-engineering");
}

// Tool: which harness reads the skills.
let tool = toolArg ?? null;
if (!tool && interactive) {
  tool = ask(await ui.select({
    message: "Which tool do you use?",
    options: Object.entries(TOOLS).map(([value, t]) => ({ value, label: t.label, hint: t.hint })),
  }));
}
tool ??= "claude";
const T = TOOLS[tool];

// Scope: the tool's home folder for every project, or its folder in the current repo.
let scope = flags.has("--global") ? "global" : flags.has("--project") ? "project" : null;
if (!scope && interactive) {
  scope = ask(await ui.select({
    message: "Where do you want to install?",
    options: [
      { value: "global", label: "Global", hint: `${tilde(T.global())}, every project` },
      { value: "project", label: "This repo only", hint: T.project() },
    ],
  }));
}
scope ??= "global";
const root = scope === "project" ? T.project() : T.global();
const manifestPath = join(root, "agentic-engineering.json");
const backup = join(root, "backups", `agentic-engineering-${stamp}`);

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
  say(`${dry ? "would move" : "moved "} ${path} -> ${join(backup, kind)}/`);
  if (dry) return;
  mkdirSync(join(backup, kind), { recursive: true });
  renameSync(path, join(backup, kind, path.split("/").pop()));
}

function put(src, dest, kind, owned) {
  if (exists(dest)) {
    if (owned && !isLink(dest)) {
      say(`${dry ? "would update" : "updated"} ${dest}`);
      if (!dry) rmSync(dest, { recursive: true, force: true });
    } else {
      moveAway(dest, kind);
      say(`${dry ? "would copy" : "copied"} ${dest}`);
    }
  } else {
    say(`${dry ? "would copy" : "copied"} ${dest}`);
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
  const picked = ask(await ui.multiselect({
    message: "Which skills do you want to install? (space to toggle, enter to confirm)",
    options: all.map((n) => ({ value: n, label: n, hint: blurb(n) })),
    initialValues: had.size ? all.filter((n) => had.has(n)) : all,
    required: true,
    maxItems: 12,
  }));
  return all.filter((n) => picked.includes(n));
}

// First sentence of a skill's description, short enough for one terminal line.
function blurb(name) {
  try {
    const m = readFileSync(join(pkgRoot, "skills", name, "SKILL.md"), "utf8").match(/^description:\s*"?(.+?)"?\s*$/m);
    const first = m[1].split(/\.\s/)[0].replace(/\.$/, "");
    return first.length > 60 ? first.slice(0, 59).trimEnd() + "…" : first;
  } catch { return ""; }
}

async function install() {
  const old = readManifest();
  if (flags.has("--retire") && scope === "global" && tool === "claude") {
    for (const n of LEGACY_SKILLS) if (exists(join(root, "skills", n))) moveAway(join(root, "skills", n), "skills");
    for (const n of LEGACY_AGENTS) if (exists(join(root, "agents", n))) moveAway(join(root, "agents", n), "agents");
  }
  const skills = await chooseSkills(names("skills", true), old);
  const agents = T.agents ? names("agents", false) : [];
  if (!skills.length) { console.error("No skill chosen, nothing to do."); process.exit(2); }
  if (ui) ui.log.info(`${dry ? "Would install" : "Installing"} ${skills.length} skills and ${agents.length} agents in ${root}`);
  else console.log(`\nInstalling ${skills.length} skills and ${agents.length} agents in ${root}\n`);
  for (const n of skills) put(join(pkgRoot, "skills", n), join(root, "skills", n), "skills", old.skills.includes(n));
  for (const n of agents) put(join(pkgRoot, "agents", n), join(root, "agents", n), "agents", old.agents.includes(n));
  // Stable path for the SessionStart hook described in the README. Claude Code, global only: the hook lives in ~/.claude/settings.json.
  if (scope === "global" && tool === "claude") {
    const script = join(root, "agentic-engineering", "clean-worktrees.sh");
    say(`${dry ? "would copy" : "copied"} ${script}`);
    if (!dry) {
      mkdirSync(dirname(script), { recursive: true });
      cpSync(join(pkgRoot, "scripts", "clean-worktrees.sh"), script);
    }
  }
  // Drop what an earlier version installed and this one no longer ships.
  for (const n of old.skills.filter((x) => !skills.includes(x))) remove(join(root, "skills", n));
  for (const n of old.agents.filter((x) => !agents.includes(x))) remove(join(root, "agents", n));
  if (!dry) {
    const { version } = JSON.parse(readFileSync(join(pkgRoot, "package.json"), "utf8"));
    mkdirSync(root, { recursive: true });
    writeFileSync(manifestPath, JSON.stringify({ version, skills, agents }, null, 2) + "\n");
  }
  const done = dry ? "Nothing changed. Run without --dry-run to do this." : `Done. Open a new ${T.label} session${scope === "global" ? ", then run /setup in each repo" : ""}.`;
  if (ui) {
    lines.unshift(`Skills  ${skills.join(", ")}`, ...(agents.length ? [`Agents  ${agents.map((x) => x.replace(/\.md$/, "")).join(", ")}`] : []), `Where   ${tilde(root)}`, ...(lines.length ? [""] : []));
    flush(dry ? "Would install" : "Installed"); ui.outro(done); } else console.log(`\n${done}`);
}

function flush(title) {
  if (ui && lines.length) ui.note(lines.splice(0).join("\n"), title);
}

function remove(path) {
  if (!exists(path)) return;
  say(`${dry ? "would remove" : "removed"} ${path}`);
  if (!dry) rmSync(path, { recursive: true, force: true });
}

function uninstall() {
  const m = readManifest();
  for (const n of m.skills) remove(join(root, "skills", n));
  for (const n of m.agents) remove(join(root, "agents", n));
  if (scope === "global" && tool === "claude") remove(join(root, "agentic-engineering"));
  remove(manifestPath);
}

if (command === "install") await install();
else { uninstall(); if (ui) { flush(dry ? "Would remove" : "Removed"); ui.outro(dry ? "Nothing changed." : "Done."); } }
