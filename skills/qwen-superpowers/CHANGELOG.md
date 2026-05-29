# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0] - 2026-05-29

Initial release. An adaptation of the [Superpowers](https://github.com/obra/superpowers)
methodology for **Qwen3.5-397B-A17B** running under **Qwen Code**.

### Added
- `QWEN.md` — always-on discipline loaded every turn (the non-negotiables).
- `skills/` — 10 core methodology skills rewritten in Qwen-friendly style
  (short, imperative, numbered, no ALL-CAPS, no flowcharts).
- `commands/` — 7 slash-command entry points, since Qwen does not reliably
  self-invoke skills the way Claude does.
- `hooks/` — the enforcement layer: block destructive shell commands
  (`PreToolUse`) and run project checks after every edit (`PostToolUse`).
- `settings/` — a sample `.qwen/settings.json` wiring the hooks, plus a
  project check-command example.
- `serving/` — an endpoint checklist to hand to whoever runs your inference,
  and a guide to the sampling/thinking settings you can control client-side.
- `docs/` — design rationale (containment vs. capability) and a condensed
  model-facts reference with sources.
- `install.sh` — links commands into `~/.qwen` and prints the manual steps.

### Known limitations
- Scoped to Qwen3.5-397B-A17B only (by design).
- Slash commands carry condensed procedures inline for robustness; the
  `skills/` files remain the fuller canonical source. A future version may
  switch commands to file-injection once path behavior is confirmed on your
  Qwen Code version.
