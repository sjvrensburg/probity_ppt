---
name: probity-pptx-template
description: "Create branded Probity Data Analytics PowerPoint decks with Quarto. Use this skill whenever the user wants to build, draft, or restyle a slide deck (.pptx) for Probity: client decks, internal reviews, conference talks, methodology walkthroughs, or any slide output carrying the Probity name. Triggers even when the user only says 'make a Probity deck', 'turn this into slides', 'use our PowerPoint template', or attaches notes to convert to slides. The skill wraps a Quarto format extension that renders Markdown to a navy/gold Probity-branded .pptx via a styled reference document."
---

# Probity Data Analytics Quarto PowerPoint template

This skill builds branded PowerPoint decks for Probity Data Analytics from a
Quarto Markdown source. The branding (navy/gold palette, Calibri, logo chrome,
slide layouts) lives in a pandoc **reference document** at
`_extensions/probity-pptx/reference.pptx`. You write content in a `.qmd` file
and Quarto renders a styled `.pptx`.

This template is the slide-specific companion to the broader Probity house
style. The palette and voice rules here are authoritative; apply them.

## When this skill triggers

Any slide deck (`.pptx`) that will leave the studio under the Probity name:
client decks, internal review decks, conference talks, methodology
walkthroughs, board updates. If the user asks for "slides" or "a deck" and the
audience is a Probity client, reviewer, or internal team, use this skill.

For Word documents, PDFs, or memos, use the broader `probity-style` skill
instead. This one is decks only.

## How to use it

### 1. Set up the project

The template is a self-contained Quarto extension. Three ways to install it
into another project:

1. **Install script** (recommended): `./install.sh /path/to/your-project`
2. **`quarto add`**: point at the repo root (not `_extensions/` directly):
   `quarto add /path/to/probity_ppt --no-prompt`
3. **Manual**: copy `_extensions/`, `build/`, and `assets/` into the target
   project and add post-render hooks to `_quarto.yml`.

If the deck lives in a subdirectory, the project root must have a `_quarto.yml`
or Quarto will not discover the extension. See `README.md` for details.

Then create a `.qmd` with this front matter:

```yaml
---
title: "Deck title"
subtitle: "A short, factual subtitle"
author: "Author Name, Role"
date: today
date-format: "D MMMM YYYY"
format: probity-pptx-pptx
---
```

The format key is `probity-pptx-pptx` (extension name `probity-pptx`, base
format `pptx`).

### 2. Write slides in Markdown

The deck uses **slide-level 2**. This is the single most important rule for
getting layouts right:

| Markdown | Produces | Layout |
|---|---|---|
| Front-matter `title`/`subtitle`/`author` | Opening title slide | Title Slide (navy) |
| `# Heading` (level 1) | Section divider | Section Header (navy) |
| `## Heading` (level 2) | Content slide | Title and Content (white) |
| `## Heading` + `::: {.columns}` | Two-column slide | Two Content (white) |

So: **`#` gives a navy divider, `##` gives a white content slide.** There is no
`.section` class in PowerPoint output: do not use one. Do not put body text
directly under a `#` heading, or pandoc emits a stray extra slide. Keep section
dividers heading-only.

A worked example deck lives in `template.qmd` at the repo root. Read it before
writing a new deck.

### 3. Slide patterns

**Content slide:**

```markdown
## Lead with the answer

- Short bullets, sentence case, no terminal full stops on fragments
- One idea per slide
- State sample sizes and limitations openly
```

**Two columns** (use for claim/evidence or before/after pairs):

```markdown
## Two columns

::: {.columns}
::: {.column width="50%"}
**Left lead-in.** Body text.
:::
::: {.column width="50%"}
**Right lead-in.** Body text.
:::
:::
```

**Table** (renders with a navy header row and tinted alternating rows
automatically):

```markdown
| Variable       | Lag   | Correlation |
|----------------|-------|-------------|
| GDP growth     | lag-1 | -0.93       |

: Caption, FY 2019/20 to FY 2023/24 {tbl-colwidths="[40,20,40]"}
```

**Native charts** from R or Python. Use Probity chart colours so the figure
matches the deck:

```{r}
#| echo: false
#| fig-cap: "Caption"
library(ggplot2)
ggplot(df, aes(year, value)) +
  geom_col(fill = "#0A325A", width = 0.6) +
  theme_minimal(base_family = "Calibri") +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(colour = "#D5DEE9", linewidth = 0.3),
    axis.text = element_text(colour = "#6B7280")
  )
```

Keep figures at or below the default `fig-height` (4.0 in). Taller figures
overflow into the slide title, because pandoc centres a lone figure in the
content area. If a figure must be tall, give the slide no title (`##` with an
empty heading is not allowed, so instead split the content).

### 3a. Stat cards and three-card rows (custom patterns)

Pandoc cannot draw boxes, and it silently drops the third of three columns. So
two branded patterns are produced by a post-render step
(`build/probity_cards.py`) instead of by pandoc. You write a marker plus a
bullet list; the script replaces the slide body with drawn cards.

The `::` token separates fields. Prefix one label with `*` to make that card the
gold emphasis variant (use it once per row, for the single most important
figure).

**Stat callout row** (`[[statcards]]`, fields: `label :: number :: description`):

```markdown
## Headline numbers

[[statcards]]

- Sample :: 6 :: Fiscal-year observations the model is fitted on
- Fit :: 0.86 :: R-squared on lag-1 GDP
- *Multiplier :: R 14.9M :: Applied provision uplift
```

Renders as white cards with a navy top edge, an uppercase muted label, a large
navy number, and a description. The `*` card becomes navy fill with a gold
label and white number.

**Three-card row** (`[[cards]]`, fields: `label :: body`):

```markdown
## Three steps

[[cards]]

- Estimate :: Fit the model and record the sign against theory.
- Stress :: Drop the anomaly and refit. Report how far the fit moves.
- Apply :: Scale every cell of the provision matrix by the multiplier.
```

Renders as off-white cards with a navy left accent edge, a navy bold label, and
body text. Two to four cards per row work; the width adapts.

**Requirement.** Card slides only render if the project runs the post-render
hook. That needs `_quarto.yml` with:

```yaml
project:
  post-render:
    - python3 build/probity_cards.py
```

and the `build/probity_cards.py` script present. Both ship in this repository.
If you copy only `_extensions/` and `assets/` into another project, also copy
`build/probity_cards.py` and add the hook, or run the script by hand after
rendering:

```bash
python3 build/probity_cards.py deck.pptx
```

Without the hook, a `[[statcards]]` slide renders as a plain bullet list, which
is a safe fallback but not the branded card layout.

### 4. Render

```bash
quarto render deck.qmd
```

Output is `deck.pptx`. Quarto picks up `format: probity-pptx-pptx` and applies
the reference document automatically.

### 5. Visual QA

Always check the rendered slides, do not trust the source alone:

```bash
soffice --headless -env:UserInstallation=file:///tmp/loprofile \
  --convert-to pdf --outdir /tmp deck.pptx
pdftoppm -jpeg -r 80 /tmp/deck.pdf /tmp/slide
```

Then read the `/tmp/slide-*.jpg` images. Check for: title/figure overlap,
text overflow, footer alignment, correct navy vs white layouts on dividers vs
content slides, chart colours.

### 6. Voice pass

Before declaring done, grep the source for voice violations and fix them:

- em dashes (`—`): replace with a colon, comma, full stop, or parentheses
- US spellings: `color`, `analyze`, `behavior`, `defense`, `organization`,
  `program` (when it means organisation/programme)
- banned constructions: `leverage`, `delve into`, `utilise`, `robust` (vague),
  `seamless`, `holistic`, `in order to`, `prior to`

## Brand reference

| Element | Value |
|---|---|
| Primary navy | `#0A325A` |
| Deep navy | `#062340` |
| Mid blue | `#4A7BA8` |
| Light blue | `#8BABCB` |
| Pale blue tint | `#E8EEF5` |
| Off-background | `#F7F9FC` |
| Gold accent | `#C8881F` |
| Body text | `#1F2937` |
| Muted text | `#6B7280` |
| Rule / hairline | `#D5DEE9` |
| Font | Calibri |
| Mono / code | Consolas |

Palette discipline: **navy dominates** (about 70% weight): titles, table
headers, chart bars, hairlines. **Gold is the accent only**: the left stripe
and rule on title and divider slides, the subtitle on dark slides, the single
most important number in a stat group. Never use gold for body text or chart
fills.

Voice rules: no em dashes, UK spelling, plain register, short sentences, lead
with the answer then the qualification, state limitations openly. Money:
`R 14,903,239` in tables, `R 14.9M` in prose. Percentages: `12.5%` (no space).
Fiscal years: `FY 2024/25`. Dates: `2024-06-30` in tables, "30 June 2024" in
prose.

Avoid the AI-slop tells: no accent lines under titles, no cream backgrounds, no
generic blue gradients, no emoji, no decorative full-width bars. The small logo
plus a hairline rule is the only chrome a content slide needs.

## What the template gives you (built into reference.pptx)

- **Title slide and section dividers**: full navy background, gold left stripe,
  white logo top-left, white left-aligned title, gold subtitle, gold anchor
  rule.
- **Content slides**: white background, small navy logo top-left, hairline rule
  below it, navy left-aligned title, navy "Probity Data Analytics" footer
  wordmark.
- **Tables**: navy header row, white bold header text, pale-blue alternating
  rows.
- **Stat cards and three-card rows**: drawn by the `build/probity_cards.py`
  post-render step from `[[statcards]]` / `[[cards]]` markers (see 3a).
- **Consolas for code**: inline code and fenced blocks. Pandoc hardcodes
  Courier for code; the `build/probity_fonts.py` post-render step swaps it to
  Consolas. Equations stay in the default math font (Cambria Math): native
  pptx math renders reliably that way.
- **Theme colours**: the full Probity palette mapped onto the Office theme, so
  any native chart or shape that uses theme accents picks up brand colours.
- Widescreen 16:9 (13.33 x 7.5 in).

## Logo assets

In `assets/`, referenced by the reference document:

- `logo_white.png`: white-line logo, used on navy title and divider slides
- `logo_navy_small.png`: small navy logo, used on white content slides
- `logo_trim.png`: whitespace-trimmed navy logo (for other uses)
- `logo.png`: full original-quality logo

## Rebuilding the reference document

The branded `reference.pptx` is generated, not hand-edited. If the brand or
layouts change, edit `build/build_reference.py` and run it:

```bash
python3 build/build_reference.py
```

It starts from pandoc's default reference (`pandoc -o ... --print-default-data-file
reference.pptx`), rewrites the theme colour scheme to the Probity palette,
repositions the master placeholders, and decorates each layout with the navy
chrome, logos, and hairlines. Do not edit `reference.pptx` by hand in
PowerPoint: changes there will be lost on the next rebuild.

## Common pitfalls

- **`#` vs `##`.** Level-1 is a navy divider, level-2 is a white content slide.
  Mixing these up is the most common error.
- **Body under a `#` heading** produces a stray extra slide. Dividers are
  heading-only.
- **Tall figures overlap the title.** Keep `fig-height` at or below 4.0 in.
- **Do not pass `reference-doc` yourself.** The extension sets it. Overriding it
  drops the branding.
- **Card slides need the post-render hook.** A `[[statcards]]` or `[[cards]]`
  slide without `_quarto.yml` + `build/probity_cards.py` falls back to a plain
  bullet list. Use `::` between fields and `*` for the one gold card.
- **Calibri and Consolas must be installed** for exact rendering. Without them
  the theme falls back to a system sans / mono, which is acceptable but not
  identical.
