#!/usr/bin/env bash
# Build the Word-style PDF (plain template that mirrors the original BRD).
set -euo pipefail

cd "$(dirname "$0")/.."
DOCS="$PWD"
PDF="$DOCS/BRD-MOBILE-v1.0-word-style.pdf"

echo "[1/3] derive markdown source"
python3 build/make_word_style.py

echo "[2/3] markdown -> html"
pandoc "BRD-MOBILE-v1.0-word-style.md" \
  -f markdown -t html5 -s \
  --metadata pagetitle="Business Requirement Document (BRD) - Aplikasi Mobile Workout GYM untuk Pemula" \
  --css build/brd-word.css \
  -o .tmp-word.html 2>/dev/null

echo "[3/3] html -> pdf"
google-chrome --headless=new --no-sandbox --disable-gpu \
  --no-pdf-header-footer --virtual-time-budget=8000 \
  --print-to-pdf="$PDF" "file://$DOCS/.tmp-word.html" 2>/dev/null

rm -f .tmp-word.html
echo "done: $PDF"
