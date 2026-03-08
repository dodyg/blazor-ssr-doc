#!/bin/bash
# setup-project.sh
# Sets up the Blazor SSR documentation project

set -e

echo "========================================="
echo "Blazor SSR Docs - Project Setup"
echo "========================================="
echo ""

# Check for .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET SDK is not installed!"
    echo "   Please install .NET 8.0 SDK or later from:"
    echo "   https://dotnet.microsoft.com/download/dotnet/8.0"
    exit 1
fi

echo "✅ Found .NET SDK: $(dotnet --version)"
echo ""

# Install Lunet if not already installed
if ! command -v lunet &> /dev/null; then
    echo "Installing Lunet..."
    dotnet tool install --global lunet
    echo "✅ Lunet installed successfully"
else
    echo "✅ Lunet is already installed: $(lunet --version)"
fi

echo ""

# Initialize Lunet project if not already done
if [ ! -f "config.scriban" ]; then
    echo "Initializing Lunet project..."
    lunet init
    echo "✅ Lunet project initialized"
else
    echo "✅ Lunet project already initialized"
fi

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Clone source docs (optional):"
echo "     git clone --depth 1 https://github.com/dotnet/AspNetCore.Docs.git temp-docs"
echo ""
echo "  2. Extract content:"
echo "     ./scripts/extract-ssr-content.sh"
echo ""
echo "  3. Build the site:"
echo "     lunet build"
echo ""
echo "  4. Serve locally:"
echo "     lunet serve"
echo ""
