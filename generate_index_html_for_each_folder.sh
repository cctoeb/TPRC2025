#!/bin/bash

# Root directory (defaults to current dir if not supplied)
ROOT_DIR="${1:-.}"
MASTER_INDEX="$ROOT_DIR/index.html"

# Store list of folders with .html files
folders_with_html=()

# Function to generate index.html in each folder
generate_subfolder_index() {
  local folder="$1"
  local index_file="$folder/index.html"

  echo "Generating index in: $folder"

  {
    echo "<!DOCTYPE html>"
    echo "<html><head><meta charset=\"UTF-8\"><title>Index of ${folder}</title></head><body>"
    echo "<h2>Index of ${folder}</h2>"
    echo "<ul>"

    for file in "$folder"/*.html; do
      if [[ -f "$file" && "$(basename "$file")" != "index.html" ]]; then
        fname=$(basename "$file")
        echo "  <li><a href=\"$fname\">$fname</a></li>"
      fi
    done

    echo "</ul></body></html>"
  } > "$index_file"
}

# Traverse all subfolders
find "$ROOT_DIR" -type d ! -path '*/.*' | while read -r dir; do
  # Skip root folder itself for now
  [[ "$dir" == "$ROOT_DIR" ]] && continue

  shopt -s nullglob
  html_files=("$dir"/*.html)
  if [ ${#html_files[@]} -gt 0 ]; then
    generate_subfolder_index "$dir"
    rel_path="${dir#$ROOT_DIR/}"   # relative path from root
    folders_with_html+=("$rel_path")
  fi
  shopt -u nullglob
done

# Generate master index at root
echo "Generating master index: $MASTER_INDEX"

{
  echo "<!DOCTYPE html>"
  echo "<html><head><meta charset=\"UTF-8\"><title>Master Index</title></head><body>"
  echo "<h1>Master Index</h1>"
  echo "<ul>"

  for folder in "${folders_with_html[@]}"; do
    echo "  <li><a href=\"$folder/index.html\">$folder</a></li>"
  done

  echo "</ul></body></html>"
} > "$MASTER_INDEX"

echo "✅ Done generating all indexes."
