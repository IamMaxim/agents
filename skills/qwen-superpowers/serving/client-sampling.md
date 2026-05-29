# Client-side sampling & thinking

You don't run inference, but a few things are set or overridable from the client. Use these;
send the rest to your platform team via [`endpoint-checklist.md`](endpoint-checklist.md).

## Sampling (if your endpoint honors per-request overrides)
For agentic coding, bias toward determinism:
- **temperature 0.2–0.4** for the execution loop — lower than the 0.6/0.7 defaults. You want
  repeatable edits, not creativity.
- top_p ~0.9, top_k 20 are reasonable.
- Nudge **presence_penalty / repetition_penalty up** and keep **min_p low** to curb Qwen's
  tendency to over-explain (community-reported; it matches the no-preamble rule in `AGENTS.md`).

Set these wherever your harness exposes generation params, or ask your gateway to accept the
standard OpenAI sampling fields.

## Thinking mode
Qwen3.5 thinks by default and has no `/think` soft switch; toggle per call with
`chat_template_kwargs: {enable_thinking: <bool>}` if your gateway passes it through.

For an agentic loop:
- **Off** for routine execution (`/tdd`, `/execute-plan`) — fewer tokens, less context bloat,
  faster tool turns. The skills supply the structure that thinking would otherwise add.
- **On** for reasoning-heavy moments (`/brainstorm`, `/debug`, planning a tricky change).

Can't toggle it client-side? Live with the default and rely on the `AGENTS.md` discipline + hooks;
just expect thinking-on to be slower and chattier per step.

## Context hygiene (fully under your control)
- Keep sessions short and task-scoped; start fresh per task. Qwen's attention degrades with
  context length faster than a frontier model's.
- Don't paste huge files — read the specific part you need.
- Compact or summarize aggressively when the window fills.
