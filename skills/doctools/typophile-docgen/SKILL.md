---
name: typophile-docgen
description: Use when converting an auto-converted, machine-exported, or messy wiki page (Jira, Confluence, docx, Notion, or proprietary wiki HTML export) into clean docgen markdown — symptoms include code shown as plain text, random bold/italic/inline-code on ordinary words, raw HTML tags, broken or tab-aligned tables, smart-quote mojibake, or missing/wrong frontmatter for the docgen wiki.
---

# typophile-docgen

Convert ONE messy, machine-exported page into clean **docgen** markdown. Fix the *meaning*, not just
the syntax — wiki exporters dump code as plain text, put emphasis on random words, leave raw HTML, and
produce dead tables. Preserve every fact; never invent. When unsure, keep the content and flag it —
do not drop it.

## docgen target format (produce exactly this)

Frontmatter (YAML, at the very top):

```yaml
---
title: Page title             # from the page's H1 / title
description: one-line summary  # used by search + meta tags; keep it short
order: 10                      # sidebar position; keep the user's value or pick a sensible one
---
```

Body rules:
- **Links:** internal → wikilink `[[slug]]` or `[[slug|Label]]` (folders optional, matched by slug).
  External → `[text](https://…)`. Drop tracking params and dead `#` anchors.
- **Code:** always fenced with a language — ` ```ts `, ` ```bash `, ` ```json `. Never leave code as prose.
- **Math:** inline `$E=mc^2$`, block `$$ … $$` (KaTeX; chemistry via mhchem).
- **Diagrams:** ` ```mermaid ` blocks.
- **Images:** `![alt](./relative.png)` — relative paths get bundled, keep the alt text. Leave
  absolute (`/x.png`) and URL images unchanged.
- **Callouts (docgen-specific):** a blockquote whose FIRST line starts with `TODO:`, `CONTENT TODO:`,
  `OPEN QUESTION:`, or `DISCUSSION:` renders as a styled callout. These four are the only styled kinds.
  A generic "Note:/Warning:/Important:" is NOT a styled callout — make it a normal blockquote
  (`> **Note:** …`).
- **Tables:** standard pipe tables. `--`→en-dash and `---`→em-dash happen automatically; write straight quotes.

## Steps
1. Read the whole page first. Decide what it is (guide, reference, API, notes) and its real title.
2. Write the frontmatter (`title`, `description`, `order`).
3. Fix headings: one logical level under the title, no skipped levels, no duplicated page-title heading.
4. Reconstruct code: anything that *is* code — pasted as text, indented, wrapped in stray `inline code`,
   or sitting in a screenshot caption — becomes a fenced block with a guessed language.
5. Remove export emphasis: `**bold**` / `*italic*` / `` `code` `` wrapped around ordinary words is
   noise — make it plain text. Keep emphasis only where it is real (a true UI label, a real identifier).
6. Convert HTML to markdown: `<br>`→newline, `<b>`/`<strong>`→`**bold**`, `<i>`/`<em>`→`*italic*`,
   `<ul><li>`→`-` list, `<a href>`→link, `<table>`→pipe table.
7. Rebuild tables: tab/space-aligned columns and dumped HTML tables → real pipe tables.
8. Convert notes: action items / open questions / discussion points → docgen callouts
   (`> TODO:` / `> CONTENT TODO:` / `> OPEN QUESTION:` / `> DISCUSSION:`). Plain "Note:/Warning:"
   → a normal blockquote `> **Note:** …`.
9. Strip noise: non-breaking spaces, zero-width chars, smart-quote mojibake (`Â`, `â€™`), breadcrumb
   trails, "Table of Contents" blocks, page footers, doubled blank lines, stray `{#id}` heading anchors.
10. Re-read. Confirm meaning is intact. Anything you could not confidently convert → wrap in a
    `> CONTENT TODO:` callout. End by listing the structural changes you made.

## Examples (before → after)

Code shown as plain text → fenced block:

````
Before:  To start the server run npm run dev, then open localhost:5173

After:
```bash
npm run dev
```
Then open `localhost:5173`.
````

Export emphasis garbage → plain text (keep only the real label):

```
Before:  The **user** must *click* the `Save` button to **continue**.
After:   The user must click the **Save** button to continue.
```

Raw HTML list + an action item → markdown list + callout:

```
Before:  <b>Steps</b><ul><li>Build</li><li>Deploy</li></ul> TODO: document the deploy step.
After:   **Steps**

         - Build
         - Deploy

         > TODO: document the deploy step.
```

## Do not
- Never invent, summarize away, or "improve" content — only re-express what is already there.
- Never drop something you do not understand — wrap it in a `> CONTENT TODO:` callout.
- Don't add emphasis the source didn't mean; when unsure, plain text.
- Don't emit raw HTML when markdown can express it.
- One page per run.
