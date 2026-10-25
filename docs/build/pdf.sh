#!/usr/bin/env bash
# Build docs/BRD-MOBILE-v1.0.pdf from the Markdown source.
set -euo pipefail

cd "$(dirname "$0")/.."
DOCS="$PWD"
CHROME="google-chrome"
PDF="$DOCS/BRD-MOBILE-v1.0.pdf"
TITLE="BRD Aplikasi Mobile Workout GYM untuk Pemula"

echo "[1/8] markdown -> html"
pandoc "BRD-MOBILE-v1.0.md" \
  -f markdown -t html5 -s \
  --toc --toc-depth=3 \
  --variable toc-title="Daftar Isi" \
  --css build/brd-mobile.css \
  -o .tmp-brd-mobile.html 2>/dev/null

echo "[2/8] move cover before table of contents"
python3 build/render.py .tmp-brd-mobile.html .tmp-brd-mobile.final.html

render_pdf() {
  local source="$1"
  local target="$2"
  "$CHROME" --headless=new --no-sandbox --disable-gpu \
    --no-pdf-header-footer --virtual-time-budget=8000 \
    --print-to-pdf="$target" "file://$source" 2>/dev/null
}

echo "[3/8] render pass 1"
render_pdf "$DOCS/.tmp-brd-mobile.final.html" "$DOCS/.tmp-pass1.pdf"

echo "[4/8] stamp page numbers (pass 1)"
python3 build/stamp_pages.py .tmp-pass1.pdf .tmp-pass1s.pdf "$TITLE"

echo "[5/8] compute table-of-contents page numbers"
python3 build/paginate.py .tmp-brd-mobile.final.html .tmp-pass1s.pdf .tmp-brd-mobile.paged.html

echo "[6/8] render pass 2"
render_pdf "$DOCS/.tmp-brd-mobile.paged.html" "$DOCS/.tmp-pass2.pdf"

echo "[7/8] stamp final pdf"
python3 build/stamp_pages.py .tmp-pass2.pdf "$PDF" "$TITLE"

echo "[8/8] verify toc mapping"
python3 build/paginate.py .tmp-brd-mobile.paged.html "$PDF" .tmp-verify.html >/dev/null
python3 - <<'PY'
import re
from pathlib import Path

a = re.findall(r'<span class="toc-page">(\d+)</span>', Path(".tmp-brd-mobile.paged.html").read_text())
b = re.findall(r'<span class="toc-page">(\d+)</span>', Path(".tmp-verify.html").read_text())
mismatch = [(x, y) for x, y in zip(a, b) if x != y]
print(f"toc entries: {len(a)}, mismatched pages: {len(mismatch)}")
for x, y in mismatch[:5]:
    print(f"  injected {x} vs detected {y}")
PY

echo "done: $PDF"
