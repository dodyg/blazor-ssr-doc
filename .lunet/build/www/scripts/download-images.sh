#!/bin/bash
# download-images.sh
# Finds image references and downloads them

set -e

CONTENT_DIR="${1:-content}"
ASSETS_DIR="${2:-assets/images}"
BASE_URL="https://raw.githubusercontent.com/dotnet/AspNetCore.Docs/main/aspnetcore"

echo "========================================="
echo "Image Download Script"
echo "========================================="
echo "Content directory: $CONTENT_DIR"
echo "Assets directory: $ASSETS_DIR"
echo ""

# Create assets directory if it doesn't exist
mkdir -p "$ASSETS_DIR"

# Find all image references
echo "Finding image references..."
grep -roh '!\[.*\](.*\.\(png\|jpg\|gif\|svg\))' "$CONTENT_DIR" | \
    sed 's/!\[.*\](\(.*\))/\1/' | \
    sort | uniq > /tmp/image_refs.txt

echo "Found $(wc -l < /tmp/image_refs.txt) unique image references"
echo ""

# Process each image reference
while read -r img_ref; do
    # Clean up the reference
    img_ref=$(echo "$img_ref" | sed 's|^~/blazor/||' | sed 's|^/||' | sed 's|^~||')
    
    # Determine source URL
    if [[ "$img_ref" =~ ^http ]]; then
        # Already a full URL
        source_url="$img_ref"
        img_name=$(basename "$img_ref")
    elif [[ "$img_ref" =~ ^/ ]]; then
        # Absolute path - assume it's from the blazor directory
        source_url="$BASE_URL${img_ref}"
        img_name=$(basename "$img_ref")
    else
        # Relative path
        source_url="$BASE_URL/$img_ref"
        img_name=$(basename "$img_ref")
    fi
    
    # Clean image name
    img_name=$(echo "$img_name" | sed 's/?.*//')
    
    echo "Image: $img_name"
    echo "  Source: $source_url"
    
    # Download if it doesn't exist
    if [ ! -f "$ASSETS_DIR/$img_name" ]; then
        echo "  Downloading..."
        wget -q -O "$ASSETS_DIR/$img_name" "$source_url" && echo "  ✓ Success" || echo "  ✗ Failed"
    else
        echo "  ✓ Already exists"
    fi
    
done < /tmp/image_refs.txt

echo ""
echo "========================================="
echo "Updating image references in markdown..."
echo "========================================="

# Update image references in all markdown files
find "$CONTENT_DIR" -name "*.md" -type f | while read -r file; do
    # Update image paths to point to assets directory
    sed -i 's|!\[\(.*\)\](.*/\(.*\.\(png\|jpg\|gif\|svg\)\)|![\1](/assets/images/\2)|g' "$file"
done

echo ""
echo "========================================="
echo "Image Download Complete!"
echo "========================================="
echo "Images saved to: $ASSETS_DIR"
echo ""

# Cleanup
rm -f /tmp/image_refs.txt
