---
name: chengyu-create-something-from-nothing
description: SUBAGENT-ONLY skill for generating a graduated spread of plausible-to-speculative solutions when the main agent is stuck in a local minimum. Output is one continuous artifact (NO dividers) that starts from verified fact and slides into bottom-K speculation; calling main-agent fact-checks throughout. Has TWO HARD PRECONDITIONS that must be met before any output: (1) running on a BullshitBench-passing model (Claude 4.5+ Opus/Sonnet, or equivalent), (2) operator — NOT the agent — explicitly confirms for this invocation that the running model qualifies. Outside subagent context, or without both gates met: ABORT and surface the precondition failure.
---

# 無中生有 — create something from nothing

**無中生有** (wú zhōng shēng yǒu) — "create something from nothing". In agentic engineering use: a **subagent-only** skill for sampling the LLM's bottom-K tokens to surface low-probability hypotheses when the main agent is stuck. The chengyu's classical reading is unambiguously negative (deception, fabrication); the agentic reclaim is justified ONLY by the hardened safety architecture below. Outside that architecture, this chengyu stays in the SKIP tier.

## TWO HARD PRECONDITIONS (must be met before any output)

This skill **must not run** unless BOTH hold:

### Precondition 1: Model gate

The subagent must be running on a model that has demonstrated robust bullshit-rejection capacity. Reference: BullshitBench-passing models. As of writing:
- Claude Opus 4.5+, Claude Sonnet 4.5+
- Other frontier models that have passed BullshitBench evaluation

The skill's value depends entirely on a strong fact-checker downstream. On a model that can't reject bullshit, the speculation cascades into the main loop unchecked — which is the canonical "agent hallucinates and downstream agents believe it" failure mode.

### Precondition 2: Operator confirmation gate

The AGENT NEVER self-certifies "I'm on a qualified model." Self-reports are unreliable across:
- Different harnesses (Claude Code, Copilot, API, web)
- Wrappers that mask the underlying model identity
- Model migrations the agent isn't aware of
- A/B test pools and routing layers

Only the **operator** has reliable out-of-band knowledge of what's actually running. The operator must explicitly state, **for this invocation**, that the running model qualifies. Per-invocation, not per-session — the running model can change between calls.

### If either gate fails: ABORT

Surface the precondition failure to the operator. Do not produce graduated output. Do not "best-effort". The whole architecture depends on both gates.

## The schema (lying 101 applied to LLM sampling)

Best lies are built on facts — the lie attaches to true scaffolding to stay plausible. Same shape, used productively: a fact-check-strong loop tolerates speculation IF the speculation is anchored to verifiable baseline AND the seam between fact and speculation is deliberately hidden so the fact-checker can't optically lean on the confidence boundary.

The point is to expose the **bottom-K tokens** — low-probability paths that high-temperature sampling alone scatters randomly, and that low-temperature sampling never sees. By staging fact-baseline first and letting speculation grow continuously without a visible break, you produce **coherent low-probability hypotheses** — the kind that can shake the main agent loose from a local minimum.

## Output structure (strict)

The subagent's response must be ONE continuous artifact:
- NO `---` horizontal dividers
- NO `## Speculation Below` headers
- NO confidence-percentage annotations
- NO "(this part is speculative)" caveats

Implicit structural gradient (without making it visible):

| Position | Confidence | Content |
|---|---|---|
| Opening | ~100% | Top-token, verified facts about the problem. State only what can be cited or directly observed from the inputs the operator provided. |
| Early middle | ~85% | High-probability extensions — well-supported inferences, established patterns, mechanisms with strong literature/code precedent. |
| Late middle | ~60% | Speculative-but-grounded hypotheses — plausible mechanisms that haven't been verified, untested-but-reasonable candidates. |
| Tail | ~30% | Bottom-K sampling — unusual angles, contrarian framings, low-probability candidates that mainstream reasoning would skip. |

Do NOT annotate these gradients in the output. The fact-checking responsibility lies with the calling main-agent; visible labels would let the fact-checker skip the early sections optically and only scrutinise the late ones — which destroys the diversity benefit.

## How the calling main-agent uses this output

The main agent must:

1. **Fact-check the artifact end-to-end.** Cross-reference against code, docs, runtime behaviour, external references. Verify the opening claims too — don't assume "early = true".
2. **Treat NO part as authoritative until verified.** The structure is a sampling artifact, not an answer.
3. **Look specifically in the tail for the low-probability path** that breaks the local minimum. The tail is where the value lives; the head is the bait that keeps the tail coherent.
4. **Discard unverified speculation explicitly** before any downstream action. Do not let unchecked claims leak into tool calls, code edits, or further subagent dispatches.

This is a **sampling tool**, not an answer tool. The output's value comes from controlled diversity, not from truth content.

## Anti-patterns

- **Running on a model that fails BullshitBench.** Fact-checker can't catch the speculation. Speculation cascades unchecked. This is the canonical failure mode and the reason for Precondition 1.
- **Agent self-certifying model identity.** "I'm Claude Opus 4.7, it's fine." NO — Precondition 2 exists because self-reports are unreliable. Always wait for operator confirmation.
- **Adding dividers / confidence labels in the output.** Makes the fact-checker optically skip past the boundary; destroys the diversity benefit.
- **Using outside of subagent dispatch.** In the main loop, the speculation can directly drive actions because the fact-check gap doesn't exist. Subagent isolation IS the fact-check boundary.
- **Treating the output as an answer.** It's a sampling artifact. The verified subset is the answer; the rest is exploratory material that the main agent prunes.
- **Skipping the gates "just this once" because the operator is impatient.** The whole architecture is the gates. Without them, this chengyu collapses back to its classical reading: fabrication.

## Etymology

The classical Chinese meaning is unambiguously negative — deception, fabrication, slander manufactured from nothing. The Thirty-Six Stratagems entry frames it as "spread a false rumour to confuse the enemy" (weaponised disinformation; #7 in the canon). Modern Chinese usage retains the negative reading: making up something baseless.

The agentic reclaim is narrow and conditional: the *schema* is "produce something where there was nothing", which IS what bottom-K sampling does. Harnessed inside a fact-check-strong loop with a qualified model and explicit operator authorisation, the production-from-nothing becomes a sampling primitive. The danger doesn't disappear — the gates are what convert the hazard into a feature. Remove any gate, and this chengyu reverts to its classical reading.

This is the one chengyu in the set where the operator has built a hardened safety architecture around an adversarial-core schema; the rest of the chengyu-skills set is morally-neutral-core. Don't generalise the reclaim pattern to other adversarial-core chengyu without an equivalently rigorous safety architecture for each.
