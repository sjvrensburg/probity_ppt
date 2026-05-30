#!/usr/bin/env bash
# install.sh — install the Probity PowerPoint extension into a target project.
#
# Usage:
#   ./install.sh /path/to/your-project
#
# This script:
#   1. Copies _extensions/probity-pptx/ into the target project.
#   2. Copies build/ scripts (probity_cards.py, probity_fonts.py) into the target.
#   3. Copies assets/ into the target (used by the reference document).
#   4. Creates or updates _quarto.yml with the required post-render hooks.
#   5. Validates the installation.
#
# Requirements:
#   - Run from the probity_ppt repository root.
#   - Target directory must exist.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
EXTENSION="$HERE/_extensions/probity-pptx"
BUILD="$HERE/build"
ASSETS="$HERE/assets"

# ---- argument parsing -------------------------------------------------------
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <target-project-directory>" >&2
    exit 1
fi

TARGET="$(cd "$1" 2>/dev/null && pwd)" || {
    echo "ERROR: target directory '$1' does not exist." >&2
    exit 1
}

echo "Installing Probity PowerPoint extension into: $TARGET"

# ---- validation: source must contain the extension --------------------------
if [[ ! -f "$EXTENSION/_extension.yml" ]]; then
    echo "ERROR: _extension.yml not found at $EXTENSION" >&2
    echo "       Run this script from the probity_ppt repository root." >&2
    exit 1
fi

if [[ ! -f "$EXTENSION/reference.pptx" ]]; then
    echo "ERROR: reference.pptx not found at $EXTENSION" >&2
    exit 1
fi

if [[ ! -f "$BUILD/probity_cards.py" ]]; then
    echo "ERROR: build/probity_cards.py not found at $BUILD" >&2
    exit 1
fi

if [[ ! -f "$BUILD/probity_fonts.py" ]]; then
    echo "ERROR: build/probity_fonts.py not found at $BUILD" >&2
    exit 1
fi

# ---- step 1: copy extension -------------------------------------------------
echo "  Copying extension..."
mkdir -p "$TARGET/_extensions"
cp -r "$EXTENSION" "$TARGET/_extensions/probity-pptx"

# ---- step 2: copy build scripts ---------------------------------------------
echo "  Copying build scripts..."
mkdir -p "$TARGET/build"
cp "$BUILD/probity_cards.py" "$TARGET/build/probity_cards.py"
cp "$BUILD/probity_fonts.py" "$TARGET/build/probity_fonts.py"

# ---- step 3: copy assets ----------------------------------------------------
echo "  Copying assets..."
cp -r "$ASSETS" "$TARGET/assets"

# ---- step 4: set up _quarto.yml ---------------------------------------------
QUARTO_YML="$TARGET/_quarto.yml"

need_post_render=true
if [[ -f "$QUARTO_YML" ]]; then
    if grep -q "probity_cards.py" "$QUARTO_YML" 2>/dev/null; then
        need_post_render=false
        echo "  _quarto.yml already has post-render hooks (skipping)."
    fi
fi

if $need_post_render; then
    echo "  Updating _quarto.yml with post-render hooks..."

    # Use python to safely merge YAML if possible, otherwise append
    if command -v python3 &>/dev/null; then
        python3 - "$QUARTO_YML" <<'PYEOF'
import sys, os

path = sys.argv[1]
hooks = """project:
  post-render:
    - python3 build/probity_cards.py
    - python3 build/probity_fonts.py
"""

if not os.path.exists(path):
    with open(path, "w") as f:
        f.write(hooks)
    sys.exit(0)

with open(path, "r") as f:
    content = f.read()

# Check if project: section exists
if "project:" in content:
    # Check if post-render: exists under project:
    if "post-render:" in content:
        # Append hooks to existing post-render list
        cards = "    - python3 build/probity_cards.py"
        fonts = "    - python3 build/probity_fonts.py"
        if "probity_cards.py" not in content:
            # Find the post-render line and add after it
            lines = content.split("\n")
            new_lines = []
            for line in lines:
                new_lines.append(line)
                if "post-render:" in line:
                    new_lines.append(cards)
                    new_lines.append(fonts)
            content = "\n".join(new_lines)
    else:
        # Add post-render under project:
        content = content.replace("project:", "project:\n  post-render:\n    - python3 build/probity_cards.py\n    - python3 build/probity_fonts.py", 1)
        # Remove duplicate project key if the original had children
        lines = content.split("\n")
        seen_project = False
        cleaned = []
        for line in lines:
            if line.strip().startswith("project:"):
                if seen_project:
                    continue
                seen_project = True
            cleaned.append(line)
        content = "\n".join(cleaned)
else:
    # No project section; prepend
    content = hooks + "\n" + content

with open(path, "w") as f:
    f.write(content)
PYEOF
    else
        # Fallback: append if no python3
        if [[ ! -f "$QUARTO_YML" ]]; then
            cat > "$QUARTO_YML" <<'YAML'
project:
  post-render:
    - python3 build/probity_cards.py
    - python3 build/probity_fonts.py
YAML
        else
            echo "" >> "$QUARTO_YML"
            echo "project:" >> "$QUARTO_YML"
            echo "  post-render:" >> "$QUARTO_YML"
            echo "    - python3 build/probity_cards.py" >> "$QUARTO_YML"
            echo "    - python3 build/probity_fonts.py" >> "$QUARTO_YML"
            echo "  WARNING: _quarto.yml was appended to. Check for duplicate 'project:' keys." >&2
        fi
    fi
fi

# ---- step 5: validate -------------------------------------------------------
echo ""
echo "Validating installation..."

errors=0

if [[ ! -f "$TARGET/_extensions/probity-pptx/_extension.yml" ]]; then
    echo "  FAIL: _extension.yml missing" >&2
    errors=$((errors + 1))
else
    echo "  OK: _extension.yml present"
fi

if [[ ! -f "$TARGET/_extensions/probity-pptx/reference.pptx" ]]; then
    echo "  FAIL: reference.pptx missing" >&2
    errors=$((errors + 1))
else
    echo "  OK: reference.pptx present"
fi

if [[ ! -f "$TARGET/build/probity_cards.py" ]]; then
    echo "  FAIL: build/probity_cards.py missing" >&2
    errors=$((errors + 1))
else
    echo "  OK: build/probity_cards.py present"
fi

if [[ ! -f "$TARGET/build/probity_fonts.py" ]]; then
    echo "  FAIL: build/probity_fonts.py missing" >&2
    errors=$((errors + 1))
else
    echo "  OK: build/probity_fonts.py present"
fi

if [[ ! -f "$TARGET/_quarto.yml" ]]; then
    echo "  FAIL: _quarto.yml missing" >&2
    errors=$((errors + 1))
else
    if grep -q "probity_cards.py" "$TARGET/_quarto.yml"; then
        echo "  OK: _quarto.yml has post-render hooks"
    else
        echo "  FAIL: _quarto.yml missing post-render hooks" >&2
        errors=$((errors + 1))
    fi
fi

# ---- summary ----------------------------------------------------------------
echo ""
if [[ $errors -eq 0 ]]; then
    echo "Installation complete. Create a .qmd file with:"
    echo ""
    echo "  ---"
    echo "  title: \"Deck title\""
    echo "  format: probity-pptx-pptx"
    echo "  ---"
    echo ""
    echo "Then render with: quarto render your-deck.qmd"
else
    echo "Installation completed with $errors error(s). Check the output above." >&2
    exit 1
fi
