# Disaster Recovery — Gestalt Book Project

If your hard disk crashes or you move to a new machine, follow these steps to fully restore the project from GitHub.

---

## 1. Install prerequisites (Ubuntu)

```bash
sudo apt update
sudo apt install -y pandoc pandoc-citeproc make latexmk texlive-full git
```

Optional but recommended:
- Zotero + Better BibTeX plugin (for managing citations)

---

## 2. Clone the repository

```bash
cd ~/Documents/Latex
git clone https://github.com/mathaifenn/Gestalt.git gestalt-book
cd gestalt-book
```

---

## 3. Make build script executable

```bash
chmod +x build.sh
```

---

## 4. Test a build

Single chapter:
```bash
./build.sh chapter 01
```

Whole book:
```bash
./build.sh book alpha
```

Whole book with EPUB:
```bash
./build.sh book beta epub
```

---

## 5. What is restored?

- All committed Markdown files (`chapter.md`, README.md, HOW-TO.md, WORKFLOW.md, etc.)
- Bibliography files (`chapter-refs.bib`)
- LaTeX templates and style files (`main_book.tex`, `titlepage.tex`, etc.)
- Build script (`build.sh`)
- Git history and branches

> Note: LaTeX aux files (`*.aux`, `*.log`, etc.) and build outputs (`*.pdf`, `*.epub`) are ignored by design. They will be regenerated automatically.

---

## 6. Daily workflow after recovery

1. Edit Markdown files locally
2. Build with `./build.sh`
3. Commit & push:
   ```bash
   git add .
   git commit -m "Update Chapter X"
   git push
   ```

---

✨ This ensures you can always recover your full writing and build environment with just Git + LaTeX tools.
