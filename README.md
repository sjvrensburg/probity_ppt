# Probity Data Analytics PowerPoint template

A Quarto format extension that renders Markdown to a navy/gold Probity-branded
PowerPoint deck.

## Quick start

```bash
quarto render template.qmd
```

This produces `template.pptx`, a fully branded example deck.

## Installation

### Option A: Use the install script (recommended)

From the **repository root** of `probity_ppt`, run:

```bash
./install.sh /path/to/your-project
```

This copies the extension, build scripts, and assets into your project and
ensures `_quarto.yml` has the required post-render hooks. It also validates the
result.

### Option B: `quarto add` from a local clone

**Important:** point `quarto add` at the **repository root**, not at the
`_extensions/` directory. Quarto discovers extensions by iterating subdirectories
inside `_extensions/`; pointing at the extension directory itself yields
"Found 0 extensions".

```bash
# Clone (or download) the template
git clone <probity-ppt-url> /tmp/probity_ppt

# From your project directory, install the extension:
cd /path/to/your-project
quarto add /tmp/probity_ppt --no-prompt
```

Then copy the build scripts and add post-render hooks manually:

```bash
cp -r /tmp/probity_ppt/build/ /path/to/your-project/build/
```

And ensure your project's `_quarto.yml` includes:

```yaml
project:
  post-render:
    - python3 build/probity_cards.py
    - python3 build/probity_fonts.py
```

### Option C: Manual copy

Copy three directories into your project root:

```bash
cp -r _extensions/ /path/to/your-project/
cp -r build/       /path/to/your-project/
cp -r assets/      /path/to/your-project/
```

Create or update `_quarto.yml` in the project root with the post-render hooks
shown above.

## Rendering from subdirectories

If your `.qmd` files live in a subdirectory (e.g., `pipeline/docs/`), Quarto
must discover the extension by walking upward from the document to the project
root. This requires a `_quarto.yml` at the project root:

```
your-project/
  _quarto.yml          <- required for subdirectory discovery
  _extensions/
    probity-pptx/
  build/
  pipeline/
    docs/
      presentation.qmd
```

Without `_quarto.yml`, Quarto does not treat the directory tree as a project and
will not find `_extensions/` when rendering from inside a subdirectory. The
error message is:

```
ERROR: Unable to read the extension 'probity-pptx'.
```

The fix is always the same: add a `_quarto.yml` at the project root. It can be
minimal:

```yaml
project:
  post-render:
    - python3 build/probity_cards.py
    - python3 build/probity_fonts.py
```

Then render from the project root:

```bash
quarto render pipeline/docs/presentation.qmd
```

## Authoring a deck

To start a new deck, create a `.qmd` with this front matter:

```yaml
---
title: "Deck title"
subtitle: "A short, factual subtitle"
author: "Author Name, Role"
date: today
format: probity-pptx-pptx
---
```

The format key is `probity-pptx-pptx` (extension directory name `probity-pptx`,
base format `pptx`).

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

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `quarto add` says "Found 0 extensions" | Path points to `_extensions/probity-pptx/` instead of repo root | Point `quarto add` at the repository root directory that **contains** `_extensions/` |
| `Unable to read the extension 'probity-pptx'` | No `_quarto.yml` at project root, or `_extensions/` is missing | Add a `_quarto.yml` at the project root and ensure `_extensions/probity-pptx/` exists |
| Card markers render as plain bullets | Post-render hooks not wired up | Ensure `_quarto.yml` has the `post-render` entries and `build/probity_cards.py` is present |
| Code appears in Courier, not Consolas | `build/probity_fonts.py` not running | Add the fonts post-render hook to `_quarto.yml` |

## What is in here

| Path | Purpose |
|---|---|
| `_extensions/probity-pptx/_extension.yml` | Quarto format definition |
| `_extensions/probity-pptx/reference.pptx` | Branded pandoc reference document |
| `assets/` | Logo files (navy, white, trimmed, full) |
| `template.qmd` | Worked example deck |
| `build/build_reference.py` | Regenerates `reference.pptx` from the palette |
| `build/probity_cards.py` | Post-render step that draws stat-card / three-card slides |
| `build/probity_fonts.py` | Post-render step that sets Consolas for code |
| `_quarto.yml` | Wires the post-render hooks |
| `install.sh` | Helper script to install extension into another project |
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
