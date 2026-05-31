---
name: codebase-documenter
description: Use when the user asks for a report explaining how something works across the codebase — how a feature flows across services, what format or keys a database / message / config uses, how an end-to-end process works, or "document/explain how X works". Not for editing docs or fixing a single bug.
---

# codebase-documenter

Answer a "how does X work / what is Y" question about this codebase with a thorough,
**evidence-backed** report in a fixed shape, written to a file. Predictable structure plus real
`path:line` citations make the report trustworthy — and the same every time. Read the code; never
answer from memory.

## Report shape (use these exact sections, in order; write "None" rather than omitting one)

```markdown
# <Title>

## Answer (TL;DR)
2–4 sentences. The direct answer.

## Scope
- Question: <restate the question exactly>
- Examined: <the services / dirs / files you actually read>
- Not covered: <what you skipped, deliberately or unavoidably>

## How it works
The body, decomposed by service / step / component. Every non-obvious claim cites `path:line`.

## Key formats / types / contracts
Concrete schemas, keys, message/DB/config formats — each with `path:line`.

## Diagram
Optional ```mermaid flow or sequence for a cross-component path. Omit if it adds nothing.

## Gaps & open questions
What is uncertain, unverified, or needs a human. Be honest here instead of guessing above.

## References
Entry points and the `path:line` list you relied on.
```

## Steps
1. Restate the question; classify it (feature-flow / data-format / cross-service / single-component).
   If scope is ambiguous or huge, say so and confirm or split before investigating.
2. Map the territory: grep/glob for entry points and the relevant services/dirs; list what you'll read.
3. Investigate breadth-first, then depth. Trace the flow or format across files. Collect a `path:line`
   for each claim as you go — one claim, one citation.
4. Read the actual code before asserting. Quote real identifiers and paths; don't paraphrase from memory.
5. Assemble the report in the exact shape above. Put every uncertainty in **Gaps**, not in the body.
6. Write it to `<topic>-report.md` (or the path the user gave). Print a short inline TL;DR + the file path.

## Do not
- No uncited non-obvious claims. No citation → move it to **Gaps**, or cut it.
- Never fabricate a path, symbol, or behavior. If you didn't read it, it isn't a finding.
- Don't silently narrow scope — record what you skipped under **Scope → Not covered**.
- Keep the section order fixed, even when a section is "None".

## Common mistakes
- Describing what you *expect* a framework to do instead of what this repo does → read the repo.
- A wall of prose with no citations → every claim earns a `path:line`.
- Scope creep into a five-service epic → confirm scope first; propose splitting big questions.
