# HOW-TO — Gestalt Book Project

This is a concise, practical guide to daily tasks.

---

## 1) Edit chapters in Markdown
- Open the chapter folder (e.g., `chapters/01-gestalt/`)
- Edit `chapter.md`; first line is the title:
  ```markdown
  # Gestalt
  ```
- Keep figures in `images/`, tables in `tables/`
- Update `chapter-refs.bib` by exporting from Zotero (Better BibTeX)

---

## 2) Create a Preface (unnumbered)
- Use `chapters/preface/chapter.md`
- It is included in the book’s `\frontmatter` and remains unnumbered
- If you want a visible heading in the Preface output:
  - Insert `\chapter*{Preface}` in the generated `.tex` (optional)

---

## 3) Convert `.md → .tex` (manual, optional)
Pandoc keeps both files in the same chapter folder:
```bash
cd chapters/01-gestalt
pandoc chapter.md   --citeproc   --csl ../../styles/apa-en-IN.csl   --bibliography=chapter-refs.bib   -o chapter.tex
```
The build script does this for you automatically.

---

## 4) Build a Chapter or the Book
- **Single chapter PDF**
  ```bash
  ./build.sh chapter 01
  ```
  Output → `outputs/pdf/01-gestalt-chapter.pdf`

- **Whole book**
  ```bash
  ./build.sh book alpha
  ./build.sh book beta epub
  ```
  Outputs → `outputs/pdf/book-*.pdf` and optional `outputs/epub/book-*.epub`

---

## 5) Insert Tables, Figures, Citations
- **Tables**
  ```markdown
  | Column A | Column B |
  |---------:|:---------|
  |     123  | text     |
  ```
- **Figures**
  ```markdown
  ![Caption](images/figure1.png){width=70%}
  ```
- **Citations (APA)**
  ```markdown
  Gestalt principles emerged in Berlin [@kohler1929, p. 17].
  ```

---

## 6) Backups & GitHub Versioning
- **Local snapshot**
  ```bash
  cp -r gestalt-book ~/backups/gestalt-book-$(date +%Y%m%d)
  ```
- **GitHub (recommended)**
  ```bash
  git init
  git remote add origin https://github.com/yourusername/gestalt-book.git
  git add .
  git commit -m "Edit Chapter 1"
  git push origin main
  ```
`.gitignore` already excludes generated outputs and LaTeX aux files.

---

## 7) What the Bash Script Does (`build.sh`)
- `./build.sh chapter <NN>`:
  - Converts `chapter.md → chapter.tex`
  - Sets bibliography header to **“References — Chapter NN: <Title>”**
  - Compiles PDF via `main_chapter.tex`

- `./build.sh book <alpha|beta> [epub]`:
  - Compiles `main_book.tex` (book class)
  - Builds **Index & Glossary** (runs `makeglossaries` and re‑compiles)
  - Optionally builds **EPUB** from concatenated Markdown chapters
  - Outputs to `outputs/pdf/` and `outputs/epub/`

---

## 8) Switching APA Locale / LaTeX Engine
- APA locale/style:
  ```bash
  CSL=styles/apa-en-US.csl ./build.sh book alpha
  ```
- LaTeX engine:
  ```bash
  PDF_ENGINE=xelatex ./build.sh chapter 01
  ```
