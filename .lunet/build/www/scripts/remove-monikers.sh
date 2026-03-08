#!/bin/bash
# remove-monikers.sh
# Removes moniker range blocks, keeping >= aspnetcore-8.0 content

set -e

CONTENT_DIR="${1:-content}"

echo "========================================="
echo "Moniker Range Removal Script"
echo "========================================="
echo "Processing directory: $CONTENT_DIR"
echo ""

find "$CONTENT_DIR" -name "*.md" -type f | while read -r file; do
    echo "Processing: $file"
    
    # Use awk to process moniker blocks
    # Keep content in >= aspnetcore-8.0 blocks
    # Remove content in < aspnetcore-8.0 blocks
    # Remove the moniker markers themselves
    
    awk '
        BEGIN { 
            in_keep_block=0; 
            in_remove_block=0; 
            skip_until_end=0;
        }
        
        # Start of moniker block to keep
        /:::moniker range=">= aspnetcore-8\.0"/ {
            in_keep_block=1;
            skip_until_end=0;
            next;
        }
        
        # Start of moniker block to remove
        /:::moniker range="< aspnetcore-8\.0"/ {
            in_remove_block=1;
            skip_until_end=1;
            next;
        }
        
        # End of any moniker block
        /:::moniker-end/ {
            if (in_keep_block || in_remove_block) {
                in_keep_block=0;
                in_remove_block=0;
                skip_until_end=0;
                next;
            }
        }
        
        # Print lines that are not in a removal block
        {
            if (skip_until_end == 0) {
                print;
            }
        }
    ' "$file" > "$file.tmp"
    
    mv "$file.tmp" "$file"
done

echo ""
echo "========================================="
echo "Moniker Removal Complete!"
echo "========================================="
