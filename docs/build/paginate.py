#!/usr/bin/env python3
"""Inject page numbers into the pandoc TOC by locating each heading in the rendered PDF."""

import html
import pathlib
import re
import sys

import pypdfium2 as pdfium

html_in = pathlib.Path(sys.argv[1])
pdf_in = pathlib.Path(sys.argv[2])
html_out = pathlib.Path(sys.argv[3])

doc_text = html_in.read_text(encoding="utf-8")

pdf = pdfium.PdfDocument(str(pdf_in))
pages = [pdf[i].get_textpage().get_text_range() for i in range(len(pdf))]


def norm(value: str) -> str:
    return re.sub(r"\s+", " ", html.unescape(value)).strip()


page_text = [norm(t) for t in pages]

body_start = 0
for idx, text in enumerate(page_text):
    if "Riwayat Revisi" in text and "Dokumen awal BRD versi" in text:
        body_start = idx
        break

toc_start = doc_text.index('<nav id="TOC"')
toc_end = doc_text.index("</nav>", toc_start) + len("</nav>")
toc_block = doc_text[toc_start:toc_end]

anchor_re = re.compile(r'<a href="#([^"]+)"[^>]*>(.*?)</a>', re.S)

entries = []
for match in anchor_re.finditer(toc_block):
    anchor, inner = match.group(1), match.group(2)
    title = norm(re.sub(r"<[^>]+>", "", inner))
    entries.append((anchor, title))

assigned = {}
prev = body_start
for anchor, title in entries:
    found = None
    for idx in range(prev, len(page_text)):
        if title and title in page_text[idx]:
            found = idx
            break
    if found is None:
        for idx in range(body_start, len(page_text)):
            if title and title in page_text[idx]:
                found = idx
                break
    if found is not None:
        assigned[anchor] = found + 1
        prev = found

cleaned_toc = re.sub(r'<span class="toc-page">.*?</span>', "", toc_block)


def add_number(match: re.Match) -> str:
    anchor = match.group(1)
    attrs = match.group(2) or ""
    inner = match.group(3)
    page = assigned.get(anchor)
    label = f'<span class="toc-page">{page}</span>' if page else ""
    return f'<a href="#{anchor}"{attrs}>{inner}</a>{label}'


numbered_toc = re.sub(
    r'<a href="#([^"]+)"([^>]*)>(.*?)</a>', add_number, cleaned_toc, flags=re.S
)

html_out.write_text(
    doc_text[:toc_start] + numbered_toc + doc_text[toc_end:], encoding="utf-8"
)

missing = [f"{title} (#{anchor})" for anchor, title in entries if anchor not in assigned]
print(f"toc entries: {len(entries)}, numbered: {len(assigned)}, missing: {len(missing)}")
for item in missing[:5]:
    print("  missing:", item)
