# chengyu-skills

**Cultural-handle skills for Claude Code.** Each skill is a four-character idiom — a Chinese chengyu (成語), or a Japanese 四字熟語 of the same form — that names a specific strategic schema the model has seen contextualised thousands of times in training. Dropping the handle into a prompt — or letting the skill auto-trigger on description match — activates a tight constellation of behaviours that would otherwise take a paragraph to specify cold.

This is the operator-level discipline of using cultural handles as compressed prompt circuits. A chengyu like 抛磚引玉 ("throw a brick to attract jade") names a specific schema (emit a deliberately rough first pass to elicit refinement) that English doesn't have a clean single-word handle for. The model knows what 抛磚引玉 *means* from training; the SKILL.md teaches the agent what to *do* when the handle fires.

## Quickstart

```bash
git clone https://github.com/evnchn-agentic/chengyu-skills.git ~/chengyu-skills
~/chengyu-skills/install.sh
```

`install.sh` symlinks each skill directory into `~/.claude/skills/`. Symlinks (not copies) so that pulling repo updates is reflected live in Claude Code.

Restart Claude Code (or start a new session) and the skills become discoverable. Try invoking one:

```
/panda-doctor I keep patching the same bug in different forms and it keeps coming back.
```

panda-doctor will name the chengyu (`釜底抽薪` — strike at the root cause, not the symptom) and pause. If you ask "what does that mean?" it'll tell the classical story tightly and map it back to your situation.

To uninstall: `~/chengyu-skills/install.sh uninstall` removes only the symlinks this repo created — never touches non-symlink skills.

## What's in the catalog

Twenty-six chengyu + one pedagogical companion (`panda-doctor`, the 熊貓博士 chengyu-selector from the Hong Kong TVB show *成語動畫廊*).

The chengyu group loosely by failure-mode:

**Iteration & drafting**
- `chengyu-throw-brick-attract-jade` (抛磚引玉) — emit rough first pass to elicit refinement
- `chengyu-grind-pestle-to-needle` (鐵杵磨針) — compound effort, 99 of 100 attempts fail, don't give up on the 100th
- `chengyu-retreat-is-best` (走為上計) — bail out of a failed approach (three retreat levels)
- `chengyu-stop-when-appropriate` (適可而止) — the 80/20 stop discipline
- `chengyu-cleave-ox-at-joints` (庖丁解牛) — find natural seams, work WITH the grain

**Debugging & causation**
- `chengyu-remove-firewood-from-cauldron` (釜底抽薪) — strike at the obvious causal root
- `chengyu-besiege-wei-save-zhao` (圍魏救趙) — non-causal redirect when frontal approach blocked
- `chengyu-lost-sheep-repair-fence` (亡羊補牢) — after a failure, fix the systemic gap not just the symptom
- `chengyu-close-door-catch-thief` (關門捉賊) — isolate the failure domain (with ASK-or-PITCH guard)
- `chengyu-seeing-is-believing` (眼見為實) — empirical verification, not model-based confidence

**Planning & adaptation**
- `chengyu-think-thrice-before-acting` (三思而後行) — meta-planning, catches what first plan missed
- `chengyu-adapt-to-changing-circumstances` (隨機應變) — mid-flight plan deviation within negotiated scope
- `chengyu-rest-await-the-tired` (以逸待勞) — strategic patience while inputs in flux
- `chengyu-watch-fire-across-shore` (隔岸觀火) — let failure declare full shape before intervening
- `chengyu-break-whole-into-parts` (化整為零) — task decomposition / divide-and-conquer

**Review & adversarial discipline**
- `chengyu-listen-all-sides-see-clearly` (兼聽則明) — adversarial multi-source review before shipping
- `chengyu-two-pipes-adversarial` (雙管齊下) — GAN thinking (generator + adversarial discriminator)
- `chengyu-create-something-from-nothing` (無中生有) — **subagent-only** bottom-K sampling with hardened gates

**Memory & migration**
- `chengyu-review-old-know-new` (溫故知新) — re-read past sessions for priors (NOT current context)
- `chengyu-one-time-one-meeting` (一期一會, *ichi-go ichi-e*) — every session is non-fungible; the invocation surface that fires durable-fix skills a "next session will handle it" mindset would skip
- `chengyu-borrow-corpse-return-soul` (借屍還魂) — transplant proven config / revive good code
- `chengyu-cicada-sheds-its-shell` (金蟬脫殼) — graceful migration with honest stub

**Communication**
- `chengyu-words-concise-meaning-complete` (言簡意賅) — TLDR-outside / details-inside, anti-sprawl
- `chengyu-great-wisdom-looks-foolish` (大智若愚) — resist demonstrating cleverness (target param required)
- `chengyu-teach-by-material` (因材施教) — match output FORMAT to consumer × use-mode
- `chengyu-speak-directly-no-taboo` (直言不諱) — anti-sugarcoating
- `chengyu-know-what-you-dont-know` (知之為知之，不知為不知) — honest gap-marking, surface "I don't know"

**Meta-companion**
- `panda-doctor` (熊貓博士) — chengyu selector + explainer + crystalizer + auditor for the catalog itself

Each SKILL.md embeds: handle (Traditional + Simplified characters), reading (pinyin, or romaji for the Japanese-origin entries), schema description, "when this applies" symptoms, explicit behaviours, anti-pattern, and a brief etymology.

## Architectural factoring

- **Cultural handle** = interface. What you remember and reach for.
- **SKILL.md** = implementation. What the agent receives — schema + etymology in the same shot, so the model can activate the named circuit rather than just executing instructions.
- A few skills ship as deliberate exceptions to the lock-to-idiom-form rule (below), each with explicit rationale in the SKILL.md:
  - `chengyu-create-something-from-nothing` — adversarial-core chengyu reclaimed for productive bottom-K sampling, with hardened safety gates
  - `panda-doctor` — non-chengyu pedagogical companion from the same cultural tradition (成語動畫廊)

## Discipline

- **Handle must precisely match the schema, not approximately.** A vaguely-fitting chengyu that "sounds cool" degrades the mnemonic and stops doing useful work.
- **Lock to the four-character-idiom form, not to one nation.** Chinese chengyu (成語) are the heart of the catalog and its namesake; Japanese 四字熟語 of the same form — same characters, same compressed-circuit mechanism — are equally welcome, no outlier status. What stays out, in sibling repos, is *other* handle traditions: Aesop fables, named-operator-personas, software design patterns. "Bucket by source" means bucket by register/mechanism (the four-character idiom the model has deeply internalised), not by alphabet — and not by passport. (The `chengyu-` directory prefix is kept as the catalog's namespace even for 四字熟語 entries.)
- **Don't add cross-language synonyms of an idiom already in the catalog.** Admit an idiom because it carries a schema no existing entry does — not because it restates one in another language. E.g. 一期一會 earns its slot (no clean Chinese equivalent for "this encounter won't recur"); 一石二鳥 would not (一箭雙鵰 / 一舉兩得 already cover "two goals, one action").
- **Schema gloss matters more than the handle.** Bare-handle invocation drifts toward stereotype, especially on smaller models. The "behavior" section in each SKILL.md is what's actually doing the work.

## Adding a new chengyu

1. Create `chengyu-<english-literal>/SKILL.md` following the shape of the existing entries (literal English translation works better as the handle than pinyin — easier to retrieve from memory).
2. Re-run `install.sh` (idempotent).
3. Use it for a week before committing to the handle — candidate names are often aspirational (you think it's 圍魏救趙 but it's actually 釜底抽薪).

For more structured chengyu maintenance, see `panda-doctor/SKILL.md` — the CRYSTALIZER mode handles add-new (3-new) and edit-existing (3-edit), the AUDITOR mode handles session-level and catalog-level drift detection.

## Compatibility

- Tested on Claude Code (macOS, Linux). WSL on Windows should work; native Windows untested.
- Skills follow the [agentskills.io](https://agentskills.io/specification) spec.

## License

MIT
