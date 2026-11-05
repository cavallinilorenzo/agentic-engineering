# Agentic Engineering

Il mio set di skill e subagenti per sviluppare software da ingegnere usando agenti di coding.

Sono parole brevi da digitare in Claude Code. Ogni parola dice in che fase del lavoro sei, l'agente fa il resto, e nessun lavoro si dichiara finito senza una prova.

```
Nebbia totale   /fog ───┐
So poco         /grill ─┴→ /spec → /plan → /build → /ship → /explain → merge
So già cosa voglio         /spec ↗         /swarm     ↑
                                           /fix       └ lancia /verify e /judge
                                           /ui
```

Non sai cosa fare adesso? Digita **`/ask`**: guarda lo stato della repo e ti dice il prossimo comando.

> [!NOTE]
> Questa è la prima versione. Le skill non sono ancora state collaudate su un lavoro vero: il primo pilota è previsto su una repo reale. Vedi [Cosa resta da collaudare](#cosa-resta-da-collaudare).

## Indice

- [I principi](#i-principi)
- [Installazione](#installazione)
- [Tutti i comandi](#tutti-i-comandi)
- [Cosa fare in ogni situazione](#cosa-fare-in-ogni-situazione)
- [Il flusso, fase per fase](#il-flusso-fase-per-fase)
- [Livelli di rischio](#livelli-di-rischio)
- [La ricevuta di verifica](#la-ricevuta-di-verifica)
- [Standard delle pull request](#standard-delle-pull-request)
- [Branch, worktree e pulizia](#branch-worktree-e-pulizia)
- [Skill, sessioni e subagenti](#skill-sessioni-e-subagenti)
- [Modelli e costi](#modelli-e-costi)
- [Interfacce](#interfacce)
- [Com'è fatta la repo](#comè-fatta-la-repo)
- [Cosa resta da collaudare](#cosa-resta-da-collaudare)

## I principi

1. **Il limite non è scrivere codice, è sapere che funziona.** Per questo ogni lavoro passa da una prova reale.
2. **Il rigore segue il rischio.** Le regole sono le stesse ovunque, ma una correzione di testo non riceve lo stesso trattamento di una migrazione del database.
3. **Pochi comandi da ricordare.** Nel quotidiano bastano 3-4 parole. Verifica e review partono da sole.
4. **Agenti fino a dove riesci a controllarli.** Più agenti non servono a nulla se poi non puoi capire cosa hanno fatto.
5. **Le decisioni sono tue, i fatti li cerca l'agente.**

## Installazione

### 1. Installa

```bash
npx agentic-engineering@latest
```

Copia le skill in `~/.claude/skills/` e gli agenti in `~/.claude/agents/`. Non serve clonare la repo. Per vedere prima cosa cambierebbe, senza toccare nulla:

```bash
npx agentic-engineering@latest --dry-run
```

Se un nome è già occupato, il vecchio elemento viene spostato in `~/.claude/backups/agentic-engineering-<data>/`. Le skill restano `/spec`, `/plan`, ecc., senza prefisso di plugin.

Prima della pubblicazione su npm, o per provare un branch, si può usare direttamente GitHub:

```bash
npx github:cavallinilorenzo/agentic-engineering
```

### 2. Togli le skill sostituite (facoltativo)

```bash
npx agentic-engineering@latest --retire
```

Sposta nel backup le vecchie skill che questo set sostituisce, come `wayfinder`, `to-spec`, `implement`, `pr`, `code-review` e `impeccable`, insieme ai relativi agenti. L'elenco esatto è in cima a `bin/cli.mjs`.

Queste cose vanno fatte a mano:

- **Hook di Impeccable:** se li avevi, togli le voci che la nominano da `SessionStart`, `PostToolUse` e `Stop` in `~/.claude/settings.json`.
- **OpenCode:** legge sia `~/.claude/skills` sia `~/.agents/skills`. Se tieni copie vecchie in `~/.agents/skills`, toglile, altrimenti avrai nomi doppi.

### 3. Attiva la pulizia automatica dei worktree

L'installazione copia lo script in `~/.claude/agentic-engineering/clean-worktrees.sh`. Aggiungi a `~/.claude/settings.json`, con il tuo nome utente:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/TUO_UTENTE/.claude/agentic-engineering/clean-worktrees.sh --all /Users/TUO_UTENTE/Developer",
            "async": true
          }
        ]
      }
    ]
  }
}
```

Dettagli in [Branch, worktree e pulizia](#branch-worktree-e-pulizia).

### 4. Prepara ogni repo

Dentro ogni repo in cui vuoi lavorare, una volta sola:

```
/setup
```

### Aggiornare e disinstallare

```bash
npx agentic-engineering@latest             # aggiorna: riesegue l'installazione
npx agentic-engineering@latest uninstall   # toglie solo ciò che aveva messo lui
```

L'aggiornamento sovrascrive le copie installate da lui, quindi le modifiche a mano a quelle skill vanno perse. Per modificarle, lavora sulla repo.

### Per chi sviluppa le skill

Clonando la repo, `./scripts/install.sh --apply` crea symlink invece di copie, così le modifiche si vedono subito. Non mescolare i due metodi sullo stesso `~/.claude`.

### Opzionale

Per le animazioni, `/ui` usa la skill di Emil Kowalski se la trova:

```bash
npx skills add emilkowalski/skills --skill emil-design-eng
```

## Tutti i comandi

| Fase | Comando | Quando lo usi |
|---|---|---|
| **Define** | `/fog` | Nebbia totale: lavoro troppo grande o confuso per una sessione |
| | `/grill` | Sai poco: un'intervista lo chiarisce |
| | `/spec` | Sai cosa vuoi: fissa cosa e perché |
| **Plan** | `/plan` | Decide come, in che ordine e con quale rischio |
| **Build** | `/build` | Un ticket, test-first, in un worktree |
| | `/swarm` | Tutti i ticket di una spec, in ordine di dipendenza |
| | `/fix` | Qualcosa è rotto o lento |
| | `/ui` | Una schermata, un redesign o una rifinitura |
| **Verify** | `/verify` | Prova che funziona. Parte da sola dopo `/build` e `/fix` |
| **Review** | `/judge` | Giudizio indipendente. Parte da sola dentro `/ship` |
| | `/explain` | Ti fa capire una PR, tua o di altri |
| **Ship** | `/ship` | Controlla tutto e apre la PR |
| | `/release` | Consegna una versione alle persone |
| **Repo** | `/setup` | Prepara una repo, una volta sola |
| **Manutenzione** | `/triage` | Sono arrivate issue che non hai scritto tu |
| | `/arch` | Hai un momento libero per migliorare i moduli |
| | `/retro` | Una sessione è andata male: migliora l'ambiente |
| **Contesto** | `/handoff` | Il lavoro passa a un altro strumento, cartella o persona |
| **Aiuto** | `/ask` | Non sai cosa viene dopo |

Queste le richiamano gli altri comandi. Puoi digitarle, ma di solito non serve:

| Skill | Cosa fa | Chi la usa |
|---|---|---|
| `tdd` | Ciclo test rosso → verde alle giunture concordate | `/build`, `/swarm` |
| `risk` | Livelli di rischio e scala di certezza | `/plan`, `/verify`, `/judge`, `/explain` |
| `research` | Un agente in background cerca fatti su fonti primarie e li salva con citazioni | `/plan`, `/fog` |
| `prototype` | Codice usa e getta per rispondere a una domanda di logica o di aspetto | `/plan`, `/fog`, `/ui` |
| `domain-modeling` | Tiene aggiornati glossario e ADR | `/plan`, `/fog`, `/arch` |
| `codebase-design` | Vocabolario per progettare moduli profondi | `/plan`, `/arch`, `tdd` |
| `writing-for-agents` | Regole per scrivere documenti per agenti | `/retro`, e chi modifica queste skill |

## Cosa fare in ogni situazione

### Iniziare un lavoro

| Situazione | Cosa fai |
|---|---|
| Repo mai preparata | `/setup` |
| Ho un'idea ma non so nemmeno se ha senso | `/fog` se è enorme, altrimenti `/grill` |
| So cosa voglio, ma è una feature con più parti | `/spec` → `/plan` → `/build` per ogni ticket |
| So esattamente cosa fare ed è piccolo | `/build` e descrivi il lavoro |
| Cambio una riga di testo o documentazione | `/build`: il rischio è basso e i controlli sono minimi |
| Non so se una cosa è tecnicamente fattibile | Durante `/plan` parte `research`, oppure chiedilo tu |
| Non so come dovrebbe sembrare o comportarsi | Durante `/plan` parte `prototype`, oppure chiedilo tu |
| Ho già una issue pronta | `/build #123`, oppure `/plan #123` se serve un piano |

### Costruire

| Situazione | Cosa fai |
|---|---|
| Un ticket alla volta | Una sessione nuova per ticket: `/build #123`, poi `/ship` |
| Più ticket con parti in comune | Uno alla volta, nell'ordine delle dipendenze |
| Tutti i ticket della spec in un colpo, anche con dipendenze | `/swarm #spec` |
| Voglio lanciare più agenti a mano | Una sessione per ticket: ognuno crea il proprio worktree |
| Due ticket toccherebbero gli stessi file | Non in parallelo: mettine uno come bloccante dell'altro |
| Il lavoro cresce oltre una PR rivedibile | `/build` si ferma e propone di spezzarlo |
| Grande rinomina o refactor su tutta la codebase | `/plan`: lo sequenzia in espansione, migrazione a blocchi e contrazione |

### Correggere

| Situazione | Cosa fai |
|---|---|
| Un bug qualsiasi | `/fix` e descrivi il sintomo |
| Bug che compare a volte | `/fix`: alza la frequenza di riproduzione finché diventa analizzabile |
| Non si riesce a riprodurre | `/fix` si ferma e ti chiede accesso o dati redatti, senza tirare a indovinare |
| Regressione di performance | `/fix`: prima misura, poi corregge |
| Emergenza in produzione | `/fix` su un branch `fix/...`, poi `/ship`, poi `/release` con piano di rollback |
| La verifica fallisce dopo `/build` | L'agente corregge e riverifica; la PR non si apre finché non passa |

### Interfacce

| Situazione | Cosa fai |
|---|---|
| Schermata nuova | `/ui`: ti chiede 1-3 riferimenti reali, scrive la direzione, costruisce e guarda il risultato |
| Più direzioni possibili | `/ui` crea varianti con `prototype` e scegli guardandole |
| Rifinire qualcosa che c'è già | `/ui` e indica la schermata |
| Repo senza `DESIGN.md` | `/ui` lo ricava dal codice e lo scrive |
| App macOS o SwiftUI | `/ui`: l'audit usa le linee guida Apple invece di quelle web |

### Aprire e capire una PR

| Situazione | Cosa fai |
|---|---|
| Lavoro finito | `/ship`, poi `/explain` in una sessione pulita |
| Non ho letto il diff della mia PR | `/explain`: è il controllo pensato per questo |
| PR di un'altra persona | `/explain 123`: spiegazione e bozza di review, che pubblichi solo tu |
| PR a rischio alto | `/explain` ti indica fino a 3 punti critici da leggere con lui |
| La ricevuta è di un commit vecchio | `/ship` la rifiuta e rilancia la verifica; `/explain` la segnala come scaduta |
| PR con più temi insieme | `/ship` la blocca: i temi estranei vanno su un altro branch |
| Commenti di review da sistemare | Riapri la sessione sul branch, correggi, `/ship` riverifica |
| CI rossa dopo l'apertura | Correggi sul branch; ogni commit nuovo invalida la ricevuta |
| Voglio solo un parere su un branch | `/judge` |

### Dopo il merge

| Situazione | Cosa fai |
|---|---|
| PR mergiata | Niente: alla prossima sessione il worktree e il branch locale spariscono |
| Voglio pulire subito | `./scripts/clean-worktrees.sh` nella repo |
| Voglio vedere cosa verrebbe tolto | `./scripts/clean-worktrees.sh --dry-run --all ~/Developer` |
| Un worktree non viene rimosso | Guarda il log: `~/.local/state/agentic-engineering/clean-worktrees.log` |
| PR chiusa senza merge | Il worktree resta: decidi tu |
| Rilasciare una versione | `/release`: go/no-go, piano di rollback, e parte solo col tuo via libera |

### Contesto, limiti e manutenzione

| Situazione | Cosa fai |
|---|---|
| Fine di una fase: continuo o pulisco? | `/ask`, che usa le regole di `PHASE-BOUNDARIES.md` |
| La sessione è lunga, lavoro non finito | `/compact` a un confine di fase |
| Lavoro finito, passo a uno non collegato | `/clear` |
| Ho finito i limiti del piano Claude | `/handoff`, poi riparti con OpenCode Go, solo su repo non sensibili |
| Passo il lavoro a un collega | `/handoff` |
| Sono arrivate issue e segnalazioni | `/triage`, poi `/build` su quelle pronte |
| L'agente ha fatto un errore prevedibile | `/retro`: un errore meccanico diventa un controllo automatico, uno di giudizio diventa una regola |
| Ho tempo libero per la qualità | `/arch`: propone i moduli da approfondire e partite da `/grill` |
| Repo con dati di clienti | In `/setup` segnala `sensitive: yes`: niente modelli di altri provider |
| Una skill non fa ciò che dovrebbe | `/retro`, poi modifica la skill in questa repo |

## Il flusso, fase per fase

### 1. Define: cosa e perché

Scegli in base a quanto sai già:

- **`/fog`** è per il lavoro troppo grande per una sessione. Crea sul tracker una **mappa** di ticket di decisione e ne risolve uno per sessione, finché la strada è chiara. Produce decisioni, non codice. Alcuni ticket li risolve con `research` o `prototype`, altri con un'intervista. Alla fine si passa a `/spec`.
- **`/grill`** è un'intervista a round: per ogni domanda ti dà una raccomandazione, e tu rispondi solo dove non sei d'accordo. I fatti li cerca l'agente, le decisioni restano tue.
- **`/spec`** riassume la conversazione in una issue: problema, soluzione, user story, **criteri di accettazione** verificabili dall'esterno, fuori scope. Non contiene come costruirlo.

Puoi saltare questa fase quando il lavoro è piccolo e chiaro.

### 2. Plan: come e in che ordine

**`/plan`** non scrive codice. Fissa le decisioni su dati, moduli e giunture, assegna il rischio, ordina le dipendenze e divide il lavoro in **fette verticali**: ogni fetta è un percorso completo e dimostrabile da sola, grande quanto una sessione e una PR. Poi ti mostra tutto e aspetta la tua approvazione.

Con una sola fetta il piano è un commento sulla issue. Con più fette crea un ticket per ciascuna, con i blocchi nativi del tracker.

### 3. Build: costruire

- **`/build`** lavora su un ticket: crea il worktree, scrive prima il test, implementa, committa e lancia il `verifier`.
- **`/swarm`** esegue tutti i ticket della spec seguendo i blocchi: gli indipendenti in parallelo, gli altri appena sbloccati. Un subagente per ticket, ognuno nel suo worktree, verso un unico branch di integrazione e una sola PR.
- **`/fix`** prima crea un comando che "va rosso" su quel bug, poi minimizza, formula ipotesi, trova la causa radice, scrive il test di regressione e verifica.
- **`/ui`** costruisce con un ciclo visivo a budget ([dettagli](#interfacce)).

### 4. Verify: la prova

**`/verify`** parte da sola. Esegue i comandi della repo sul commit esatto, usa davvero la funzione e scrive la [ricevuta](#la-ricevuta-di-verifica). Se qualcosa non va, la ricevuta non viene scritta come valida.

### 5. Review: giudizio e comprensione

Sono due cose diverse:

- **`/judge`** dà un giudizio indipendente, con agenti che non hanno scritto il codice. Controlla gli standard, la spec e, a rischio alto, il blast radius. Parte da solo dentro `/ship`.
- **`/explain`** fa capire a te. È il controllo che sostituisce la lettura dell'intero diff: ogni affermazione è legata a un `file:riga` o a un comando eseguito, e dice cosa non è verificato.

**Il limite:** un agente può spiegare benissimo una cosa sbagliata. Per questo, a rischio alto, ti chiede di leggere fino a 3 punti critici.

### 6. Ship: consegnare

- **`/ship`** controlla branch, tema unico, dimensione, ricevuta e review, poi apre la PR nel [formato standard](#standard-delle-pull-request). Il merge lo fai tu.
- **`/release`** consegna una versione: elenca le modifiche, controlla che sia pronta, scrive il piano di rollback e parte solo col tuo via libera.

## Livelli di rischio

Il rischio dipende da cosa tocca la modifica e da quanto è reversibile, non da quante righe cambia. Vince il livello più alto. Nel dubbio è **alto**.

| Livello | Esempi | Verifica | Review |
|---|---|---|---|
| **Basso** | Doc, testi, test, stile senza logica | Comandi e ricevuta breve | Solo CI |
| **Medio** | Logica di prodotto, UI con stato, dipendenze | + comportamento reale | `/judge` (standard + spec) e `/explain` |
| **Alto** | Soldi, dati di clienti o personali, migrazioni, auth, segreti, CI/release, API pubbliche, cancellazioni, porte a una via | + prova nell'app sul percorso critico | `/judge` con blast radius e `/explain` con punti critici |

- Ogni repo ha un **minimo** in `docs/agents/engineering.md`. Per le repo di clienti il minimo è medio.
- L'agente può alzare il livello, solo tu puoi abbassarlo.
- Una **porta a una via** non si può annullare a basso costo: migrazione distruttiva, versione pubblicata, messaggio inviato.

### Scala di certezza

Per ogni affermazione sul fatto che qualcosa funziona, o è sicuro:

1. **Detto:** l'ho affermato. Da solo non vale nulla.
2. **Indicato:** c'è un `file:riga` vero.
3. **Tracciato:** ho seguito il caso negativo e non può accadere.
4. **Eseguito:** uno script o un test sul codice reale.
5. **Riprodotto:** l'ho visto nell'app in esecuzione.

Rischio medio richiede il livello 4 sul comportamento cambiato, rischio alto il 5 sul percorso critico. Ciò che resta sotto finisce in **Non verificato**.

## La ricevuta di verifica

Sta fuori dal diff, in `$(git rev-parse --git-path verification-receipt.md)`, ed è legata a un commit:

```markdown
Commit: 3f2a9c1e...
Risk: medium (cambia il calcolo del totale)

## Commands
- `npm test`: exit 0, 538 passati

## Behaviour
- Il totale si aggiorna: provato nel browser su dati finti (certezza 5)

## Not verified
- Export PDF: non toccato e non provato

## Screenshots
- desktop: /percorso/desktop.png
```

**La ricevuta scade a ogni commit.** `/ship` la accetta solo se `Commit:` coincide con `HEAD`, così una verifica vecchia non può coprire codice nuovo.

## Standard delle pull request

**Titolo:** Conventional Commits in inglese, massimo 72 caratteri, ad esempio `feat(budget): keep limits from the current month onward`. I termini di dominio restano nella lingua del glossario.

**Branch:** `tipo/argomento`, con tipo `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf` o `ci`.

**Regole:** un solo tema per PR, nessun limite di righe, `Closes #n` quando il lavoro nasce da una issue.

**Corpo:**

```markdown
Closes #123

## Why
Il problema e l'approccio, in 1-3 frasi.

## What changed
1-3 punti, con un piccolo diagramma se aiuta.

## Scope
Cosa include e cosa lascia fuori.

## Risk
**Level:** medium (motivo)
**Door:** two-way
**Blast radius:** chi o cosa tocca, e perché è sicuro o rischioso.

## Verification
**Commit:** `sha completo`
- `comando`: esito
- criterio: comportamento osservato (certezza 4)

**Not verified:** elenco, o None

## Screenshots
Prima e dopo, solo se cambia la UI.
```

**Screenshot:** GitHub non ha un'API pubblica per allegare immagini, quindi `/ship` le carica in una prerelease con tag `pr-assets-<numero>`, che non attiva i workflow legati ai tag `v*`. Mostrano **sempre e solo dati finti**: in una repo pubblica un'immagine espone dati quanto il codice.

Un'immagine costa circa 1.500-2.700 token solo quando il modello la apre. Salvarla e allegarla è gratis.

## Branch, worktree e pulizia

Sono due cose diverse e servono entrambe:

- Il **branch** è una linea di storia.
- Il **worktree** è la cartella in cui quel branch è aperto.

Una cartella tiene aperto un solo branch alla volta. Con due agenti nella stessa cartella, il secondo cambierebbe i file sotto i piedi del primo. Dato che lancio spesso più agenti insieme, **ogni implementazione lavora nel suo worktree**, in `.claude/worktrees/<argomento>`.

Costo: ogni worktree è una cartella nuova, da preparare con dipendenze e `.env`. La riga `setup` di `docs/agents/engineering.md` dice all'agente come farlo. In un progetto Rust anche la compilazione riparte da zero.

### Pulizia automatica

`scripts/clean-worktrees.sh` parte in background a ogni avvio di sessione ([come attivarlo](#5-attiva-la-pulizia-automatica-dei-worktree)) e controlla tutte le repo della cartella indicata. Rimuove il worktree e il branch locale solo se **tutte** queste condizioni sono vere:

| Controllo | Perché |
|---|---|
| Sta in `.claude/worktrees/` | Non tocca worktree creati altrove a mano |
| La sua PR è mergiata **a quel commit esatto** | Un commit fatto dopo il merge non va perso |
| Nessuna modifica, nemmeno file non tracciati | Il lavoro non committato resta |
| Non è bloccato (`git worktree lock`) | Rispetta un blocco esplicito |
| Nessun processo ci sta lavorando dentro | Non cancella la cartella sotto un agente attivo |

**Nel dubbio resta.** Se GitHub non risponde, se la PR è solo chiusa o se manca `gh`, il worktree non si tocca. I file ignorati, come `node_modules`, non bloccano la rimozione.

I worktree di review `pr-<numero>`, creati da `/explain`, spariscono quando la PR è mergiata o chiusa, a meno che contengano commit estranei alla PR.

Attiva anche su GitHub la cancellazione del branch remoto al merge. `/setup` lo propone.

## Skill, sessioni e subagenti

| | Cos'è | Contesto | Va bene per |
|---|---|---|---|
| **Skill** | Istruzioni caricate dove lavori | Il thread corrente | Un metodo da seguire |
| **Nuova sessione** | Tu con un agente pulito | Vuoto, ma puoi conversare | Un ticket |
| **Subagente** | Un altro lavoratore con un compito preciso | Vuoto, ti torna solo il risultato | Lavoro laterale |

Non sono alternative: un subagente può caricare una skill. **Per un ticket, la scelta normale è una nuova sessione con `/build`.**

Usa un subagente in quattro casi:

1. Il lavoro riempirebbe il contesto principale: ricerche, log, test verbosi.
2. Vuoi un giudizio indipendente da chi ha scritto il codice.
3. Hai compiti davvero indipendenti da eseguire in parallelo.
4. Vuoi limitare i permessi, ad esempio sola lettura.

Resta nella sessione principale quando serve botta e risposta, i passi sono sequenziali o la modifica è piccola. I subagenti non fanno risparmiare token in totale, proteggono solo il contesto principale, e consumano gli stessi limiti del piano.

Questa repo definisce due soli agenti:

- **`reviewer`:** legge un diff su un solo asse, senza modificare nulla. Lo lancia `/judge`.
- **`verifier`:** esegue `/verify` e ti restituisce solo l'esito, tenendo log e screenshot fuori dalla conversazione. Lo lanciano `/build`, `/fix`, `/swarm` e `/ship`.

## Modelli e costi

| Lavoro | Modello | Perché |
|---|---|---|
| `/fog`, `/plan`, `/judge` a rischio alto, direzione in `/ui` | Opus 5.5 | Qui un errore costa di più |
| `/build`, `/fix`, `/ship`, `reviewer`, `verifier` | Sonnet 5.5 | Regge la maggior parte del lavoro e costa meno |
| Compiti semplici e ripetitivi | Haiku 5.5 | Il più economico |
| Secondo parere e lavori a basso rischio, su repo non sensibili | OpenCode Go | Un modello diverso trova errori diversi |

- Si cambia con `/model` a seconda della fase.
- **Repo sensibili** (dati di clienti, finanziari, personali): restano sui modelli Claude. In `engineering.md` si scrive `sensitive: yes`.
- Il secondo parere si attiva con la riga `second_opinion` di `engineering.md`.
- Le abitudini che fanno risparmiare di più: una sessione per ticket, `/clear` tra lavori non collegati, poche sessioni in parallelo.

## Interfacce

**Nessuna skill garantisce una UI bellissima.** Il risultato dipende molto dalla direzione e dai riferimenti che scegli. `/ui` serve a farti arrivarci spendendo poco:

1. **Base:** legge `DESIGN.md` e riusa token e componenti esistenti.
2. **Riferimenti:** ti chiede 1-3 esempi reali che ti piacciono.
3. **Direzione:** un brief sotto le 150 parole, con scelte che nascono dal soggetto, non da default generici.
4. **Costruzione:** Opus decide e giudica, un subagente Sonnet implementa, inclusi stati vuoti, di caricamento e di errore.
5. **Ciclo visivo:** screenshot desktop e mobile con Playwright CLI su dati finti, **massimo 3 giri per schermata**, poi si ferma e ti chiede.
6. **Audit:** le [Web Interface Guidelines di Vercel](https://github.com/vercel-labs/web-interface-guidelines) in un subagente, solo sui file toccati. Per SwiftUI, le linee guida Apple.
7. **Animazioni:** la skill di Emil Kowalski, solo quando servono.

Le immagini costano circa 3-5k token a giro, cioè 10-16k per schermata: è una stima da misurare. Il risparmio maggiore viene dal non rifare il lavoro per un brief vago.

## Com'è fatta la repo

```
skills/<nome>/SKILL.md    una cartella per skill
agents/                   reviewer e verifier
bin/cli.mjs               installer per npx (copia in ~/.claude)
scripts/install.sh        installer a symlink, per chi sviluppa
scripts/clean-worktrees.sh  pulizia dei worktree al merge
tests/                    controlli su skill, installazione e pulizia
NOTICE.md                 origine e licenza di ogni skill
```

**Da dove viene ogni skill:** [NOTICE.md](NOTICE.md) dichiara per ognuna se è copiata, rielaborata o nuova, con commit e licenza.

In breve: la base è [Matt Pocock](https://github.com/mattpocock/skills), il ciclo a sei fasi viene da [Addy Osmani](https://github.com/addyosmani/agent-skills), alcune idee da [pstack](https://github.com/cursor/plugins/tree/main/pstack), le linee guida UI da [Vercel](https://github.com/vercel-labs/web-interface-guidelines).

**Modificare le skill:** esegui `bash tests/run.sh` prima di ogni commit. Controlla nomi, riferimenti incrociati, citazioni e i casi pericolosi della pulizia.

**Aggiornare dalle fonti:** confronta la fonte col commit in `NOTICE.md`, porta qui ciò che serve e aggiorna il commit. Non c'è sincronizzazione automatica, per scelta.

## Cosa resta da collaudare

Le parti deterministiche hanno test: installazione, pulizia dei worktree, struttura delle skill. Il resto va provato su un lavoro vero:

| Da collaudare | Rischio |
|---|---|
| Il flusso completo, da `/spec` a `/explain` | Mai eseguito end-to-end |
| `/plan` e `/verify` che sostituiscono i comandi omonimi di Claude Code | Documentato per il terminale locale, non per altre superfici |
| Caricamento degli screenshot in prerelease | Comandi non ancora eseguiti su una PR reale |
| Il budget di `/ui` | I token sono una stima |
| `second_opinion` con OpenCode Go | Il comando esatto va definito |
| Subagenti su OpenCode | Le skill funzionano, ma `reviewer` e `verifier` usano il formato di Claude Code |
