#!/bin/bash
# process-content.sh
# Processes extracted markdown files for the Blazor SSR documentation site

set -e

CONTENT_DIR="${1:-content}"

echo "========================================="
echo "Content Processing Script"
echo "========================================="
echo "Processing directory: $CONTENT_DIR"
echo ""

# Counter
processed=0

# Process each markdown file (excluding index.md which is custom)
find "$CONTENT_DIR" -name "*.md" -type f ! -name "index.md" | while read -r file; do
    echo "Processing: $file"
    
    # Get the relative path from content directory
    rel_path="${file#$CONTENT_DIR/}"
    dir_name=$(dirname "$rel_path")
    base_name=$(basename "$rel_path" .md)
    
    # Determine section based on directory
    section="Documentation"
    case "$dir_name" in
        "getting-started"|"")
            section="Getting Started"
            ;;
        "fundamentals")
            section="Fundamentals"
            ;;
        "components")
            section="Components"
            ;;
        "forms")
            section="Forms"
            ;;
        "security")
            section="Security"
            ;;
        "advanced")
            section="Advanced"
            ;;
    esac
    
    # Extract title from existing frontmatter
    title=$(grep -m 1 "^title:" "$file" | sed 's/title: *//' | tr -d '"')
    if [ -z "$title" ]; then
        title="$base_name"
    fi
    
    # Extract description from existing frontmatter
    description=$(grep -m 1 "^description:" "$file" | sed 's/description: *//' | tr -d '"')
    
    # Create new frontmatter
    temp_file=$(mktemp)
    
    # Write new frontmatter
    cat > "$temp_file" << EOF
---
title: $title
description: ${description:-Documentation for Blazor SSR}
layout: page
section: $section
toc: true
---

EOF
    
    # Skip old frontmatter (everything between --- and ---)
    awk '
        BEGIN { in_frontmatter=0; first_dash=0; }
        /^---$/ && first_dash==0 { first_dash=1; in_frontmatter=1; next; }
        /^---$/ && in_frontmatter==1 { in_frontmatter=0; next; }
        in_frontmatter==0 { print; }
    ' "$file" >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
    
    processed=$((processed + 1))
done

echo ""
echo "========================================="
echo "Processing Complete!"
echo "========================================="
echo "Files processed: $processed"
echo ""
echo "✨ Next steps:"
echo "  1. Remove moniker ranges: Run scripts/remove-monikers.sh"
echo "  2. Convert xref links: Run scripts/convert-links.sh"
echo "  3. Download images: Run scripts/download-images.sh"
echo "  4. Filter WebAssembly content: Manual review"
echo ""
