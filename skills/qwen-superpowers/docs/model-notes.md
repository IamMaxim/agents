# Qwen3.5-397B-A17B — facts that shaped this pack

Reported figures from the sources at the bottom; captured 2026-05-29. Verify against your own
endpoint where it matters.

## Architecture
- 397B total parameters, **17B active** (MoE); 512 experts (10 routed + 1 shared per token),
  60 layers, hidden dim 4096, vocab 248,320.
- Released February 2026, **Apache-2.0**. Multimodal (vision-language), ~201 languages.

## Benchmarks (reported)
- SWE-bench Verified **80.0**, Terminal-Bench 2.0 **54.0**, MMLU-Pro 87.8, GPQA-Diamond 88.4.

## Context & output
- Native context **262,144**; extensible to ~**1,010,000** with YaRN.
- Recommended output 32,768 (81,920 for hard math/coding). Keep ≥128K context to preserve
  reasoning; YaRN can hurt short-context quality, so enable it only when actually needed.

## Thinking
- Thinks **by default**. Disable per call: `chat_template_kwargs: {enable_thinking: false}`
  (or `enable_thinking: false` on a DashScope-style gateway).
- **No `/think` / `/nothink` soft switch** (unlike earlier Qwen3).
- Multi-turn: history should contain only final answers, not the thinking content.

## Sampling (official recommendation)
- Thinking: temp 0.6, top_p 0.95, top_k 20, min_p 0, presence 0, repetition 1.0.
- Non-thinking: temp 0.7, top_p 0.8, top_k 20, presence_penalty 1.5.

## Tool calling
- Parser **`qwen3_coder`** (not the generic `hermes`).
  - vLLM: `--enable-auto-tool-choice --tool-call-parser qwen3_coder --reasoning-parser qwen3`
  - SGLang: `--tool-call-parser qwen3_coder --reasoning-parser qwen3`
- Qwen's docs warn the tool protocol "is not guaranteed … even with proper prompting" → build
  for fallible tool calls; enforce rather than trust.

## Why this matters for the skills
- No reliable hidden scratchpad to lean on → suppress preamble/narration explicitly.
- Tool calls can be malformed → the hooks plus small steps catch the fallout.
- fp8 serving (this deployment) can slightly degrade structured output vs bf16 → one more reason
  for the enforcement layer.

## Sources
- Qwen/Qwen3.5-397B-A17B model card — <https://huggingface.co/Qwen/Qwen3.5-397B-A17B>
- Qwen function-calling docs — <https://qwen.readthedocs.io/en/latest/framework/function_call.html>
- Unsloth Qwen3.5 run guide — <https://unsloth.ai/docs/models/qwen3.5>
- Artificial Analysis overview — <https://artificialanalysis.ai/articles/qwen3-5-397b-a17b-everything-you-need-to-know>
- NVIDIA build model card — <https://build.nvidia.com/qwen/qwen3.5-397b-a17b/modelcard>
