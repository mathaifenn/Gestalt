#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Gestalt Book Builder — single entrypoint
# Usage:
#   ./build.sh chapter <NN>            # e.g., ./build.sh chapter 01
#   ./build.sh book <alpha|beta> [epub]
#
# Defaults:
#   - PDF engine: pdflatex  (override: PDF_ENGINE=xelatex)
#   - CSL style:  styles/apa-en-IN.csl (override: CSL=styles/apa-en-US.csl)
#   - Glossary/Index: ON for book builds, OFF for chapters (controlled in TeX masters)
#   - Terms auto-tag filter: tools/filters/tag_terms.lua if present (book EPUB only)
# ------------------------------------------------------------

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHAPTERS_DIR="$ROOT_DIR/chapters"
OUTPUT_PDF_DIR="$ROOT_DIR/outputs/pdf"
OUTPUT_EPUB_DIR="$ROOT_DIR/outputs/epub"
TOOLS_DIR="$ROOT_DIR/tools"
STYLES_DIR="$ROOT_DIR/styles"

# Configurables via environment variables
PDF_ENGINE="${PDF_ENGINE:-pdflatex}"
CSL="${CSL:-$STYLES_DIR/apa-en-IN.csl}"
PANDOC_OPTS=(
  --citeproc
  --csl "$CSL"
)

mkdir -p "$OUTPUT_PDF_DIR" "$OUTPUT_EPUB_DIR"

usage() {
  cat <<USAGE
Gestalt Book Builder

USAGE:
  ./build.sh chapter <NN>             Build a single chapter PDF (e.g., 01)
  ./build.sh book <alpha|beta> [epub] Build whole book PDF (and EPUB if specified)

ENV OVERRIDES:
  PDF_ENGINE=xelatex                  Use XeLaTeX
  CSL=styles/apa-en-US.csl            Switch citation locale/style

EXAMPLES:
  ./build.sh chapter 03
  ./build.sh book alpha
  ./build.sh book beta epub
USAGE
}

fail() { echo "Error: $*" >&2; exit 1; }

# Resolve a chapter folder by number prefix, e.g., 01 -> chapters/01-*
find_chapter_dir() {
  local num="$1"
  local match
  match=$(find "$CHAPTERS_DIR" -maxdepth 1 -type d -regex ".*/${num}-[^/]+$" | sort | head -n1 || true)
  [[ -n "$match" ]] && echo "$match" || return 1
}

# Extract H1 title from chapter.md (first line starting with '# ')
extract_h1_title() {
  local md="$1"
  awk '/^# /{sub(/^# /,""); print; exit}' "$md"
}

# Build a single chapter PDF
build_chapter() {
  local num="$1"
  local chapter_dir
  chapter_dir=$(find_chapter_dir "$num") || fail "Chapter prefix '$num' not found under chapters/"

  local md="$chapter_dir/chapter.md"
  local bib="$chapter_dir/chapter-refs.bib"
  local tex="$chapter_dir/chapter.tex"

  [[ -f "$md"  ]] || fail "Missing: $md"
  [[ -f "$bib" ]] || fail "Missing: $bib (export from Zotero as chapter-refs.bib)"

  echo "[1/3] Converting Markdown → LaTeX: $md"
  local title
  title=$(extract_h1_title "$md")
  local chap_label="References — Chapter ${num}: ${title:-Chapter}"

  pandoc "$md"         "${PANDOC_OPTS[@]}"         --bibliography="$bib"         --metadata reference-section-title="$chap_label"         -o "$tex"

  echo "[2/3] Compiling PDF via $PDF_ENGINE"
  (cd "$ROOT_DIR" &&         latexmk -quiet -$PDF_ENGINE -file-line-error -interaction=nonstopmode           -jobname="${num}-chapter"           "main_chapter.tex")

  mv "$ROOT_DIR/${num}-chapter.pdf" "$OUTPUT_PDF_DIR/$(basename "$chapter_dir")-chapter.pdf"
  echo "[3/3] Done → $OUTPUT_PDF_DIR/$(basename "$chapter_dir")-chapter.pdf"
}

# Build the whole book (PDF, and optional EPUB)
build_book() {
  local flavor="$1"   # alpha | beta
  local do_epub="${2:-}"

  [[ "$flavor" == "alpha" || "$flavor" == "beta" ]] || fail "Book flavor must be alpha or beta"

  echo "[1/3] Compiling Book PDF ($flavor) via $PDF_ENGINE"
  (cd "$ROOT_DIR" &&         latexmk -quiet -$PDF_ENGINE -file-line-error -interaction=nonstopmode           -jobname="book-$flavor" main_book.tex)

  mv "$ROOT_DIR/book-$flavor.pdf" "$OUTPUT_PDF_DIR/book-$flavor.pdf"
  echo "[2/3] PDF → $OUTPUT_PDF_DIR/book-$flavor.pdf"

  echo "[2.5/3] Building glossary & index (makeglossaries) and re-compiling"
  (cd "$ROOT_DIR" && makeglossaries "book-$flavor" || true)
  (cd "$ROOT_DIR" && \
    latexmk -quiet -$PDF_ENGINE -file-line-error -interaction=nonstopmode \
      -jobname="book-$flavor" main_book.tex)
  mv "$ROOT_DIR/book-$flavor.pdf" "$OUTPUT_PDF_DIR/book-$flavor.pdf"

  if [[ "$do_epub" == "epub" ]]; then
    echo "[3/3] Generating EPUB"
    local epub_out="$OUTPUT_EPUB_DIR/book-$flavor.epub"
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    # Concatenate chapters by numeric order
    find "$CHAPTERS_DIR" -maxdepth 1 -type d -regex ".*/[0-9]{2}-[^/]+$" | sort | while read -r d; do
      if [[ -f "$d/chapter.md" ]]; then
        printf "\n\n" >> "$tmpdir/book.md"
        cat "$d/chapter.md" >> "$tmpdir/book.md"
      fi
    done

    [[ -s "$tmpdir/book.md" ]] || fail "No chapter.md files found for EPUB build"

    pandoc "$tmpdir/book.md"           "${PANDOC_OPTS[@]}"           --metadata-file="$STYLES_DIR/pandoc.yaml"           ${COVER:+--epub-cover-image="$COVER"}           -o "$epub_out"

    echo "EPUB → $epub_out"
  fi
}

main() {
  [[ $# -ge 2 ]] || { usage; exit 1; }
  local cmd="$1"; shift
  case "$cmd" in
    chapter)
      [[ $# -eq 1 ]] || { usage; exit 1; }
      build_chapter "$1" ;;
    book)
      local flavor="$1"; shift
      local maybe_epub="${1:-}"
      build_book "$flavor" "$maybe_epub" ;;
    *)
      usage; exit 1 ;;
  esac
}

main "$@"
