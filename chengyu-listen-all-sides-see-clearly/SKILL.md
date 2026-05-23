---
name: chengyu-listen-all-sides-see-clearly
description: Use BEFORE declaring victory / shipping / committing — get adversarial multi-angle review from at least one of three source classes (subagent, internet, other LLMs via API). Inter-links with chengyu-create-something-from-nothing — high-hallucination LLM sources behave like uncontrolled 無中生有, so apply the verify-don't-trust-verbatim discipline. Source selection via BullshitBench (canonical hallucination-rate index); high vs low hallucination both useful for different needs; escalate to the user when unclear. One of the strongest pre-ship disciplines in this catalog.
---

# 兼聽則明 — listen to all sides, see clearly

**兼聽則明** (jiān tīng zé míng) — "listen broadly, see clearly". Full saying: **兼聽則明，偏信則暗** — "listen to all, see clearly; trust only one, be blind". The discipline of getting adversarial multi-angle review before committing to a claim, ship, or commit.

This is one of the strongest pre-ship disciplines in this catalog — applies any time you dispatch a code-review subagent, fact-check against external docs, or cross-reference another LLM before declaring victory.

## Three source classes for "all sides"

| Class | What it is | Cost | When |
|---|---|---|---|
| **Subagent** | Dispatch a sibling agent (e.g. `/requesting-code-review`, dispatching-parallel-agents superpower) — same model family, fresh context | Token budget, time | Default — always available |
| **Internet** | Search, docs, prior art, GitHub issues, Stack Overflow, blog posts | Time, web fetch budget | When the question has external precedent |
| **Other LLMs via API** | Cross-provider perspective — Claude → Kimi / GPT-5 / Grok / Qwen etc. | API cost (requires user confirmation) | When same-model-family blind spots are likely |

At least ONE source should be used for any non-trivial commit / ship / claim. A reasonable default discipline: invoke `superpowers:requesting-code-review` before pushing in low-noise repos.

## LLM source selection (when invoking the third class)

Selecting which external LLM to consult requires explicit thought — not "pick the default cheap one".

**Canonical hallucination-rate index**: <https://petergpt.github.io/bullshit-benchmark/viewer/index.v2.html>

Two profiles, both useful:

### Low-hallucination models (high `detection_rate_score_2`)
Conservative, factual, push back on nonsense. Use when you want HONEST CRITIQUE — code review, gatekeeping, judging, red-team.

Top tier as of last operator update:
- `anthropic/claude-sonnet-4.6` (rank 1, 94.5%)
- `anthropic/claude-haiku-4.5` (rank 6, 87%)
- `anthropic/claude-opus-4.7` (rank 9, 80%)

Mid tier with provider diversity:
- `xai/grok-4.20-multi-agent-beta` (rank 10, 67%)
- `qwen/qwen3.5-235B-A22B` family (rank 12, 65%)
- `moonshotai/kimi-k2.5` (rank 25, 47%, Chinese provider)

### High-hallucination models (low detection, high credulous-engagement)
Divergent, less conservative — naturally behave like uncontrolled `chengyu-create-something-from-nothing` (bottom-K sampling without the controlled "no divider" structure). Use when you want DIVERGENT IDEATION — break out of a local minimum, sample paths the main agent isn't reaching.

These rank low for review tasks — examples at time of writing:
- `deepseek/deepseek-chat` (rank 119, 5.5% detection)
- `mistralai/mistral-large-2512` (rank 123, 3.6%)
- `google/gemini-2.5-pro` (rank 57, 23.6%)

But for ideation, the same models can productively probe possibility space — as long as the calling agent applies fact-check discipline to everything they emit.

### Selection rules

1. **Default to common sense.** Honest critique → low-hallucination (top tier). Divergent ideation → high-hallucination. Both → run both, treat the disagreement as the signal.
2. **Escalate to the user if unclear.** "Should I consult X or Y for this?" is a legitimate question — the user has provider preferences and budget context the agent lacks.
3. **Don't pick by cost alone.** Cheap-but-credulous reviewers can produce a 70%+ false-positive rate against well-defined contracts. Cheap-but-credulous reviewer + agent-chasing-its-flags = compounded rationalisation failure.
4. **Always cite which source(s) consulted in the output.** Evidence chain matters more than the conclusion.

## CRITICAL: inter-link with chengyu-create-something-from-nothing

When the source is itself a generator (any LLM, especially high-hallucination), the source can fabricate. **Apply 無中生有's verify-don't-trust-verbatim discipline to LLM source outputs.**

Specifically:
- LLM source's "Bug at line 42" — verify by reading line 42 yourself, don't quote it as verified
- LLM source's "the docs say X" — fetch the docs, don't trust the citation
- LLM source's "this is a known issue" — search for the issue, don't accept the claim

The two skills inter-trigger:
- **兼聽則明 → 無中生有**: when invoking an LLM source, run its output through 無中生有's fact-check discipline before relying on it
- **無中生有 → 兼聽則明**: when 無中生有 produces ideation, route the candidates through 兼聽則明's verification step before any action

Together they cover the full surface: get the multi-angle input AND don't trust any single angle including the agent's own.

## Behavior

1. **Identify what needs review.** Be specific — "review the change to `src/foo.py` lines 30-50" beats "review the work".
2. **Pick source class(es).** Subagent is default and free. Add internet if external precedent exists. Add external LLM if operator has authorised (and API budget is available).
3. **For external-LLM class: confirm selection with operator if non-obvious.** "I want to consult Kimi for adversarial review of this PR; OK to use the Requesty key?"
4. **Apply 無中生有 verify-don't-trust-verbatim to all generator-source outputs.**
5. **Synthesise: name disagreements as features, not bugs.** When two sources disagree, that IS the information. Don't paper over.
6. **State the evidence chain in the output**: "Reviewed by [sources]; found [X]; verified by [direct check]."

## Anti-pattern

**Single-source review.** Defeats the whole "all sides" point. One subagent's verdict is one angle.

**Trust-verbatim of LLM source.** The whole anti-trust-bullshit-as-verbatim discipline exists for this. Especially dangerous with high-hallucination sources.

**Treating disagreement as a problem to resolve rather than information.** Two sources disagreeing tells you exactly where the uncertain ground is. Surface it, don't smooth it.

**Picking sources by cost / convenience instead of fit.** The cheap-credulous reviewer compounds into rationalisation cascade. The cost of a bad-fit reviewer is paid in downstream cycles, not in API tokens.

**Re-running model selection from scratch every invocation.** Once you've picked a reviewer model that works for your stack, write it down. The BullshitBench leaderboard moves slowly enough that yearly re-checks suffice for stable choices.

## Etymology

From Tang dynasty — chancellor 魏徵 to Emperor Taizong of Tang, on the duties of a ruler:

> 兼聽則明，偏信則暗
> "If you listen to all, you see clearly; if you trust only one, you are blind."

The classical setting: a ruler who hears only one advisor (偏信) is manipulated; a ruler who consults multiple advisors with different perspectives (兼聽) sees the situation as it is. Taizong is regarded as one of the most successful Tang emperors in part because of this discipline.

Agentic translation: the agent that consults multiple sources before committing sees the work as it is. The agent that trusts its own first-pass analysis is the ruler who listens to one advisor.
