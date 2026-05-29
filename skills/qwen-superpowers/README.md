# qwen-superpowers

An adaptation of the [Superpowers](https://github.com/obra/superpowers) software-development
methodology for **Qwen3.5-397B-A17B** running under **[Qwen Code](https://github.com/QwenLM/qwen-code)**.

Superpowers was authored and tuned against Claude. Its skills lean on behaviors a frontier
model has and Qwen does not: long-context instruction adherence, reliable skill self-invocation,
and honest self-verification. Pointed at Qwen, the original skills underperform — the model
drifts, skips steps, claims success it didn't verify, and occasionally does something
destructive. This repo keeps the *methodology* and rebuilds the *delivery* around what Qwen
3.5 actually does.

---

## The core idea: separate containment from capability

The pain of driving a weaker model splits into two different problems:

- **Capability** — it makes mistakes. Mitigable, but there's a ceiling. No prompt turns a
  17B-active MoE into Claude.
- **Containment** — its mistakes are expensive (it edits ten files, claims green tests, runs
  `rm -rf`). Almost entirely solvable, cheaply.

Most "babysitting" is a containment problem wearing a capability costume. So this pack spends
its effort on **making mistakes cheap and impossible to hide**, and only then on guiding the
model. Three layers, lowest-trust first:

| Layer | File(s) | What it does | Trust required |
|-------|---------|--------------|----------------|
| **Enforcement** | `hooks/` | Blocks destructive shell; runs your checks after every edit and feeds failures back. The model *cannot* talk past a red test. | None |
| **Always-on discipline** | `QWEN.md` | The non-negotiables, loaded every turn: small diffs, one change at a time, no preamble, stop-and-report. | Low |
| **On-demand procedure** | `commands/` + `skills/` | TDD, debugging, planning, review — invoked explicitly via slash commands, because Qwen won't self-invoke reliably. | Higher |

The design principle in one line: **move non-negotiables into always-on context, make explicit
`/commands` the entry points, and let hooks enforce what skills can only request.**

---

## Why the originals don't transfer (the model facts that drive this)

`Qwen3.5-397B-A17B` (397B total / 17B active MoE, 512 experts, Apache-2.0, Feb 2026):

- **Thinks by default, no `/think` soft-switch.** You toggle thinking per-call via
  `chat_template_kwargs: {enable_thinking: false}`, and multi-turn history must keep *only
  final answers*. So skills can't lean on an invisible scratchpad, and verbosity/preamble must
  be suppressed explicitly. (See `serving/client-sampling.md`.)
- **Tool calls use the `qwen3_coder` parser**, not the generic `hermes`. Qwen's own docs warn
  the tool protocol "is not guaranteed … even with proper prompting." → reliability has to come
  from enforcement, not trust.
- **Sampling matters:** recommended temp 0.6 (thinking) / 0.7 (non-thinking, with
  `presence_penalty 1.5`). A too-high server default produces exactly the "wild edits" symptom.
- **fp8 serving** (your case) can slightly degrade structured-output reliability vs bf16 — one
  more reason the enforcement layer exists.

Full facts with sources: [`docs/model-notes.md`](docs/model-notes.md). The reasoning behind every
design choice: [`docs/DESIGN.md`](docs/DESIGN.md).

> **You don't run the inference.** That's common in companies, and it's important here: the most
> likely single cause of "the model is dumb" is a server-side misconfiguration you can't see —
> wrong tool-call parser, wrong sampling defaults, thinking-mode mismatch. Before tuning prompts,
> hand [`serving/endpoint-checklist.md`](serving/endpoint-checklist.md) to whoever operates the
> endpoint.

---

## Layout

```
qwen-superpowers/
├── QWEN.md                 always-on discipline (import this into your QWEN.md)
├── skills/                 the 10 adapted methodology skills (canonical, readable)
├── commands/               7 Qwen Code slash commands that invoke the skills
├── hooks/                  enforcement: block-dangerous-bash + run-checks-after-edit
├── settings/               sample .qwen/settings.json + project check-command example
├── serving/                endpoint checklist + client-side sampling guide
├── docs/                   DESIGN.md (rationale + research) + model-notes.md (facts)
└── install.sh              links commands into ~/.qwen, prints manual steps
```

---

## Requirements

- **Qwen Code** CLI installed.
- Access to a **Qwen3.5-397B-A17B** endpoint (OpenAI-compatible is fine).
- `bash`, `jq`, and `git` on PATH (the hooks use `jq` to parse tool input).

## Install

**1. Point Qwen Code at your endpoint.** For an OpenAI-compatible internal API, set the
provider env it reads (confirm names against your Qwen Code version):

```bash
export OPENAI_BASE_URL="https://your-internal-endpoint/v1"
export OPENAI_API_KEY="…"
export OPENAI_MODEL="Qwen3.5-397B-A17B"
```

**2. Run the installer** (links slash commands into `~/.qwen/commands`, makes hooks executable):

```bash
./install.sh
```

**3. Do the three manual steps it prints:**
- Import `QWEN.md` into your project (or global) `QWEN.md`.
- Merge `settings/settings.json` into your `.qwen/settings.json` (set the hook paths).
- Provide a project check command (`.qwen/checks.sh` or `$QWEN_SP_CHECK`).

Everything works per-project or globally — commands live in `~/.qwen`, while `QWEN.md`, hooks,
and the check command are best set per-project so the checks match the repo.

---

## Usage

Drive work through the slash commands — don't rely on the model to pick the right procedure:

| Command | When | Skill |
|---------|------|-------|
| `/brainstorm <idea>` | before building anything new | brainstorming |
| `/write-plan <spec>` | turn a spec into small, checkable steps | writing-plans |
| `/execute-plan <plan>` | work a plan one step at a time | executing-plans |
| `/tdd <change>` | implement a feature or fix, test-first | test-driven-development |
| `/debug <symptom>` | a bug, failure, or surprise | systematic-debugging |
| `/verify <claim>` | before saying "done"/"fixed" | verification-before-completion |
| `/review <scope>` | prepare a change for review | requesting-code-review |

The non-command skills (`using-git-worktrees`, `finishing-a-development-branch`,
`receiving-code-review`) live in `skills/` and are referenced by `QWEN.md` at the right moments.

### The loop, in practice

1. `/brainstorm` → `/write-plan` for anything non-trivial.
2. `/tdd` or `/execute-plan` for the work — small steps, one at a time.
3. The **post-edit hook** runs your checks after each edit and pastes failures back into the
   conversation, so the model fixes them instead of moving on.
4. `/verify` before any completion claim — it requires pasting real command output.
5. The **pre-bash hook** silently blocks destructive commands the whole time.

---

## The enforcement layer (the part that actually moves reliability)

Two hooks, wired in `settings/settings.json`:

- **`block-dangerous-bash.sh`** (`PreToolUse` on `Bash`): denies `rm -rf`, force-push,
  `git reset --hard`, `git clean -fd`, fork bombs, `dd`/`mkfs` to devices, `chmod -R 777`, and
  similar. Everything else passes silently.
- **`run-checks-after-edit.sh`** (`PostToolUse` on edits): runs your *fast* check command and, on
  failure, injects the output back so the model can't proceed as if it passed. Heavy suites
  belong in `/verify`, not here.

Define your check command once, per project:

```bash
# .qwen/checks.sh — fast signal only (lint + typecheck + targeted tests)
ruff check . && mypy app/ && pytest tests/unit -q
```

See [`hooks/README.md`](hooks/README.md) for tuning, including running everything inside Qwen
Code's sandbox so even a blocked-list miss can't touch your host.

---

## Honest ceiling

Scaffolding doesn't raise the model's IQ; it converts capability into *reliable throughput* by
trading autonomy for guardrails. With this pack, Qwen3.5-397B-A17B is a useful executor on
well-scoped, well-tested tasks. It will not become a model you point at a vague ticket and walk
away from. The combination that ships: **small steps, behind hard test gates, in a sandbox, with
a human reviewing the plan.**

---

## Credits & license

Methodology adapted from **[Superpowers](https://github.com/obra/superpowers)** by Jesse Vincent
(obra), MIT-licensed. This adaptation is independent and not affiliated with or endorsed by the
upstream project. Released under the [MIT License](LICENSE).

Contributions welcome — especially feedback from real Qwen 3.5 usage. See [`CHANGELOG.md`](CHANGELOG.md).
