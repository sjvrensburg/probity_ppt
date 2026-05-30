# Probity Data Analytics PowerPoint template

A Quarto format extension that renders Markdown to a navy/gold Probity-branded
PowerPoint deck.

## Quick start

```bash
quarto render template.qmd
```

This produces `template.pptx`, a fully branded example deck.

To start your own deck, copy `_extensions/` and `assets/` next to a new `.qmd`
and set the format:

```yaml
---
title: "Deck title"
subtitle: "A short, factual subtitle"
author: "Author Name, Role"
date: today
format: probity-pptx-pptx
---
```

## Layout rules

The deck uses slide-level 2:

- `# Heading` produces a navy **section divider** (Section Header layout)
- `## Heading` produces a white **content slide** (Title and Content layout)
- `## Heading` plus `::: {.columns}` produces a two-column slide

Keep section dividers heading-only: body text under a `#` produces a stray
slide.

For branded **stat cards** and **three-card rows**, write a marker plus a
bullet list (fields separated by `::`, `*` marks the gold emphasis card):

```markdown
## Headline numbers

[[statcards]]

- Sample :: 6 :: Fiscal-year observations
- *Multiplier :: R 14.9M :: Applied provision uplift
```

These are drawn by `build/probity_cards.py` via the `_quarto.yml` post-render
hook. See `SKILL.md` for the full pattern.

## What is in here

| Path | Purpose |
|---|---|
| `_extensions/probity-pptx/_extension.yml` | Quarto format definition |
| `_extensions/probity-pptx/reference.pptx` | Branded pandoc reference document |
| `assets/` | Logo files (navy, white, trimmed, full) |
| `template.qmd` | Worked example deck |
| `build/build_reference.py` | Regenerates `reference.pptx` from the palette |
| `build/probity_cards.py` | Post-render step that draws stat-card / three-card slides |
| `_quarto.yml` | Wires the card post-render hook |
| `SKILL.md` | Guide for Claude on using the template |

## Rebuilding the reference document

`reference.pptx` is generated. To change the brand or layouts, edit
`build/build_reference.py` and run:

```bash
python3 build/build_reference.py
```

Do not edit `reference.pptx` by hand: changes are lost on the next rebuild.

## Brand palette

| Colour | Hex |
|---|---|
| Primary navy | `#0A325A` |
| Gold accent | `#C8881F` |
| Mid blue | `#4A7BA8` |
| Pale blue tint | `#E8EEF5` |
| Body text | `#1F2937` |
| Hairline | `#D5DEE9` |

Font: Calibri. Navy dominates; gold is the accent only. See `SKILL.md` for the
full brand and voice rules.
