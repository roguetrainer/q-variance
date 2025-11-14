#!/bin/bash

# Define destination directories
SRC_DIR="src"
DOCS_DIR="docs"
NOTEBOOKS_DIR="notebooks"

# --- 1. Create destination directories if they don't exist ---
mkdir -p "$SRC_DIR"
mkdir -p "$DOCS_DIR"
mkdir -p "$NOTEBOOKS_DIR"

echo "Created/ensured existence of $SRC_DIR, $DOCS_DIR, and $NOTEBOOKS_DIR."
echo "---"

# --- 2. Move .py files to src folder ---
echo "Moving **.py** files to **$SRC_DIR** (overwriting if necessary)..."
# Finds all .py files and moves them, overwriting existing files in $SRC_DIR.
find . -maxdepth 1 -type f -name "*.py" -exec mv {} "$SRC_DIR/" \;
echo "Finished moving .py files."
echo "---"


# --- 3. Move .md files (excluding README.md) to docs folder ---
echo "Moving **.md** files (excluding README.md) to **$DOCS_DIR** (overwriting if necessary)..."
# Finds all .md files except README.md and moves them, overwriting existing files in $DOCS_DIR.
find . -maxdepth 1 -type f -name "*.md" ! -name "README.md" -exec mv {} "$DOCS_DIR/" \;
echo "Finished moving .md files."
echo "---"


# --- 4. Move .ipynb files to notebooks folder ---
echo "Moving **.ipynb** files to **$NOTEBOOKS_DIR** (overwriting if necessary)..."
# Finds all .ipynb files and moves them, overwriting existing files in $NOTEBOOKS_DIR.
find . -maxdepth 1 -type f -name "*.ipynb" -exec mv {} "$NOTEBOOKS_DIR/" \;
echo "Finished moving .ipynb files."
echo "---"

echo "✅ **All specified files have been moved successfully.**"