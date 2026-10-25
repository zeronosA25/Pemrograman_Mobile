#!/usr/bin/env python3
"""Post-process pandoc HTML so the cover page appears before the table of contents."""

import pathlib
import sys

src = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".tmp-brd-mobile.html")
dst = pathlib.Path(sys.argv[2] if len(sys.argv) > 2 else ".tmp-brd-mobile.final.html")

html = src.read_text(encoding="utf-8")

start = html.index('<div class="cover">')
end = html.index("</div>", start) + len("</div>")
cover = html[start:end]

html = html[:start] + html[end:]

toc_marker = '<nav id="TOC"'
pos = html.index(toc_marker)
html = html[:pos] + cover + "\n\n" + html[pos:]

html = html.replace(
    "<title>BRD-MOBILE-v1.0</title>",
    "<title>Business Requirement Document - Aplikasi Mobile Workout GYM untuk Pemula</title>",
)

dst.write_text(html, encoding="utf-8")
print(f"written: {dst} ({len(html)} bytes)")
