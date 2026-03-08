#!/bin/bash
# convert-links.sh
# Converts xref links and updates internal links

set -e

CONTENT_DIR="${1:-content}"

echo "========================================="
echo "Link Conversion Script"
echo "========================================="
echo "Processing directory: $CONTENT_DIR"
echo ""

# Define link mappings
declare -A LINK_MAP=(
    ["blazor/hosting-models"]="/getting-started/comparison"
    ["blazor/components/index"]="/components/index"
    ["blazor/components/render-modes"]="/fundamentals/render-modes"
    ["blazor/fundamentals/routing"]="/fundamentals/routing"
    ["blazor/fundamentals/dependency-injection"]="/fundamentals/dependency-injection"
    ["blazor/fundamentals/configuration"]="/fundamentals/configuration"
    ["blazor/security/index"]="/security/index"
    ["blazor/forms/index"]="/forms/index"
    ["blazor/forms/validation"]="/forms/validation"
    ["signalr/introduction"]="https://learn.microsoft.com/aspnet/core/signalr/introduction"
)

find "$CONTENT_DIR" -name "*.md" -type f | while read -r file; do
    echo "Processing: $file"
    
    # Convert <xref:...> links
    for key in "${!LINK_MAP[@]}"; do
        sed -i "s|<xref:${key}>|[${key##*/}](${LINK_MAP[$key]})|g" "$file"
        sed -i "s|xref:${key}|${LINK_MAP[$key]}|g" "$file"
    done
    
    # Convert common patterns
    sed -i 's|\[!\[|![|g' "$file"
    sed -i 's|\](~/blazor/|](/|g' "$file"
    sed -i 's|\](~/|](/|g' "$file"
    
    # Remove INCLUDE statements
    sed -i '/\[!INCLUDE\[/d' "$file"
    
done

echo ""
echo "========================================="
echo "Link Conversion Complete!"
echo "========================================="
