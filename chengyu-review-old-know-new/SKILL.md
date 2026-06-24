---
name: chengyu-review-old-know-new
description: Use when bringing forward priors from PAST sessions / cross-agent history before doing new work — NOT about re-reading the current context window (which is trivially in-context). Specifically triggered when auto-compact is lossy, when cross-session reference is needed, when the same topic has been treated before, or when the original work was done in a different agent's session. The discipline is targeted historical retrieval via grep + read of session JSONLs, then promotion to memory if the prior deserves persistence.
---

# 溫故知新 — review the old to know the new

**溫故知新** (wēn gù zhī xīn) — "review the old to know the new". Re-read past sessions / JSONLs / memory to bring forward priors before doing fresh work. The current context window is trivially "old"; this chengyu is about the history that is *not* currently in context — past sessions, other agents.

## Critical disambiguation

This skill does NOT mean "re-read the conversation so far" — that's trivially available. It means:

- Re-read past JSONLs (other sessions) for prior treatments of the current topic
- Cross-reference what other agent-sessions concluded
- Recover information that auto-compact has dropped from your current context
- Find empirical answers to "have we done this before?" by greping the archive, not by guessing

The distinction is load-bearing. Users have been burned by agents who say "let me review what we discussed" and then just re-read the last 3 turns. That isn't 溫故知新.

## When this applies

Symptoms that this schema applies:

- **Auto-compact has destroyed information you suspect you covered earlier** in this session — recover it from the JSONL on disk rather than re-deriving.
- **This conversation references a topic that was deep-dived in a prior session** — find the prior treatment instead of starting over.
- **A user reference like "we decided X earlier"** — find the actual decision in past JSONLs rather than assume what X was.
- **Recurring topic** — you've discussed the same domain (e.g. a specific PR shape, a specific design tension) with this user multiple times. Find the prior treatments before re-deriving and risking inconsistency.
- **User asks "have we done this before?"** — answer empirically (grep), not from your fuzzy in-context memory.

## Behavior

1. **Identify the topic / decision / artifact** you need historical context on. Be specific: "I need to find the prior treatment of [particular API design]" beats "review my history".

2. **Grep the session archive for matching keywords across JSONL files.** Claude Code stores session history at `~/.claude/projects/<project-encoded-path>/*.jsonl`. Use multiple keyword variations; the prior might use different wording. To date/rank matches use the **first `"timestamp"` inside each file**, not file mtime — mtime lies for dating past sessions (see *Reliable retrieval mechanics* below).

3. **Read the matching sessions** (or the relevant portions). Don't re-read everything — the chengyu is about *targeted* historical retrieval, not exhaustive re-reading.

4. **State explicitly what you found**: "Per session [filename / date]: [decision/finding/treatment]". Cite the prior so the user can verify if needed.

5. **Update memory if the prior should be promoted to long-term storage** — write to your skill's memory location. A prior that resurfaces twice is a candidate for permanent memory.

## Reliable retrieval mechanics (the obvious filters both lie)

Targeted retrieval only compounds if the grep actually *runs* and the ranking is *real*. Three footguns — each silently returns a wrong answer that reads like a confident "no prior":

- **File mtime ≠ session date.** mtime drifts from OS access / unrelated tooling. Date a session by the **first `"timestamp"` in the file**: `grep -m1 '"timestamp"' f.jsonl | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}'`. (mtime is reliable *only* for "which session is being written right now".)
- **Substring count ≠ relevance.** `exam` matches inside `example`; org-listing strings and SVG refs inflate counts. Anchor with whole-word / role / cwd: `grep -cE '\bFOO\b' f.jsonl`, `grep -m1 '"cwd"' f.jsonl` (cwd is unambiguous ground truth).
- **Leading-dash paths swallow the grep.** Project dirs are path-encoded with a leading `-` (`-Users-evnchn`, `-home-evnchn`), so `grep PAT */*.jsonl` from `~/.claude/projects/` parses the paths as **option flags** and returns nothing — a false "no prior" where the search never ran. Use `grep -rl PAT .` (paths generated internally), a `./` prefix, or the `--` end-of-options guard: `grep -lE PAT -- */*.jsonl`. **Canary a known-present term** in the same sweep — zero canary hits means a broken grep, not an empty archive.

> Absence of a hit is evidence of absence *only* once the grep is proven to run (canary) and keyword synonyms are exhausted.

## Cross-node / cross-machine case (optional)

If you operate Claude Code across multiple machines (e.g. a homelab, a work laptop, a personal desktop), the same skill extends:
- If you have a synced memory layer, check that first
- Otherwise, SSH to the original machine and grep the JSONLs there
- Pull the matching JSONL back if you need to read it locally

This is an optional extension — single-machine users can ignore.

## Anti-pattern

**Re-reading the current context window and claiming "review of the old"** — the most common failure mode. The current window is trivially in-context; the chengyu is about what's NOT in-context.

**Re-deriving from scratch when a prior treatment exists.** The whole point of the chengyu is compound effort on top of prior work. Re-deriving from scratch loses the user's previously-stated preferences and forces them to re-litigate decisions.

**Treating absence-of-prior as evidence-of-absence.** You greped one keyword and got nothing. Try synonyms, related terms, fragments of the user's actual phrasing. A miss isn't proof there's no prior.

**Re-reading everything.** Don't grep 50 files when 5 will do. The chengyu is targeted retrieval, not exhaustive crawl. Exhaustive crawl loses focus and wastes context.

**Failing to write back to memory when a prior should be promoted.** Re-discovering the same prior next session means the lesson didn't stick. Promote durable findings to your memory layer (append, don't overwrite — multiple agents may write concurrently in homelab-style setups).

## Etymology

From the *Analects* (論語), Book 2:

> 子曰：「溫故而知新，可以為師矣。」
> Confucius said: "He who reviews the old to know the new is fit to be a teacher."

The classical setting is scholarly: re-reading classical texts yields fresh understanding because the reader has changed. The same text, read at age 30 vs age 50, reveals different things — not because the text changed but because the reader brings new questions.

Agentic translation: re-reading past JSONLs yields fresh insight because the current question wasn't yet being asked in those past sessions, but the priors that bear on it were laid down then. The prior is "old" (recorded then); the question is "new" (asked now); the synthesis is the value.

In any multi-session, multi-day agentic workflow with auto-compact lossiness, this discipline is the difference between "doing the same work twice" and "compounding on prior treatments." The agent that grep's the archive is the agent that becomes a teacher of itself — fit, per Confucius, to be 師.
