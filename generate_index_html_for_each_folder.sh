#!/bin/bash

# Function to generate index.html in a given directory
generate_index() {
  local dir="$1"
  local index_file="$dir/index.html"

  echo "Generating index for: $dir"

  {
    echo "<html><head><title>Index of $dir</title></head><body>"
    echo "<h2>Index of $dir</h2>"
    echo "<ul>"

    # List HTML files (excluding index.html)
    for f in "$dir"/*.html; do
      if [[ -f "$f" && "$(basename "$f")" != "index.html" ]]; then
        echo "  <li><a href=\"$(basename "$f")\">$(basename "$f")</a></li>"
      fi
    done

    # List subdirectories (exclude hidden)
    for sub in "$dir"/*/; do
      subname=$(basename "$sub")
      if [[ -d "$sub" && "$subname" != .* ]]; then
        echo "  <li><a href=\"$subname/index.html\">$subname/</a></li>"
      fi
    done

    echo "</ul></body></html>"
  } > "$index_file"
}

export -f generate_index

# Use find but exclude hidden directories
find . -type d \( ! -name '.*' \) -exec bash -c 'generate_index "$0"' {} \;

