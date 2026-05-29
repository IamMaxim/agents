# Endpoint checklist — hand this to whoever runs your Qwen endpoint

You consume **Qwen3.5-397B-A17B** as an internal OpenAI-compatible API and don't control
serving. A server-side misconfiguration is the single most likely cause of "the model makes a
lot of mistakes" — and you can't see it from the client. Ask your inference/platform team to
confirm each item.

## Tool calling
- [ ] Tool-call parser is **`qwen3_coder`** — not the generic `hermes`.
      - vLLM: `--enable-auto-tool-choice --tool-call-parser qwen3_coder`
      - SGLang: `--tool-call-parser qwen3_coder`
      - Wrong parser ⇒ garbled or dropped tool calls, which looks exactly like a dumb model.
- [ ] `--enable-auto-tool-choice` is set (vLLM).
- [ ] Reasoning parser is **`qwen3`**.

## Sampling defaults
- [ ] Defaults match Qwen's recommendation for the mode in use:
      - thinking → temp **0.6**, top_p **0.95**, top_k **20**
      - non-thinking → temp **0.7**, top_p **0.8**, top_k **20**, presence_penalty **1.5**
      - A too-high temperature is a top cause of "wild edits" and broken tool calls.
- [ ] Clients can override sampling per request (so we can pin a low temperature for coding).

## Thinking mode
- [ ] On or off by default? (Qwen3.5 thinks by default; there is **no** `/think` soft switch.)
- [ ] Can clients toggle per request via `chat_template_kwargs: {enable_thinking: <bool>}`
      (or `enable_thinking` on a DashScope-style gateway)?
- [ ] The chat template strips prior-turn thinking from history (a multi-turn requirement).

## Template, context, precision
- [ ] The official **Qwen3.5-397B-A17B chat template** is in use — a wrong template silently
      degrades everything.
- [ ] Stop tokens / EOS match that template.
- [ ] Served context length is at least **128K** (native 262,144; YaRN extends to ~1M).
- [ ] If served at **fp8**: which fp8 (dynamic/static), and any measured tool-calling /
      structured-output regression vs bf16? fp8 can slightly hurt instruction-following — which
      is exactly why this pack leans on client-side enforcement.

If all of these are correct and the model still struggles, you're at a capability ceiling, not a
config bug — lean harder on small steps, `/tdd`, and the hooks.
