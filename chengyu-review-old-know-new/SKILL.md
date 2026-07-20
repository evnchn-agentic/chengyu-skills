---
name: chengyu-review-old-know-new
description: Use when bringing forward priors from PAST sessions / cross-agent history before doing new work — NOT about re-reading the current context window (which is trivially in-context). Specifically triggered when auto-compact is lossy, when cross-session reference is needed, when the same topic has been treated before, when the original work was done in a different agent's session, or when you need to locate/date a past session JSONL or answer "have we done this before / what did we decide". The discipline is targeted historical retrieval via grep + read of session JSONLs (incl. the mtime/substring/leading-dash traps that make naive search silently return nothing), then promotion to memory if the prior deserves persistence.
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

2. **Grep the session archive for matching keywords across JSONL files.** Claude Code stores session history at `~/.claude/projects/<cwd-encoded>/*.jsonl` — the dir encodes the *full* working directory, so search across all of `~/.claude/projects/*/`, not just one. Use multiple keyword variations; the prior might use different wording. Date candidates by the **first `"timestamp"` inside each file, not by file mtime** (mtime drifts and lies) — see Mechanics below for why, and for the grep traps that silently return "nothing found".

3. **Read the matching sessions** (or the relevant portions). Don't re-read everything — the chengyu is about *targeted* historical retrieval, not exhaustive re-reading.

4. **State explicitly what you found**: "Per session [filename / date]: [decision/finding/treatment]". Cite the prior so the user can verify if needed.

5. **Update memory if the prior should be promoted to long-term storage** — write to your skill's memory location. A prior that resurfaces twice is a candidate for permanent memory.

## Surfacing what you found — follow supercomment shape

The output of retrieval is itself a multi-item synthesis, so **surface it in `supercomment` shape**: a glimpse TL;DR (what the prior decided / what you recovered) on top, with citations (session file + date) and the recovered detail tucked into collapsible evidence underneath. Don't paste raw JSONL excerpts at the user — that's the same unreadable blob the archive started as.

For a **whole-session** review (not just one fact), render the target session via **`rich-render` session-mode** (`session_render.py`) first: it turns the JSONL into a scrubbed, chaptered, supercomment-shaped dashboard you can read and share, instead of grepping blind. The full loop: **render (rich-render) → review (溫故知新, this skill) → surface (supercomment).** Same substrate (session JSONL), three consumers — a person reading it, the agent grepping it, the reader of your synthesis.

## Mechanics (the how)

The discipline above fails quietly if the search itself is wrong — and the failure mode is the worst one: a *false "no prior exists"* that sends you re-deriving. The traps:

**Where sessions live.** `~/.claude/projects/<cwd-encoded>/<session-uuid>.jsonl`. The dir encodes the *full* working directory (slashes → dashes), e.g. `-Users-you-myproject` — **not** one flat per-home dir. So a project's sessions are in their own dir; sweep `~/.claude/projects/*/`. The currently-live session is the most-recently-written JSONL: `ls -t ~/.claude/projects/*/*.jsonl | head -1`.

**Sibling CC homes on the same machine.** `~/.claude` is not necessarily the only home — a machine can run parallel homes (`~/.claude-b/projects`, `~/.claude-nano/projects`, …), and another agent's work may live in one of them. If a *proven-complete* `~/.claude` sweep comes up empty for a cross-agent finding, widen to the siblings (`ls -d ~/.claude*/projects`) before concluding absence. And **`~/.claude/session-status/*.md`** is a cheap breadcrumb *into* the right session — a short per-session checkpoint (state · current task · file/line or JSONL-offset anchors) that beats grepping raw JSONL when one exists; read it first.

**Two filters that look reliable but lie:**
- **mtime ≠ session date.** File mtime drifts from OS access / unrelated tooling. Date a session by its *first* in-file timestamp: `grep -m1 -oE '"timestamp":"[^"]+"' f.jsonl`. (mtime is trustworthy for exactly one thing: "which session is live right now.")
- **`grep -c keyword` ≠ relevance.** Substring matches inflate (`exam` inside `example`, listing boilerplate, SVG refs). Anchor on whole-word `\bWORD\b`, on role (`-E '"role":\s*"user"'`), or on the unambiguous `"cwd"` field.

**Two traps that return a false empty:**
- **Leading-dash paths swallow the grep.** Project dirs start with `-`; `grep PATTERN */*.jsonl` parses `-Users…` as option flags and returns nothing — which reads as "no prior" when the search never actually ran. Use `grep -rl PATTERN .`, a `./` prefix, or the `--` end-of-options guard: `grep -lE PATTERN -- */*.jsonl`. **Always canary a known-present term** in the same sweep — zero hits on the canary means your grep is broken, not the archive empty. (This is the operational backing for the "absence isn't evidence of absence" anti-pattern below.)
- **Big JSONLs are often sidechain-bloat** (90% screenshots / stream events / one giant Read). Triage by real conversation volume first: `grep -cE '"role":\s*"user"' f.jsonl` — 100+ is a real conversation, <20 a single-task agent. Read line ranges, not the whole file.

**Mining a large transcript — divide and conquer.** A multi-MB / thousands-of-lines history won't fit one agent. Dispatch parallel subagents — roughly **ceil(lines / 1000)**, each a thematic slice (decisions / findings / commands / preferences, *and why failed approaches failed*) — then merge their structured reports. A "supercharged uncompact": costly in tokens, but recovers what auto-compact discarded.

**Large archive — bounded-time, recents-first.** When the whole archive is GBs (`du -sh ~/.claude/projects` — empirically ~1.3 GB / ~2000 files on a heavy user), a blind full grep is slow and usually unnecessary. You can't grep *faster*, but you can grep *smarter*: go **newest-first** (a partial sweep then surfaces the likeliest prior first) and **bound the set**. Order robustly with `stat`+`sort` — **not** `xargs ls -t`, whose ordering silently breaks once the file list splits across `xargs` batches (it only looks right while everything fits one invocation). Paths from an absolute `find` start with `/`, so the leading-dash trap doesn't bite here:
```bash
# 50 most-recently-touched sessions, newest-first, then grep — stop when you have enough
# (macOS/BSD stat shown; Linux/GNU: stat -c '%Y %n')
find ~/.claude/projects -name '*.jsonl' -exec stat -f '%m %N' {} + \
  | sort -rn | head -50 | cut -d' ' -f2- | tr '\n' '\0' | xargs -0 grep -lI "PATTERN"
# explicit window by mtime instead:   find ... -newermt 2026-06-01 ! -newermt 2026-06-15
```
Two honesty caveats: **(1)** this orders/bounds by **file mtime** = *recently touched*, reliable for activity but **not** the session's real date — mtime clusters (empirically a recent-touch window caught ~1680 of ~2030 files), so for a precise "when it happened" window filter on the first in-file `"timestamp"` (above) instead. **(2)** A time- or budget-bounded sweep is **partial** — report it as "searched the N most-recent; older unsearched", never a clean "no prior exists" (same canary discipline: absence is evidence of absence only once the search is proven *complete*).

## Cross-node / cross-machine case (optional)

If you operate Claude Code across multiple machines (e.g. a homelab, a work laptop, a personal desktop), the same skill extends:
- If you have a synced memory layer, check that first
- Otherwise, SSH to the original machine and grep the JSONLs there
- Pull the matching JSONL back if you need to read it locally

A session can even be *resumed* on another machine by copying its JSONL into the target's `~/.claude/projects/<cwd-encoded>/` dir — but the file's baked-in `cwd` still points at the original home: fine for talk-only replay, but tool calls referencing the original machine's paths won't re-run, and hooks don't transfer (the target uses its own config). This is an optional extension — single-machine users can ignore.

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
