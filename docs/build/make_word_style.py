#!/usr/bin/env python3
"""Derive the Word-style Markdown source from the branded BRD source."""

import pathlib
import re

DOCS = pathlib.Path(__file__).resolve().parent.parent
source = DOCS / "BRD-MOBILE-v1.0.md"
target = DOCS / "BRD-MOBILE-v1.0-word-style.md"

text = source.read_text(encoding="utf-8")

start = text.index('<div class="cover">')
end = text.index("</div>", start) + len("</div>")
text = text[:start] + text[end:]

revision_start = text.index("## Riwayat Revisi")
body_start = text.index("## 1. Ringkasan Eksekutif", revision_start)
text = text[:revision_start] + text[body_start:]

# The original BRD uses bullet lists in these chapters; mirror that style.
bullet_sections = [
    ("### 2.2 Permasalahan", "### 2.3 Solusi yang Diusulkan"),
    ("## 3. Tujuan Bisnis", "## 4. Ruang Lingkup"),
    ("## 8. Arsitektur Tingkat Tinggi", "## 9. Model Data Ringkas"),
    ("## 10. Alur Proses Bisnis Ringkas", "## 11. Teknologi"),
    ("## 12. Asumsi", "## 13. Risiko & Mitigasi"),
    ("## 14. Kriteria Penerimaan", "## 15. Diagram Use Case"),
]

for section_start, section_end in bullet_sections:
    start = text.index(section_start)
    end = text.index(section_end, start)
    block = re.sub(r"(?m)^\d+\.\s+", "- ", text[start:end])
    text = text[:start] + block + text[end:]

title_block = """<div class="doc-title">
<p>BUSINESS REQUIREMENT DOCUMENT (BRD)</p>
<p>Aplikasi Mobile Workout GYM untuk Pemula</p>
<p>Sistem Tutorial Workout untuk Pemula di GYM berbasis Mobile</p>
</div>

"""

text = title_block + text.lstrip("\n")

target.write_text(text, encoding="utf-8")
print(f"written: {target.name} ({len(text)} bytes)")
