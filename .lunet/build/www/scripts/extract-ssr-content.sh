#!/bin/bash
# extract-ssr-content.sh
# Extracts Blazor SSR-relevant content from the ASP.NET Core Docs repository

set -e

SOURCE_DIR="${1:-temp-docs/aspnetcore/blazor}"
TARGET_DIR="${2:-content}"

echo "========================================="
echo "Blazor SSR Content Extraction Script"
echo "========================================="
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Source directory '$SOURCE_DIR' not found!"
    echo ""
    echo "Please clone the source repository first:"
    echo "  git clone --depth 1 https://github.com/dotnet/AspNetCore.Docs.git temp-docs"
    exit 1
fi

# Files to extract - focused on SSR content
declare -a FILES=(
    # Core documentation
    "index.md"
    "hosting-models.md"
    "project-structure.md"
    "tooling.md"
    "supported-platforms.md"
    
    # Components - SSR relevant
    "components/index.md"
    "components/render-modes.md"
    "components/prerender.md"
    "components/rendering.md"
    "components/cascading-values-and-parameters.md"
    "components/lifecycle.md"
    "components/event-handling.md"
    "components/data-binding.md"
    "components/sync-context.md"
    
    # Fundamentals - SSR relevant
    "fundamentals/index.md"
    "fundamentals/routing.md"
    "fundamentals/dependency-injection.md"
    "fundamentals/configuration.md"
    "fundamentals/static-files.md"
    "fundamentals/dependency-injection.md"
    
    # Forms (SSR-relevant)
    "forms/index.md"
    "forms/input-components.md"
    "forms/validation.md"
    "forms/binding.md"
    
    # Security (SSR-relevant)
    "security/index.md"
    "security/server/account-confirmation-and-password-recovery.md"
    "security/server/interactive-server-side-rendering.md"
    "security/server/threat-mitigation.md"
    
    # Advanced topics
    "performance.md"
    "advanced-scenarios.md"
    "globalization-localization.md"
)

# Counter for statistics
total_files=0
copied_files=0
missing_files=0

echo "Extracting files..."
echo ""

# Copy files
for file in "${FILES[@]}"; do
    total_files=$((total_files + 1))
    source_file="$SOURCE_DIR/$file"
    target_file="$TARGET_DIR/$file"
    
    if [ -f "$source_file" ]; then
        # Create target directory if it doesn't exist
        mkdir -p "$(dirname "$target_file")"
        
        # Copy file
        cp "$source_file" "$target_file"
        copied_files=$((copied_files + 1))
        
        echo "✅ Extracted: $file"
    else
        missing_files=$((missing_files + 1))
        echo "⚠️  Missing:  $file"
    fi
done

echo ""
echo "========================================="
echo "Extraction Complete!"
echo "========================================="
echo "Total files:      $total_files"
echo "Successfully extracted: $copied_files"
echo "Missing files:    $missing_files"
echo ""

if [ $missing_files -gt 0 ]; then
    echo "⚠️  Some files were not found in the source repository."
    echo "    This is normal if the documentation structure has changed."
    echo ""
fi

echo "✨ Next steps:"
echo "  1. Review extracted content in: $TARGET_DIR"
echo "  2. Process markdown files to filter SSR-relevant content"
echo "  3. Update cross-references and links"
echo "  4. Download and process images"
echo "  5. Build with: lunet build"
echo ""

# Create a list of extracted files
echo "Creating file manifest..."
cat > "$TARGET_DIR/.extracted-files.txt" <<EOF
# Extracted Blazor SSR Documentation Files
# Generated on: $(date)
# Source: $SOURCE_DIR

EOF

for file in "${FILES[@]}"; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo "$file" >> "$TARGET_DIR/.extracted-files.txt"
    fi
done

echo "✅ File manifest created: $TARGET_DIR/.extracted-files.txt"
