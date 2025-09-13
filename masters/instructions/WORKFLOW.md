# WORKFLOW — Portable Gestalt Book Publishing (Markdown → LaTeX)

This repository is a **standalone** starter kit for writing your Gestalt book in **Markdown**, compiling with **Pandoc → LaTeX**, and producing **PDF** (and EPUB). It is designed to be flash‑drive portable and Ubuntu‑friendly.

---

## 0) Prerequisites (for new machines)
Already installed on your primary machine; install on others if needed:

- **Pandoc** (with citeproc)
- **TeX Live** (`texlive-full` recommended)
- **Zotero** + **Better BibTeX** plugin (for `.bib` auto‑export)
- Optional: **git** for GitHub versioning

Install on Ubuntu:
```bash
sudo apt update
sudo apt install -y pandoc pandoc-citeproc make latexmk texlive-full git
pandoc --version
```

---

## 1) Folder Tree (portable)
```
gestalt-book/
├─ build.sh
├─ main_book.tex
├─ main_chapter.tex
├─ chapters/
│  ├─ 01-gestalt/
│  │  ├─ chapter.md
│  │  ├─ chapter-refs.bib
│  │  ├─ images/
│  │  └─ tables/
│  └─ preface/
│     ├─ chapter.md
│     └─ chapter-refs.bib
├─ terms.yml
├─ masters/
│  ├─ templates/
│  │  └─ titlepage.tex
│  └─ instructions/
│     ├─ WORKFLOW.md   ← you are here
│     └─ HOW-TO.md
├─ styles/
│  ├─ apa-en-IN.csl
│  ├─ apa-en-US.csl
│  ├─ cover.png
│  └─ pandoc.yaml
├─ tools/
│  ├─ filters/
│  │  └─ tag_terms.lua
│  └─ makegloss.sh
└─ outputs/
   ├─ pdf/
   └─ epub/
```

**Naming conventions (strict):**
- Chapter file = `chapter.md`
- Chapter bibliography = `chapter-refs.bib`
- Folder prefix sets order: `01-…`, `02-…`, etc.

---

## 2) Authoring in Markdown (minimal but expressive)

**First line is the chapter title**:
```markdown
# Gestalt
```

**Footnotes**
```markdown
Text with a footnote.[^1]
[^1]: Footnote content.
```

**Figures**
```markdown
![Gestalt illustration](images/figure1.png){width=70%}
```

**Tables**
```markdown
| Column A | Column B |
|---------:|:---------|
|     123  | text     |
```

**Citations (APA)**
```markdown
Gestalt ideas emerged in Berlin [@kohler1929, p. 17].
```
Pandoc + `--citeproc` + `styles/apa-en-IN.csl` format these; the per‑chapter `.bib` is `chapter-refs.bib`.

---

## 3) Zotero → `chapter-refs.bib` (per chapter)
In Zotero, create a collection per chapter (or tag), then **Export** → **Better BibTeX** (`.bib`) and save to:
```
chapters/NN-slug/chapter-refs.bib
```
Enable Better BibTeX **auto‑export** to keep it updated.

---

## 4) Preface (unnumbered)
- Use `chapters/preface/chapter.md`
- It’s included in `\frontmatter` via `\include{chapters/preface/chapter}`
- Preface is **unnumbered** by design (you can add `\chapter*{Preface}` inside the generated .tex if you want the title styled without a number)

---

## 5) Terms, Glossary & Index (book builds)
- `terms.yml` holds your master vocabulary (keys, aliases, definitions).
- A Lua filter can auto‑tag terms during Pandoc conversion (placeholder provided).
- `main_book.tex` is already wired with `makeidx` and `glossaries`; the sample includes two entries (Gestalt, Pragnanz).

> Chapters **do not** build glossary/index. Book builds include them by default.

---

## 6) Metadata & Styles
- Default metadata is in `styles/pandoc.yaml` (title, author, publisher, language, rights, ISBN, cover).
- Switch APA style by changing the CSL:
  - Default: `styles/apa-en-IN.csl`
  - Alternate: `styles/apa-en-US.csl`
  - Override at build time: `CSL=styles/apa-en-US.csl ./build.sh book alpha`

---

## 7) Engines: `pdflatex` (default) ↔ `xelatex` (optional)
Default: **pdflatex**. To switch:
```bash
PDF_ENGINE=xelatex ./build.sh book alpha
```
Ensure system fonts are available if you later customize with `fontspec`.

---

## 8) Build Commands (single script)
```bash
./build.sh chapter 01         # Build chapter 01 (PDF)
./build.sh book alpha         # Build whole book (PDF)
./build.sh book beta epub     # Book PDF + EPUB
```

What happens in a **chapter build**:
- `pandoc` converts `chapter.md → chapter.tex` (same folder)
- The **References** section title is auto‑set to:  
  `References — Chapter NN: <Title>`
- LaTeX compiles `main_chapter.tex` and pulls in the chapter’s `.tex`

What happens in a **book build**:
- LaTeX compiles `main_book.tex` (includes Preface, then numbered chapters)
- **Index & Glossary** are built (via `makeglossaries` + re‑compile)
- EPUB (optional) concatenates chapter Markdown in numeric order

---

## 9) Version Control (GitHub)
This kit is ready for Git:
```bash
git init
git remote add origin https://github.com/yourusername/gestalt-book.git
git add .
git commit -m "Initial commit"
git push origin main
```
`.gitignore` excludes PDFs/EPUB/DOCX, LaTeX aux files, and `.txt`.

---

## 10) Portability
- All paths are **relative**, so you can run the kit directly from a flash drive.
- Builds write only to `outputs/`.

---

## 11) Troubleshooting
- **Missing citations:** Check `chapter-refs.bib` and keys; ensure `--citeproc` and correct CSL.
- **Images not found:** Use correct relative paths; Linux is case‑sensitive.
- **Glossary/Index empty:** Confirm `terms.yml` contents; ensure book build (not chapter).
- **LaTeX package issues:** Install `texlive-full` to avoid missing packages.
