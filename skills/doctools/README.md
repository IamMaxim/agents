# doctools

Personal, Qwen-targeted skills for documentation work. These are native **Agent Skills**: each
`<name>/SKILL.md` installs into `~/.qwen/skills/` and is invokable as `/<name>` (the model can also
auto-invoke from the description). Written in the same terse, explicit, anti-drift style as
[`../qwen-superpowers`](../qwen-superpowers) — but a separate collection, since these are domain
utilities rather than the obra methodology.

| Skill | Invoke | Use when |
|-------|--------|----------|
| [typophile-docgen](typophile-docgen/SKILL.md) | `/typophile-docgen` | converting a messy / auto-exported wiki page (Jira, Confluence, docx, …) into clean [docgen](https://github.com/iammaxim/docgen) markdown |
| [codebase-documenter](codebase-documenter/SKILL.md) | `/codebase-documenter` | producing an evidence-backed report on how something works across the codebase |

## Install

```sh
./install.sh                  # links into ~/.qwen/skills (or $QSP_QWEN_DIR/skills)
./install.sh /path/to/skills  # custom skills dir (e.g. ~/.gemini/skills, or a project .qwen/skills)
```

Each skill directory is symlinked into the target; a pre-existing real directory is backed up first.
Restart the harness and run `/skills` to confirm both appear.
