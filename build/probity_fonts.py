#!/usr/bin/env python3
"""Post-render step: set Consolas for code.

Pandoc's pptx writer hardcodes Courier for code runs (it ignores the reference
document's theme font). Probity house style uses Consolas for code. This script
rewrites the slide XML after render, replacing every Courier / Courier New run
typeface with Consolas.

Equations are left in the default math font (Cambria Math): native OMML math
renders reliably that way across PowerPoint and viewers, and forcing a
non-math font onto math runs is unreliable.

Run by Quarto's post-render hook, or by hand:

    python3 build/probity_fonts.py deck.pptx
"""
import os, re, sys, zipfile

MONO = "Consolas"
_courier = re.compile(r'typeface="Courier(?: New)?"')


def rewrite_slide(xml: str) -> str:
    return _courier.sub(f'typeface="{MONO}"', xml)


def process_file(path: str) -> None:
    tmp = path + ".tmp"
    touched = 0
    with zipfile.ZipFile(path) as zin, \
         zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.namelist():
            data = zin.read(item)
            if re.match(r"ppt/slides/slide\d+\.xml$", item):
                txt = data.decode("utf-8")
                new = rewrite_slide(txt)
                if new != txt:
                    touched += 1
                data = new.encode("utf-8")
            zout.writestr(item, data)
    os.replace(tmp, path)
    print(f"probity_fonts: Consolas for code on {touched} slide(s) in "
          f"{os.path.basename(path)}")


def main():
    files = sys.argv[1:]
    if not files:
        env = os.environ.get("QUARTO_PROJECT_OUTPUT_FILES", "")
        files = [f for f in env.splitlines() if f.strip()]
    for f in files:
        if f.lower().endswith(".pptx") and os.path.exists(f):
            process_file(f)


if __name__ == "__main__":
    main()
