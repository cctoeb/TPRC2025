#!/bin/bash

ROOT_DIR="${1:-.}"
MASTER_INDEX="$ROOT_DIR/index.html"

folders_with_html=()

# Function to generate index.html in a given folder
generate_subfolder_index() {
  local folder="$1"
  local rel_self="${folder#$ROOT_DIR/}"  # relative folder path
  local index_file="$folder/index.html"

  echo "Generating index in: $folder"

  {
    echo "<!DOCTYPE html>"
    echo "<html><head><meta charset=\"UTF-8\"><title>Index of ${rel_self}</title></head><body>"
    echo "<h2>Index of ${rel_self:-.}</h2>"

    # List .html files in this folder
    echo "<h3>Files</h3><ul>"
    for file in "$folder"/*.html; do
      if [[ -f "$file" && "$(basename "$file")" != "index.html" ]]; then
        fname=$(basename "$file")
        echo "  <li><a href=\"$fname\">$fname</a></li>"
      fi
    done
    echo "</ul>"

    # List all other folders
    echo "<h3>Other Folders</h3><ul>"
    for other_folder in "${folders_with_html[@]}"; do
      [[ "$other_folder" == "$rel_self" ]] && continue
      echo "  <li><a href=\"../$other_folder/index.html\">$other_folder</a></li>"
    done
    echo "</ul></body></html>"
  } > "$index_file"
}

# Find subfolders with .html files
find "$ROOT_DIR" -type d ! -path '*/.*' | while read -r dir; do
  shopt -s nullglob
  html_files=("$dir"/*.html)
  if [ ${#html_files[@]} -gt 0 ]; then
    rel_path="${dir#$ROOT_DIR/}"   # relative path from root
    folders_with_html+=("$rel_path")
  fi
  shopt -u nullglob
done

# Now generate index.html for all folders
for folder in "${folders_with_html[@]}"; do
  generate_subfolder_index "$ROOT_DIR/$folder"
done

# Generate master index
echo "Generating master index: $MASTER_INDEX"

{
  echo "<!DOCTYPE html>"
  echo "<html><head><meta charset=\"UTF-8\"><title>Master Index</title></head><body>"
  echo "<h1>Master Index</h1>"
  echo "<h3>Folders</h3><ul>"

  for folder in "${folders_with_html[@]}"; do
    echo "  <li><a href=\"$folder/index.html\">$folder</a></li>"
  done

  echo "</ul></body></html>"
} > "$MASTER_INDEX"

echo "✅ All indexes generated, including cross-linked folders."

