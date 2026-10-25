#!/usr/bin/env python3
"""Stamp a footer with the document title and page number on every page except the cover."""

import io
import pathlib
import sys

from pypdf import PdfReader, PdfWriter
from reportlab.lib.colors import HexColor
from reportlab.pdfgen import canvas

pdf_in = pathlib.Path(sys.argv[1])
pdf_out = pathlib.Path(sys.argv[2])
title = sys.argv[3] if len(sys.argv) > 3 else "BRD Aplikasi Mobile Workout GYM untuk Pemula"

reader = PdfReader(str(pdf_in))
total = len(reader.pages)
writer = PdfWriter()

for index, page in enumerate(reader.pages):
    if index > 0:
        width = float(page.mediabox.width)
        buffer = io.BytesIO()
        overlay = canvas.Canvas(buffer, pagesize=(width, float(page.mediabox.height)))
        overlay.setStrokeColor(HexColor("#CBD5E1"))
        overlay.setLineWidth(0.5)
        overlay.line(51, 40, width - 45, 40)
        overlay.setFont("Helvetica", 7.5)
        overlay.setFillColor(HexColor("#64748B"))
        overlay.drawString(51, 29, title)
        label = f"Halaman {index + 1} dari {total}"
        overlay.drawRightString(width - 45, 29, label)
        overlay.save()
        buffer.seek(0)
        page.merge_page(PdfReader(buffer).pages[0])
    writer.add_page(page)

with open(pdf_out, "wb") as handle:
    writer.write(handle)

print(f"stamped: {pdf_out} ({total} pages)")
