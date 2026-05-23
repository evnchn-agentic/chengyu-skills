---
name: chengyu-throw-brick-attract-jade
description: Use when user asks for a rough draft, first pass, brainstorm, MVP, stub, sketch, or proposes to "draft a PR for review and refinement before sending upstream" — anywhere the user is throwing a brick (deliberately rough work) to elicit jade (refinement, feedback, selection)
---

# 抛磚引玉 — throw brick, attract jade

**抛磚引玉 / 拋磚引玉** (pāo zhuān yǐn yù) — literally "throw a brick to attract jade". Emit a deliberately rough first pass to elicit refinement.

## When user is throwing a brick

Real shapes that signal the user is throwing a brick:

- "Draft a PR raised to my fork for my review and refinement before sending upstream"
- "brainstorm API options. Later we will select which one to go with"
- "so what fix? brainstorm"
- "Brainstorm harder, search the web"
- "branch off the PR branch in your fork, where you can play without upstream noise concern, and propose a diff set once known works"
- "draft a reply to the issue retracting the wrapper idea"
- "post the bench findings as a comment on the issue, propose a reasonable budget"
- "Get to doing and throw the brick for me"

The fork-as-staging pattern (work in fork, refine, then upstream) is literally 抛磚引玉 as software engineering practice.

## Behavior

1. **Produce a quick sketch, not a polished artifact.** Resist the urge to over-engineer the first pass. Speed over completeness.
2. **Explicitly flag what's rough.** Name the gaps, assumptions, and known weaknesses inline. Don't hide them.
3. **Invite specific refinements.** End with concrete questions or choice points — not a generic "let me know what you think".
4. **Don't apologize for roughness.** The roughness is the *feature*, not a bug. It's bait for the jade.

## Anti-pattern

Polishing the brick into a small jade. If the user asked for a draft, do not silently spend extra cycles to ship something publication-ready. That defeats the iteration loop and burns their review budget on details they would have changed anyway.

## Etymology (one line, for schema-activation)

The chengyu comes from the Tang dynasty story of poet Chang Jian, who knew Zhao Gu would visit Lingyan Temple; Chang wrote two mediocre lines on the temple wall so that Zhao, when he arrived, would feel compelled to complete the poem with his better couplet — and he did. The mediocre lines were the brick; Zhao's couplet was the jade.
