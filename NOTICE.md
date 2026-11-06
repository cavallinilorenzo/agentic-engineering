# Origine di ogni skill

Questo progetto è sotto licenza MIT (vedi [LICENSE](LICENSE)). Riusa materiale altrui, citato qui con commit e licenza.

- **Copiata:** testo originale. Cambiano solo i nomi e i riferimenti indicati.
- **Rielaborata:** parte da una o più fonti, con struttura o contenuto riscritti.
- **Nuova:** scritta qui. Le fonti sono solo spunti.

## Commit delle fonti

| Sigla | Progetto | Commit | Licenza |
|---|---|---|---|
| Matt | [mattpocock/skills](https://github.com/mattpocock/skills) | `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d` | MIT |
| Addy | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | `301b02b12bff98e4688e6984af6556802322bbde` | MIT |
| pstack | [cursor/plugins, cartella pstack](https://github.com/cursor/plugins/tree/main/pstack) | `bb68f2365eceafa0cb2d253112f675acf5f144cc` | MIT |
| Vercel | [vercel-labs/web-interface-guidelines](https://github.com/vercel-labs/web-interface-guidelines) | `434b7f91364665f2f733b310ec54809bf8f37937` | MIT |

## Copiate

| Skill | Origine | Cosa cambia |
|---|---|---|
| `grill` | Matt `productivity/grilling` | Nome |
| `fog` | Matt `engineering/wayfinder` | Nome; riferimenti a `grill` e `/setup` |
| `arch` | Matt `engineering/improve-codebase-architecture` | Nome; riferimento a `grill` |
| `triage` | Matt `engineering/triage` | Riferimento a `/setup` |
| `retro` | Matt `engineering/retro` | Nessuna |
| `handoff` | Matt `productivity/handoff` | Nessuna |
| `tdd` | Matt `engineering/tdd` | Riferimento a `judge` |
| `prototype` | Matt `engineering/prototype` | Nessuna |
| `research` | Matt `engineering/research` | Nessuna |
| `domain-modeling` | Matt `engineering/domain-modeling` | Nessuna |
| `codebase-design` | Matt `engineering/codebase-design` | Nessuna |
| `writing-for-agents` | Matt `productivity/writing-for-agents` | Nessuna |

File copiati dentro skill rielaborate:

| File | Origine |
|---|---|
| `skills/ask/PHASE-BOUNDARIES.md` | Matt `engineering/ask-matt` |
| `skills/setup/domain.md`, `issue-tracker-*.md`, `triage-labels.md` | Matt `engineering/setup-matt-pocock-skills` (riferimenti a `/fog`, `/slice` e `/arch`) |
| `skills/ui/references/web-interface-guidelines.md` | Vercel `command.md` |

## Rielaborate

| Skill | Fonti | Cosa è cambiato |
|---|---|---|
| `spec` | Matt `to-spec` | Solo cosa e perché: le decisioni tecniche passano a `slice`; aggiunti i criteri di accettazione |
| `slice` | Matt `to-tickets`, Addy `planning-and-task-breakdown`, Matt `to-spec` | Fase sempre presente, che unisce design, rischio, dipendenze e fette; pubblica ticket solo se servono |
| `build` | Matt `implement`, Addy `incremental-implementation` | Worktree obbligatorio; chiude con il `verifier` e la ricevuta |
| `swarm` | Matt `implement-spec` | Massimo 3 agenti alla volta; controllo dei file in comune; verifica finale |
| `fix` | Matt `diagnosing-bugs`, pstack `principle-fix-root-causes` | Base copiata; aggiunti regola sulla causa radice, worktree e verifica finale |
| `judge` | Matt `code-review`, Addy `code-review-and-quality`, pstack `blast-radius` | Assi separati di Matt, controlli di Addy, asse blast radius; profondità decisa dal rischio |
| `ship` | Matt `pr`, pstack `opening-a-pr`, Matt `implement` (controlli veloci spesso, suite completa una volta), Addy `/ship` (fan-out parallelo) | Controlli bloccanti in ordine di costo, verifica una sola volta in fondo, formato PR unificato. Il `pr` di Matt cita [Dex Horthy, HumanLayer](https://github.com/humanlayer/skills) |
| `release` | Addy `shipping-and-launch` | Da checklist generale a procedura con go/no-go umano, che usa il meccanismo della repo |
| `setup` | Matt `setup-matt-pocock-skills`, Addy `constraint-driven-development` | Aggiunti rischio, dati sensibili e ricetta di verifica provata |
| `ask` | Matt `ask-matt` | Stessa idea: riscritta sul flusso di questa repo; guarda anche lo stato della repo |

## Nuove

| Elemento | Spunti |
|---|---|
| `verify` | pstack `principle-prove-it-works`; Simon Willison, [Agentic manual testing](https://simonwillison.net/guides/agentic-engineering-patterns/agentic-manual-testing/) |
| `risk` | Scala di certezza da pstack `blast-radius`; [Cortex, risk-based code review](https://www.cortex.io/post/risk-based-code-review) |
| `explain` | Simon Willison, [Linear walkthroughs](https://simonwillison.net/guides/agentic-engineering-patterns/linear-walkthroughs/) e [Interactive explanations](https://simonwillison.net/guides/agentic-engineering-patterns/interactive-explanations/); pstack `how` |
| `ui` | Anthropic [`frontend-design`](https://github.com/anthropics/skills/tree/main/skills/frontend-design) (Apache-2.0), solo come spunto; Matt `prototype`; [Emil Kowalski](https://github.com/emilkowalski/skills) (MIT), riferimento opzionale non incluso |
| `agents/reviewer.md`, `agents/verifier.md` | Simon Willison, [Subagents](https://simonwillison.net/guides/agentic-engineering-patterns/subagents/) |
| `scripts/` | Nessuna fonte |

## Testi di licenza

```text
MIT License

Copyright (c) 2026 Matt Pocock
Copyright (c) 2025 Addy Osmani
Copyright (c) 2026 Lauren Tan
Copyright (c) 2025 Vercel Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
