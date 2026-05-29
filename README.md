# agents

A monorepo of skills, subagent descriptions, and related tooling for driving local and
open-weight LLMs in agentic coding harnesses.

## Layout
```
agents/
└── skills/
    └── qwen-superpowers/   Superpowers methodology adapted for Qwen3.5-397B-A17B (Qwen Code)
```
More packages — additional skill packs, subagent definitions, and so on — will live alongside.

## Packages

### [skills/qwen-superpowers](skills/qwen-superpowers/)
An adaptation of [obra/superpowers](https://github.com/obra/superpowers) for **Qwen3.5-397B-A17B**
running under **Qwen Code**: always-on discipline (`QWEN.md`), slash-command entry points, and
enforcement hooks that contain a weaker model's mistakes (block destructive shell, run project
checks after every edit). See its [README](skills/qwen-superpowers/README.md).

## License
[MIT](LICENSE). Individual packages may carry their own attribution — e.g.
[`skills/qwen-superpowers/LICENSE`](skills/qwen-superpowers/LICENSE) credits the upstream
Superpowers project.
