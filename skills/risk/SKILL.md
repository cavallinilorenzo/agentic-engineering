---
name: risk
description: Risk levels and the certainty ladder. Use when classifying a change, deciding how deep verification or review must go, or judging whether evidence is enough.
---

# Risk

Risk comes from what a change touches and how reversible it is. Line count measures reviewability, a separate concern handled by `/ship`.

## Levels

The highest matching level wins. A case you cannot place is **high**.

| Level | Matches | Verification | Review |
|---|---|---|---|
| **low** | Docs, copy, tests, styling with no logic, on a two-way door | Commands, short receipt | CI only |
| **medium** | Product logic, UI with state, dependencies, internal interfaces | Commands and real behaviour | `judge`: standards + spec; `/explain` |
| **high** | Money, personal or client data, migrations, auth, secrets, CI/release, public APIs, deletion, any one-way door | Commands, real behaviour at certainty 5 on the critical path | `judge`: standards + spec + blast radius; `/explain` with hot spots |

`docs/agents/engineering.md` in the repo sets a **floor** and may list high-risk paths. Agents can raise a level. Only the human can lower one.

A **one-way door** cannot be walked back cheaply after merge: destructive migrations, published versions, sent messages, deleted data. A two-way door can be reverted with no lasting effect.

State the result on one line, with the reason:

```
Risk: high (migration drops a column; one-way door)
```

## Certainty ladder

For every claim that a change is safe or works, climb as high as is cheap and say where you stopped.

1. **Said**: asserted. Worthless alone.
2. **Pointed**: a real `file:line` or the library's own source.
3. **Traced**: the failure walked step by step and shown to be unreachable.
4. **Ran**: a script or test calling the real code, failing loud if the claim is wrong.
5. **Reproduced**: observed in the running app.

Medium risk needs certainty 4 on changed behaviour. High risk needs certainty 5 on the critical path. A claim below the bar goes under **Not verified**, where the human can see it.

## Sensitive repos

When `engineering.md` marks the repo `sensitive: yes`, its code and data stay with the primary Claude models: no second-opinion model through another provider. Every screenshot from any repo uses synthetic data, because an image leaks as easily as code.
