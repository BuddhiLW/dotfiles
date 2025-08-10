#!/usr/bin/env bash
set -euo pipefail

# KISS: Warn if deps are missing; build if required ones are present.

DOC_DIR="$HOME/dotfiles/.config/documentation"
INPUT_MD="$DOC_DIR/xmonad-bindings-tables.md"
OUTPUT_PDF="$DOC_DIR/xmonad-bindings-tables.pdf"

missing=()

# Required for build
for bin in pandoc xelatex; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    missing+=("$bin")
  fi
done

# Optional check to warn about base TeX Live presence
if ! command -v pdflatex >/dev/null 2>&1; then
  echo "[warn] Missing optional dependency: pdflatex (texlive-base)" >&2
fi

if ((${#missing[@]} > 0)); then
  echo "[warn] Missing required dependencies: ${missing[*]}" >&2
  echo "[info] Please install: pandoc and TeX Live with XeLaTeX (package often named texlive-xetex)." >&2
  exit 1
fi

if [[ ! -f "$INPUT_MD" ]]; then
  echo "[error] Input markdown not found: $INPUT_MD" >&2
  exit 1
fi

pandoc "$INPUT_MD" -o "$OUTPUT_PDF" --toc --pdf-engine=xelatex
echo "[ok] Built: $OUTPUT_PDF"


