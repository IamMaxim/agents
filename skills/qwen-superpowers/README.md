# qwen-superpowers

An adaptation of the [Superpowers](https://github.com/obra/superpowers) software-development
methodology for **Qwen3.5-397B-A17B**, runnable under multiple agent harnesses — **Qwen Code**,
**Gemini CLI** and forks, **Claude Code** (pointed at a Qwen endpoint), or any harness that reads
`AGENTS.md`.

Superpowers was authored and tuned against Claude. Its skills lean on behaviors a frontier model
has and Qwen does not: long-context instruction adherence, reliable skill self-invocation, and
honest self-verification. Pointed at Qwen, the originals underperform — the model drifts, skips
steps, claims success it didn't verify, and occasionally does something destructive. This pack
keeps the *methodology* and rebuilds the *delivery* around what Qwen 3.5 actually does.

---

## The core idea: separate containment from capability

The pain of driving a weaker model splits into two different problems:

- **Capability** — it makes mistakes. Mitigable, but there's a ceiling. No prompt turns a
  17B-active MoE into Claude.
- **Containment** — its mistakes are expensive (it edits ten files, claims green tests, runs
  `rm -rf`). Almost entirely solvable, cheaply.

Most "babysitting" is a containment problem wearing a capability costume. So this pack spends its
effort on **making mistakes cheap and impossible to hide**, and only then on guiding the model.
Three layers, lowest-trust first:

| Layer | File(s) | What it does | Trust required |
|-------|---------|--------------|----------------|
| **Enforcement** | `hooks/` | Blocks destructive shell; runs your checks after every edit and feeds failures back. The model *cannot* talk past a red test. | None |
| **Always-on discipline** | `AGENTS.md` | The non-negotiables, loaded every turn: small diffs, one change at a time, no preamble, stop-and-report. | Low |
| **On-demand procedure** | `skills/` (native skills where supported) | TDD, debugging, planning, review — invokable as `/<name>` (reliable) and auto-invokable by the model where supported. | Higher |

The design principle in one line: **move non-negotiables into `AGENTS.md`, make explicit
`/<skill>` invocations the reliable entry points, and let hooks enforce what skills can only request.**

---

## Why the originals don't transfer (the model facts that drive this)

`Qwen3.5-397B-A17B` (397B total / 17B active MoE, 512 experts, Apache-2.0, Feb 2026):

- **Thinks by default, no `/think` soft-switch.** You toggle thinking per-call via
  `chat_template_kwargs: {enable_thinking: false}`, and multi-turn history must keep *only final
  answers*. So skills can't lean on an invisible scratchpad, and verbosity/preamble must be
  suppressed explicitly. (See `serving/client-sampling.md`.)
- **Tool calls use the `qwen3_coder` parser**, not the generic `hermes`. Qwen's own docs warn the
  tool protocol "is not guaranteed … even with proper prompting." → reliability has to come from
  enforcement, not trust.
- **Sampling matters:** recommended temp 0.6 (thinking) / 0.7 (non-thinking, with
  `presence_penalty 1.5`). A too-high server default produces exactly the "wild edits" symptom.
- **fp8 serving** can slightly degrade structured-output reliability vs bf16 — one more reason the
  enforcement layer exists.

Full facts with sources: [`docs/model-notes.md`](docs/model-notes.md). The reasoning behind every
design choice: [`docs/DESIGN.md`](docs/DESIGN.md).

> **If you don't run the inference** (common in companies), the most likely single cause of "the
> model is dumb" is a server-side misconfiguration you can't see — wrong tool-call parser, wrong
> sampling defaults, thinking-mode mismatch. Before tuning prompts, hand
> [`serving/endpoint-checklist.md`](serving/endpoint-checklist.md) to whoever operates the endpoint.

---

## Harnesses

The methodology is identical everywhere; only delivery differs. Choose one or more profiles at
install time:

| Profile | Harnesses | Procedures via | Hooks | Default dir |
|---------|-----------|----------------|-------|-------------|
| `qwen-family` | Qwen Code, Gemini CLI, forks | native skills (`/<name>`) | yes (ms timeouts) | `~/.qwen` (configurable) |
| `claude-code` | Claude Code (e.g. pointed at a local/internal Qwen endpoint) | Markdown | yes (sec timeouts) | `~/.claude` |
| `generic` | Codex, Cursor, aider, opencode, … | — | — | a dir you choose |

**Universal everywhere:** `AGENTS.md` (always-on discipline) + `skills/` (the procedures). Per-harness
wiring lives in [`harnesses/<profile>/README.md`](harnesses/). The hook *scripts* are shared across
harnesses; only the settings wiring and tool-name matchers differ.

---

## Layout

```
qwen-superpowers/
├── AGENTS.md               always-on discipline (the cross-harness standard file)
├── skills/                 the 10 adapted methodology skills, native <name>/SKILL.md dirs
├── harnesses/
│   ├── qwen-family/        settings sample + notes; skills install from ../skills/ (Qwen Code / forks)
│   ├── claude-code/        Markdown commands + settings sample (Claude Code)
│   └── generic/            wiring notes for harnesses without commands/hooks
├── hooks/                  enforcement scripts (shared) + checks example
├── serving/                endpoint checklist + client-side sampling guide
├── docs/                   DESIGN.md (rationale + research) + model-notes.md (facts)
└── install.sh              interactive, multi-harness installer (remembers your choices)
```

---

## Requirements

- One of: **Qwen Code**, **Gemini CLI** (or a fork), **Claude Code**, or any `AGENTS.md`-aware harness.
- Access to a **Qwen3.5-397B-A17B** endpoint (OpenAI-compatible is fine).
- `bash`, `jq`, and `git` on PATH (the hooks use `jq` to parse tool input).

## Install

**1. Point your harness at the Qwen endpoint.** For an OpenAI-compatible API (Qwen Code / Gemini
CLI), set the provider env it reads; for Claude Code, set `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN`
to your gateway. Confirm exact names against your harness version.

**2. Run the installer.** It asks which profiles to install and where, remembers your answers in
`~/.config/qwen-superpowers/config`, and prints ready-to-paste hooks snippets with real paths:

```bash
./install.sh            # interactive
./install.sh --print    # show saved choices
./install.sh --yes      # non-interactive (reuse saved/defaults); QSP_* env vars override
```

**3. Do the manual steps it prints:** place `AGENTS.md` where your harness reads it, merge the
hooks snippet into the right `settings.json`, and provide a project check command (`.qwen/checks.sh`
or `$QWEN_SP_CHECK`). See the per-harness READMEs under [`harnesses/`](harnesses/) for specifics.

---

## Usage

On `qwen-family` (Qwen Code) the procedures are **native skills**: invoke one explicitly as `/<name>`
(the reliable path) — the model can also auto-invoke it from its description. On `claude-code` they're
Markdown slash commands; on a `generic` harness, ask it to "follow `skills/<name>/SKILL.md`". Prefer
explicit invocation over trusting the model to pick.

| Skill (`/<name>`) | When |
|-------------------|------|
| `/brainstorming` | before building anything new |
| `/writing-plans` | turn a spec into small, checkable steps |
| `/executing-plans` | work a plan one step at a time |
| `/test-driven-development` | implement a feature or fix, test-first |
| `/systematic-debugging` | a bug, failure, or surprise |
| `/verification-before-completion` | before saying "done"/"fixed" |
| `/requesting-code-review` | prepare a change for review |
| `/receiving-code-review` | acting on review feedback |
| `/using-git-worktrees` | isolating risky work |
| `/finishing-a-development-branch` | wrapping up a finished branch |

### The loop, in practice

1. `/brainstorming` → `/writing-plans` for anything non-trivial.
2. `/test-driven-development` or `/executing-plans` for the work — small steps, one at a time.
3. The **post-edit hook** runs your checks after each edit and pastes failures back into the
   conversation, so the model fixes them instead of moving on.
4. `/verification-before-completion` before any completion claim — it requires pasting real command output.
5. The **pre-bash hook** silently blocks destructive commands the whole time.

---

## The enforcement layer (the part that actually moves reliability)

Two shared hook scripts, wired into your harness's `settings.json` (samples in
`harnesses/<profile>/settings.sample.json`; the installer prints ready snippets with real paths):

- **`block-dangerous-bash.sh`** (`PreToolUse` on the shell tool): denies `rm -rf`, force-push,
  `git reset --hard`, `git clean -fd`, fork bombs, `dd`/`mkfs` to devices, `chmod …777`, and
  similar; asks before recoverable-but-risky ones. Everything else passes silently.
- **`run-checks-after-edit.sh`** (`PostToolUse` on edits): runs your *fast* check command and, on
  failure, injects the output back so the model can't proceed as if it passed. Heavy suites belong
  in `/verification-before-completion`, not here.

Define your check command once, per project:

```bash
# .qwen/checks.sh — fast signal only (lint + typecheck + targeted tests)
ruff check . && mypy app/ && pytest tests/unit -q
```

See [`hooks/README.md`](hooks/README.md) for tuning, including running everything inside your
harness's sandbox so even a blocked-list miss can't touch your host.

---

## Honest ceiling

Scaffolding doesn't raise the model's IQ; it converts capability into *reliable throughput* by
trading autonomy for guardrails. With this pack, Qwen3.5-397B-A17B is a useful executor on
well-scoped, well-tested tasks. It will not become a model you point at a vague ticket and walk
away from. The combination that ships: **small steps, behind hard test gates, in a sandbox, with a
human reviewing the plan.**

---

## Credits & license

Methodology adapted from **[Superpowers](https://github.com/obra/superpowers)** by Jesse Vincent
(obra), MIT-licensed. This adaptation is independent and not affiliated with or endorsed by the
upstream project. Released under the [MIT License](LICENSE).

Contributions welcome — especially feedback from real Qwen 3.5 usage. See [`CHANGELOG.md`](CHANGELOG.md).
