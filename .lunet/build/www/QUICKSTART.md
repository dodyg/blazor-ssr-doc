# Quick Start Guide - Blazor SSR Documentation Project

This guide will help you get started with the Blazor SSR Documentation project.

## Prerequisites

Before you begin, ensure you have the following installed:

- **.NET 8.0 SDK** or later - [Download here](https://dotnet.microsoft.com/download/dotnet/8.0)
- **Git** - [Download here](https://git-scm.com/downloads)
- A code editor (Visual Studio, VS Code, or JetBrains Rider)

## Step 1: Install Lunet

Lunet is the static site generator we'll use to build the documentation.

```bash
# Install Lunet as a global .NET tool
dotnet tool install --global lunet

# Verify installation
lunet --version
```

## Step 2: Project Setup

If you haven't already cloned this repository:

```bash
# Clone the repository
git clone <repository-url>
cd blazor-ssr-docs

# Or if creating from scratch, initialize Lunet
lunet init
```

## Step 3: Extract Documentation Content

The documentation content needs to be extracted from the official ASP.NET Core Docs repository.

### Option A: Automated Extraction (Recommended)

```bash
# Clone the source repository (this is large, ~2GB)
git clone --depth 1 https://github.com/dotnet/AspNetCore.Docs.git temp-docs

# Run the extraction script
./scripts/extract-ssr-content.sh temp-docs/aspnetcore/blazor content

# Clean up the temporary repository
rm -rf temp-docs
```

### Option B: Manual Extraction

1. Browse to https://github.com/dotnet/AspNetCore.Docs/tree/main/aspnetcore/blazor
2. Download relevant markdown files manually
3. Place them in the `content/` directory according to the structure in PLAN.md

## Step 4: Review and Process Content

After extraction, you need to process the markdown files:

### What to Filter

**Include content about:**
- Static SSR (non-interactive rendering)
- Interactive SSR (server-side with SignalR)
- Render modes (Static, InteractiveServer, InteractiveAuto)
- Prerendering
- Component lifecycle in SSR
- Dependency injection
- Routing
- Forms and validation
- Security (authentication/authorization)
- Performance optimization

**Exclude content about:**
- Blazor WebAssembly standalone apps
- Progressive Web Apps (PWA)
- Blazor Hybrid (.NET MAUI, WPF, Windows Forms)
- WebAssembly AOT compilation
- Client-side offline scenarios
- WebAssembly-specific deployment

### Processing Checklist

For each extracted file:

- [ ] Review and understand the content
- [ ] Remove or comment out sections not relevant to SSR
- [ ] Update cross-references (`<xref:...>` links)
- [ ] Download images and update paths
- [ ] Add appropriate frontmatter metadata
- [ ] Test rendering locally

## Step 5: Build the Site

Build the static site using Lunet:

```bash
# Build the site
lunet build

# The output will be in .lunet/build/www/
```

## Step 6: Preview Locally

Preview your documentation site locally:

```bash
# Start the development server
lunet serve

# Open your browser to http://localhost:4000
```

The development server includes:
- Live reload (changes refresh automatically)
- File watcher (rebuilds on file changes)
- Local preview of the production build

## Step 7: Deploy

### Option A: GitHub Pages

```bash
# Build for production
lunet build

# Navigate to build output
cd .lunet/build/www

# Initialize git and push to gh-pages branch
git init
git add .
git commit -m "Deploy documentation"
git remote add origin https://github.com/<username>/<repo>.git
git push -f origin master:gh-pages
```

### Option B: Azure Static Web Apps

1. Create a Static Web App resource in Azure
2. Connect your GitHub repository
3. Configure build settings:
   - Build command: `lunet build`
   - Output directory: `.lunet/build/www`
4. Azure will automatically deploy on push to main branch

### Option C: Netlify

1. Connect your GitHub repository to Netlify
2. Configure build settings:
   - Build command: `lunet build`
   - Publish directory: `.lunet/build/www`
3. Deploy!

### Option D: Vercel

1. Import your GitHub repository
2. Configure build:
   - Build command: `lunet build`
   - Output directory: `.lunet/build/www`
3. Deploy!

## Project Structure Overview

```
blazor-ssr-docs/
├── config.scriban              # Lunet configuration
├── content/                    # All markdown content
│   ├── index.md               # Homepage
│   ├── getting-started/       # Getting started guides
│   ├── fundamentals/          # Core concepts
│   ├── components/            # Component documentation
│   ├── forms/                 # Form handling
│   ├── security/              # Security topics
│   └── advanced/              # Advanced topics
├── layouts/                    # Page layout templates
│   ├── _default.scriban      # Default layout
│   ├── page.scriban          # Standard page layout
│   └── index.scriban         # Homepage layout
├── includes/                   # Reusable partials
├── assets/                     # Static files
│   ├── css/                   # Stylesheets
│   ├── js/                    # JavaScript
│   └── images/                # Images
├── scripts/                    # Utility scripts
│   ├── extract-ssr-content.sh
│   └── setup-project.sh
├── .gitignore
├── PLAN.md                    # Detailed project plan
├── README.md                  # Project overview
└── QUICKSTART.md              # This file
```

## Common Tasks

### Adding a New Page

1. Create a new markdown file in the appropriate `content/` subdirectory:

```markdown
---
title: My New Page
description: Description of the page
---

# My New Page

Content goes here...
```

2. Build and preview:

```bash
lunet build
lunet serve
```

### Customizing Layouts

Edit the layout templates in `layouts/`:

- `_default.scriban` - Base layout
- `page.scriban` - Standard page layout
- `index.scriban` - Homepage layout

### Adding Styles

Place CSS files in `assets/css/` and reference them in your layouts.

### Adding JavaScript

Place JS files in `assets/js/` and reference them in your layouts.

### Updating Navigation

Edit the `menus` section in `config.scriban` to update the navigation menu.

## Troubleshooting

### Lunet command not found

If `lunet` is not found after installation:

```bash
# Ensure .NET tools are in your PATH
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.):
export PATH="$HOME/.dotnet/tools:$PATH"

# Then reload your profile
source ~/.bashrc  # or ~/.zshrc
```

### Build errors

1. Check your markdown syntax
2. Verify frontmatter is valid JSON/YAML
3. Ensure all referenced files exist
4. Check `config.scriban` for syntax errors

### Missing content after extraction

Some files in the extraction list may not exist in the source repository (documentation structure changes over time). This is normal. The extraction script will report missing files.

### Images not loading

1. Download images from source repository
2. Place in `assets/images/`
3. Update image paths in markdown files

## Next Steps

1. ✅ Complete project setup
2. ⏳ Extract and process content
3. ⏳ Customize layouts and styling
4. ⏳ Add your own content
5. ⏳ Build and deploy

## Getting Help

- **Lunet Documentation**: https://lunet.io
- **Scriban Templates**: https://github.com/scriban/scriban
- **Blazor Documentation**: https://learn.microsoft.com/aspnet/core/blazor
- **Project Issues**: Open an issue in this repository

## Contributing

Found a bug or want to improve the documentation?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

**Happy documenting! 🚀**
