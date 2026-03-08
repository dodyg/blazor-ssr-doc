# Blazor SSR Documentation Extraction Plan

> **Agent-Ready Implementation Plan**
> 
> This document provides step-by-step instructions for extracting and organizing Blazor Server-Side Rendering (SSR) documentation from the official ASP.NET Core repository and building a static documentation site using Lunet.

---

## 📋 Project Overview

**Objective**: Create a static documentation website focused exclusively on Blazor SSR (Server-Side Rendering)

**Sources**:
- Website: https://learn.microsoft.com/en-us/aspnet/core/overview?view=aspnetcore-10.0
- Repository: https://github.com/dotnet/AspNetCore.Docs/tree/main/aspnetcore/blazor
- Static Site Generator: https://github.com/lunet-io/lunet

**Target Directory**: `/mnt/d/GitHub/blazor-ssr-docs`

**Scope**:
- ✅ INCLUDE: Static SSR, Interactive SSR, Render Modes, Prerendering, Server-side concepts
- ❌ EXCLUDE: WebAssembly, PWA, Hybrid apps, Client-side features

**Estimated Time**: 20-30 hours

---

## 🎯 Definition of Done

The project is complete when:

- [ ] Lunet is installed and configured
- [ ] Content extracted from source repository
- [ ] Content filtered to SSR-only topics
- [ ] All cross-references converted to working links
- [ ] Images downloaded and paths updated
- [ ] Site builds without errors (`lunet build` succeeds)
- [ ] Site viewable locally (`lunet serve` works)
- [ ] Navigation functional
- [ ] Deployed to hosting platform

---

## 📐 Project Structure

```
blazor-ssr-docs/
├── config.scriban              # Lunet configuration (JSON)
├── content/                    # All markdown content
│   ├── index.md               # Homepage
│   ├── getting-started/       # Getting started guides
│   ├── fundamentals/          # Core SSR concepts
│   ├── components/            # Component documentation
│   ├── forms/                 # Form handling
│   ├── security/              # Security topics
│   └── advanced/              # Advanced topics
├── layouts/                    # Page layout templates (.scriban)
├── includes/                   # Reusable template partials
├── assets/                     # Static files
│   ├── css/                   # Stylesheets
│   ├── js/                    # JavaScript
│   └── images/                # Downloaded images
├── scripts/                    # Utility scripts
│   ├── extract-ssr-content.sh
│   └── setup-project.sh
├── .lunet/                     # Build output (generated, git-ignored)
├── PLAN.md                     # This file
├── README.md                   # Project overview
└── QUICKSTART.md              # Quick start guide
```

---

## 🔧 Prerequisites

Before starting, ensure:

- [ ] **.NET 8.0 SDK** or later installed
  - Verify: `dotnet --version` returns 8.0.x or higher
  - Download: https://dotnet.microsoft.com/download/dotnet/8.0

- [ ] **Git** installed
  - Verify: `git --version`
  - Download: https://git-scm.com/downloads

- [ ] **~5GB disk space** available
  - Source repository: ~2GB
  - Build output: ~100MB
  - Working space: ~2GB

- [ ] **Internet connection** for:
  - Installing Lunet
  - Cloning source repository
  - Downloading images

---

## 🚀 Phase 1: Environment Setup

**Goal**: Install and initialize Lunet

**Time**: ~30 minutes

### Step 1.1: Install Lunet

**Command**:
```bash
dotnet tool install --global lunet
```

**Validation**:
```bash
lunet --version
# Expected: 1.0.x or higher
```

**Error Handling**:
- If `lunet` command not found:
  ```bash
  # Add .NET tools to PATH
  export PATH="$HOME/.dotnet/tools:$PATH"
  # Add to shell profile for persistence
  echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  ```

### Step 1.2: Navigate to Project Directory

**Command**:
```bash
cd /mnt/d/GitHub/blazor-ssr-docs
```

**Validation**:
```bash
pwd
# Expected: /mnt/d/GitHub/blazor-ssr-docs
ls -la
# Should see: config.scriban, content/, scripts/, etc.
```

### Step 1.3: Initialize Lunet Project

**Command**:
```bash
lunet init
```

**Expected Output**:
- Creates default layout templates in `layouts/`
- Creates default includes in `includes/`
- No errors in console

**Validation**:
```bash
ls layouts/
# Should see: _default.scriban or similar template files
```

**Success Criteria**:
- [ ] Lunet installed globally
- [ ] `lunet --version` returns version number
- [ ] Project directory exists and contains expected files
- [ ] `lunet init` completed without errors
- [ ] Default layouts created

---

## 📥 Phase 2: Source Repository Setup

**Goal**: Clone the ASP.NET Core Docs repository

**Time**: ~15-30 minutes (depends on network speed)

### Step 2.1: Clone Repository

**Command**:
```bash
# Clone with depth=1 to minimize size (~2GB instead of ~10GB)
git clone --depth 1 https://github.com/dotnet/AspNetCore.Docs.git temp-docs
```

**Expected Output**:
```
Cloning into 'temp-docs'...
Receiving objects: 100% (xxx/xxx), ~2GB
Resolving deltas: 100% (xxx/xxx)
```

**Validation**:
```bash
ls temp-docs/aspnetcore/blazor/
# Should see: index.md, hosting-models.md, components/, fundamentals/, etc.
```

**Error Handling**:
- If clone fails due to network:
  ```bash
  # Retry with timeout
  GIT_CURL_VERBOSE=1 git clone --depth 1 https://github.com/dotnet/AspNetCore.Docs.git temp-docs
  ```
- If disk space insufficient:
  ```bash
  df -h  # Check available space
  # Clean up unnecessary files if needed
  ```

### Step 2.2: Verify Repository Contents

**Command**:
```bash
# Verify key files exist
ls -la temp-docs/aspnetcore/blazor/index.md
ls -la temp-docs/aspnetcore/blazor/hosting-models.md
ls -la temp-docs/aspnetcore/blazor/components/
ls -la temp-docs/aspnetcore/blazor/fundamentals/
```

**Expected**: All paths should exist

**Success Criteria**:
- [ ] Repository cloned to `temp-docs/`
- [ ] `temp-docs/aspnetcore/blazor/` directory exists
- [ ] Key files (index.md, hosting-models.md) present
- [ ] Subdirectories (components/, fundamentals/) present

---

## 📤 Phase 3: Content Extraction

**Goal**: Extract SSR-relevant markdown files from source

**Time**: ~5-10 minutes

### Step 3.1: Run Extraction Script

**Command**:
```bash
chmod +x scripts/extract-ssr-content.sh
./scripts/extract-ssr-content.sh temp-docs/aspnetcore/blazor content
```

**Expected Output**:
```
=========================================
Blazor SSR Content Extraction Script
=========================================
✅ Extracted: index.md
✅ Extracted: hosting-models.md
✅ Extracted: components/index.md
...
Extraction Complete!
Successfully extracted: XX
Missing files: X
```

### Step 3.2: Verify Extraction

**Command**:
```bash
# Check extracted files
find content/ -name "*.md" -type f | wc -l
# Expected: 20-40 files

# Check manifest
cat content/.extracted-files.txt
```

**Expected**: List of extracted markdown files

**Success Criteria**:
- [ ] Extraction script ran without errors
- [ ] Files extracted to `content/` directory
- [ ] Manifest file created (`content/.extracted-files.txt`)
- [ ] At least 20 markdown files extracted

---

## 🔍 Phase 4: Content Filtering

**Goal**: Filter extracted content to remove non-SSR topics

**Time**: ~4-6 hours (manual review)

### Step 4.1: Understand Filtering Rules

**INCLUDE Topics** (Keep content about):
```
- Static SSR (non-interactive rendering)
- Interactive SSR (server-side with SignalR)
- Render modes: Static, InteractiveServer, InteractiveAuto
- Prerendering
- Blazor Web Apps (.NET 8+)
- Server-side component lifecycle
- Dependency Injection (server-side)
- Routing (server-side)
- Forms and validation (SSR context)
- Security: Authentication/Authorization (SSR)
- Performance optimization (server-side)
- Configuration
- Static file serving
```

**EXCLUDE Topics** (Remove content about):
```
- Blazor WebAssembly standalone apps
- Progressive Web Apps (PWA)
- WebAssembly AOT compilation
- WebAssembly lazy loading
- WebAssembly native dependencies
- Blazor Hybrid (.NET MAUI, WPF, Windows Forms)
- Client-side offline scenarios
- WebAssembly-specific deployment
- Browser storage (LocalStorage, SessionStorage) - unless SSR-relevant
- IndexedDB
- Service Workers
```

### Step 4.2: Process Each File

For each markdown file in `content/`:

**Action**:
1. Open file in text editor
2. Search for moniker ranges: `:::moniker range="< 8.0"` → Remove
3. Search for WebAssembly keywords → Remove if not SSR-relevant
4. Search for "Blazor Hybrid", "MAUI", "WPF", "WinForms" → Remove sections
5. Search for "WebAssembly", "Wasm", "wasm" → Review and remove if client-side only
6. Keep sections with: "Blazor Server", "SSR", "server-side", "SignalR"

**Specific Actions by File**:

#### `content/hosting-models.md`
- [ ] Remove Blazor WebAssembly section
- [ ] Remove Blazor Hybrid section
- [ ] Keep Blazor Server section
- [ ] Keep comparison table (Server vs WebAssembly) but note SSR focus

#### `content/index.md`
- [ ] Already created (don't overwrite)
- [ ] Skip this file

#### `content/components/*.md`
- [ ] Remove WebAssembly-specific examples
- [ ] Keep render mode documentation
- [ ] Keep lifecycle events (OnInit, OnAfterRender, etc.)
- [ ] Remove client-side event handling if not SSR-relevant

#### `content/fundamentals/*.md`
- [ ] Keep routing
- [ ] Keep dependency injection
- [ ] Keep configuration
- [ ] Remove HTTP client examples specific to WebAssembly

#### `content/security/*.md`
- [ ] Keep server-side authentication
- [ ] Keep authorization
- [ ] Remove WebAssembly-specific security

### Step 4.3: Remove Version-Specific Blocks

Search for and remove:
```
:::moniker range="< aspnetcore-8.0"
...content...
:::moniker-end
```

Keep only .NET 8+ content:
```
:::moniker range=">= aspnetcore-8.0"
...content...
:::moniker-end
```

**Command** (optional automation):
```bash
# Example: Remove moniker blocks (use with caution)
find content/ -name "*.md" -exec sed -i '/:::moniker range="< aspnetcore-8.0"/,/:::moniker-end/d' {} \;
```

**Success Criteria**:
- [ ] All files reviewed
- [ ] WebAssembly-specific content removed
- [ ] Hybrid app content removed
- [ ] PWA content removed
- [ ] .NET 8+ content retained
- [ ] File still readable and coherent

---

## 📝 Phase 5: Content Transformation

**Goal**: Update extracted content for local use

**Time**: ~3-4 hours

### Step 5.1: Update Frontmatter

For each markdown file, update YAML frontmatter:

**Before** (source):
```yaml
---
title: ASP.NET Core Blazor
author: guardrex
description: ...
monikerRange: '>= aspnetcore-3.1'
ms.author: wpickett
ms.custom: mvc
ms.date: 11/11/2025
uid: blazor/index
---
```

**After** (target):
```yaml
---
title: Blazor Overview
description: Introduction to Blazor Server-Side Rendering
layout: page
section: Getting Started
toc: true
---
```

**Rules**:
- Remove: `author`, `monikerRange`, `ms.author`, `ms.custom`, `ms.date`, `uid`
- Keep: `title`, `description`
- Add: `layout: page`, `section: <appropriate-section>`, `toc: true`

### Step 5.2: Convert Cross-References

Find and replace `<xref:...>` links:

**Pattern**:
```
<xref:blazor/components/index>
```

**Replace with**:
```
[Components](/components/index)
```

**Common Mappings**:
```
<xref:blazor/hosting-models> → [Hosting Models](/getting-started/comparison)
<xref:blazor/components/index> → [Components](/components/index)
<xref:blazor/components/render-modes> → [Render Modes](/fundamentals/render-modes)
<xref:blazor/fundamentals/routing> → [Routing](/fundamentals/routing)
<xref:blazor/security/index> → [Security](/security/index)
<xref:blazor/forms/index> → [Forms](/forms/index)
```

**Command** (optional automation):
```bash
# Example conversion (review before running)
find content/ -name "*.md" -exec sed -i 's/<xref:blazor\/components\/index>/[Components](\/components\/index)/g' {} \;
```

### Step 5.3: Update Internal Links

Find markdown links to other docs:

**Pattern**:
```
[Link Text](xref:blazor/something)
```

**Replace with**:
```
[Link Text](/section/something)
```

Or if external:
```
[Link Text](https://learn.microsoft.com/aspnet/core/blazor/something)
```

### Step 5.4: Download Images

**Step 1**: Find all image references
```bash
grep -r "!\[.*\](.*\.png\|.*\.jpg\|.*\.gif\|.*\.svg)" content/ > image-references.txt
```

**Step 2**: Extract image URLs
```bash
# Images in source repo are typically at:
# ~/blazor/folder/_static/image.png
# Maps to: https://raw.githubusercontent.com/dotnet/AspNetCore.Docs/main/aspnetcore/blazor/folder/_static/image.png
```

**Step 3**: Download images
```bash
# Create images directory
mkdir -p assets/images

# Download each image (example)
wget -O assets/images/blazor-server.png \
  https://raw.githubusercontent.com/dotnet/AspNetCore.Docs/main/aspnetcore/blazor/hosting-models/_static/blazor-server.png
```

**Step 4**: Update image paths in markdown
```
Before: ![Alt text](~/blazor/hosting-models/_static/blazor-server.png)
After:  ![Alt text](/assets/images/blazor-server.png)
```

**Command** (batch update):
```bash
# Update all image paths (review pattern first)
find content/ -name "*.md" -exec sed -i 's|\[~\/blazor\/.*\/_static\/|\[\/assets\/images\/|g' {} \;
```

**Success Criteria**:
- [ ] All frontmatter updated
- [ ] All `<xref:...>` converted to markdown links
- [ ] All internal links updated
- [ ] All images downloaded to `assets/images/`
- [ ] All image references updated to local paths
- [ ] No broken links (test in Phase 7)

---

## 🗂️ Phase 6: Content Organization

**Goal**: Organize content into logical structure

**Time**: ~2-3 hours

### Step 6.1: Verify Directory Structure

**Expected Structure**:
```
content/
├── index.md                          # Homepage
├── getting-started/
│   ├── index.md                      # Overview
│   ├── what-is-ssr.md               # What is Blazor SSR
│   ├── quick-start.md               # Quick start
│   └── comparison.md                # SSR vs WASM vs Hybrid
├── fundamentals/
│   ├── index.md                      # Overview
│   ├── render-modes.md              # Render modes
│   ├── routing.md                   # Routing
│   ├── dependency-injection.md      # DI
│   ├── configuration.md             # Configuration
│   └── static-files.md              # Static files
├── components/
│   ├── index.md                      # Component basics
│   ├── render-modes.md              # Render modes
│   ├── lifecycle.md                 # Lifecycle
│   ├── rendering.md                 # Rendering
│   ├── prerender.md                 # Prerendering
│   ├── cascading-values.md          # Data flow
│   └── event-handling.md            # Events
├── forms/
│   ├── index.md                      # Forms overview
│   ├── validation.md                # Validation
│   └── binding.md                   # Data binding
├── security/
│   ├── index.md                      # Security overview
│   ├── authentication.md            # Auth
│   └── authorization.md             # Authorization
└── advanced/
    ├── performance.md               # Performance
    ├── deployment.md                # Deployment
    └── testing.md                   # Testing
```

**Command**:
```bash
# Verify structure
tree content/ -L 2
```

### Step 6.2: Move/Rename Files

**Mapping** (if files not in correct location):
```bash
# Example: Move render-modes.md to fundamentals/
mv content/components/render-modes.md content/fundamentals/render-modes.md

# Example: Rename files for clarity
mv content/hosting-models.md content/getting-started/comparison.md
```

### Step 6.3: Create Missing Index Files

For each directory, create `index.md` if missing:

**Template** (`content/fundamentals/index.md`):
```markdown
---
title: Fundamentals
description: Core concepts of Blazor SSR
layout: page
---

# Fundamentals

Learn the core concepts of Blazor Server-Side Rendering.

## Topics

- [Render Modes](/fundamentals/render-modes) - Understanding static and interactive SSR
- [Routing](/fundamentals/routing) - URL navigation
- [Dependency Injection](/fundamentals/dependency-injection) - Service management
- [Configuration](/fundamentals/configuration) - App settings
```

**Success Criteria**:
- [ ] All files in correct directories
- [ ] Index files created for each section
- [ ] Logical organization matches proposed structure
- [ ] No duplicate files

---

## ⚙️ Phase 7: Lunet Configuration

**Goal**: Configure Lunet for site generation

**Time**: ~1 hour

### Step 7.1: Verify config.scriban

File already exists at `/mnt/d/GitHub/blazor-ssr-docs/config.scriban`

**Verify contents**:
```bash
cat config.scriban
```

**Expected**: JSON configuration with menus, taxonomies, defaults

**If missing or corrupted, recreate** (see QUICKSTART.md for full content)

### Step 7.2: Create Layout Templates

**File**: `layouts/_default.scriban`

**Minimum Content**:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ page.title }} | Blazor SSR Docs</title>
    <meta name="description" content="{{ page.description }}">
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
    <header>
        <nav>
            <!-- Navigation menu -->
        </nav>
    </header>
    
    <main>
        <article>
            <h1>{{ page.title }}</h1>
            {{ content }}
        </article>
    </main>
    
    <footer>
        <p>Extracted from Microsoft ASP.NET Core Documentation</p>
    </footer>
</body>
</html>
```

### Step 7.3: Create CSS

**File**: `assets/css/style.css`

**Minimum Content**:
```css
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6;
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
}

nav ul {
    list-style: none;
    padding: 0;
}

nav ul li {
    display: inline;
    margin-right: 1rem;
}

pre {
    background: #f4f4f4;
    padding: 1rem;
    overflow-x: auto;
}

code {
    background: #f4f4f4;
    padding: 0.2rem 0.4rem;
}
```

**Success Criteria**:
- [ ] `config.scriban` present and valid
- [ ] Layout template created
- [ ] CSS created
- [ ] Configuration references correct paths

---

## 🏗️ Phase 8: Build and Test

**Goal**: Build site and verify functionality

**Time**: ~1-2 hours

### Step 8.1: Initial Build

**Command**:
```bash
lunet build
```

**Expected Output**:
```
Building site...
Processing content...
Generating pages...
Build complete!
Output: .lunet/build/www
```

**Validation**:
```bash
ls -la .lunet/build/www/
# Should see: index.html, folders, assets/
```

**Error Handling**:
- If build fails with "config not found":
  ```bash
  # Verify config.scriban exists
  ls -la config.scriban
  ```
- If build fails with "layout not found":
  ```bash
  # Verify layouts exist
  ls -la layouts/
  # Run lunet init again if needed
  lunet init
  ```

### Step 8.2: Local Preview

**Command**:
```bash
lunet serve
```

**Expected Output**:
```
Starting development server...
Server running at: http://localhost:4000
Press Ctrl+C to stop
```

**Validation**:
1. Open browser to http://localhost:4000
2. Verify homepage loads
3. Verify navigation works
4. Verify pages render correctly
5. Verify images display
6. Verify links work

### Step 8.3: Link Verification

**Command** (optional):
```bash
# Install link checker
npm install -g broken-link-checker

# Check links
blc http://localhost:4000 -ro
```

**Manual Checks**:
- [ ] Homepage loads
- [ ] All menu items work
- [ ] All internal links work
- [ ] All images display
- [ ] No console errors in browser
- [ ] Mobile responsive

### Step 8.4: Content Review

For each major page:
- [ ] Content renders correctly
- [ ] Code samples formatted
- [ ] No WebAssembly references remain
- [ ] No Hybrid app references remain
- [ ] Markdown formatting correct

**Success Criteria**:
- [ ] `lunet build` completes without errors
- [ ] `lunet serve` starts server successfully
- [ ] Site accessible at http://localhost:4000
- [ ] All pages load
- [ ] No broken links
- [ ] Images display correctly

---

## 🚢 Phase 9: Deployment

**Goal**: Deploy site to hosting platform

**Time**: ~1 hour

### Option A: GitHub Pages

**Step 1**: Build for production
```bash
lunet build
```

**Step 2**: Deploy to gh-pages branch
```bash
cd .lunet/build/www
git init
git add .
git commit -m "Deploy Blazor SSR Docs"
git remote add origin https://github.com/<username>/blazor-ssr-docs.git
git push -f origin master:gh-pages
```

**Step 3**: Enable GitHub Pages
1. Go to repository Settings → Pages
2. Source: Deploy from branch
3. Branch: gh-pages, / (root)
4. Save

**URL**: https://<username>.github.io/blazor-ssr-docs/

### Option B: Netlify

**Step 1**: Connect repository
1. Go to https://app.netlify.com
2. "New site from Git"
3. Choose GitHub, select repository
4. Configure:
   - Build command: `lunet build`
   - Publish directory: `.lunet/build/www`
5. Deploy site

**URL**: https://<random-name>.netlify.app

### Option C: Azure Static Web Apps

**Step 1**: Create resource
```bash
az staticwebapp create \
  --name blazor-ssr-docs \
  --resource-group <resource-group> \
  --source <repository-url> \
  --location <location> \
  --branch main \
  --app-location "/" \
  --output-location ".lunet/build/www"
```

**Step 2**: Add workflow file
Create `.github/workflows/azure-static-web-apps.yml`

**URL**: https://<random-name>.azurestaticapps.net

### Option D: Vercel

**Step 1**: Import project
1. Go to https://vercel.com
2. "Import Project" → Git Repository
3. Configure:
   - Build Command: `lunet build`
   - Output Directory: `.lunet/build/www`
4. Deploy

**URL**: https://<random-name>.vercel.app

**Success Criteria**:
- [ ] Site deployed to hosting platform
- [ ] Site accessible via public URL
- [ ] All pages load on deployed site
- [ ] No broken links on deployed site
- [ ] HTTPS enabled

---

## ✅ Phase 10: Cleanup

**Goal**: Remove temporary files

**Time**: ~5 minutes

### Step 10.1: Remove Source Repository

**Command**:
```bash
rm -rf temp-docs
```

**Validation**:
```bash
ls -la temp-docs
# Expected: No such file or directory
```

### Step 10.2: Remove Temporary Files

**Command**:
```bash
rm -f content/.extracted-files.txt
rm -f image-references.txt
```

**Success Criteria**:
- [ ] `temp-docs/` directory removed
- [ ] Temporary files removed
- [ ] Disk space freed
- [ ] Project still builds correctly

---

## 📊 Quality Assurance Checklist

### Content Quality
- [ ] All pages have proper frontmatter
- [ ] All pages have title and description
- [ ] Content is focused on SSR only
- [ ] No WebAssembly-specific content remains
- [ ] No Hybrid app content remains
- [ ] Code samples are SSR-relevant
- [ ] Examples use .NET 8+ syntax

### Technical Quality
- [ ] All cross-references converted
- [ ] All internal links work
- [ ] All images display
- [ ] No broken links
- [ ] Site builds without warnings
- [ ] Site builds without errors
- [ ] HTML is valid
- [ ] CSS is valid

### User Experience
- [ ] Navigation is intuitive
- [ ] Pages load quickly
- [ ] Mobile responsive
- [ ] Accessible (a11y)
- [ ] Search works (if enabled)
- [ ] Table of contents displays

### Deployment
- [ ] Site deployed successfully
- [ ] HTTPS enabled
- [ ] Custom domain configured (if applicable)
- [ ] CDN configured (if applicable)

---

## 🐛 Troubleshooting Guide

### Issue: Lunet command not found
**Solution**:
```bash
export PATH="$HOME/.dotnet/tools:$PATH"
echo 'export PATH="$HOME/.dotnet/tools:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Issue: Build fails with "config.scriban not found"
**Solution**:
```bash
# Verify file exists
ls -la config.scriban
# If missing, recreate from QUICKSTART.md
```

### Issue: Build fails with "layout not found"
**Solution**:
```bash
# Re-initialize Lunet
lunet init
# Verify layouts created
ls -la layouts/
```

### Issue: Images not displaying
**Solution**:
```bash
# Verify images downloaded
ls -la assets/images/
# Check paths in markdown
grep -r "!\[" content/ | head -5
# Update paths if needed
```

### Issue: Links broken
**Solution**:
```bash
# Find broken links
grep -r "\[.*\](.*xref:" content/  # Should find nothing
# Convert remaining xref links
```

### Issue: Content not filtered correctly
**Solution**:
```bash
# Search for excluded keywords
grep -ri "webassembly" content/ --include="*.md"
grep -ri "blazor hybrid" content/ --include="*.md"
grep -ri "MAUI" content/ --include="*.md"
# Remove found sections manually
```

### Issue: Git clone fails
**Solution**:
```bash
# Try shallow clone with timeout
GIT_CURL_VERBOSE=1 GIT_SSL_NO_VERIFY=1 \
  git clone --depth 1 --single-branch \
  https://github.com/dotnet/AspNetCore.Docs.git temp-docs
```

### Issue: Lunet serve doesn't auto-reload
**Solution**:
```bash
# Manually restart server
# Ctrl+C to stop, then:
lunet serve
```

---

## 📚 Reference: File Extraction List

### Priority 1: Core Documentation (CRITICAL)
Extract from `aspnetcore/blazor/`:

- [ ] `index.md` → `content/index.md` (Already created, skip)
- [ ] `hosting-models.md` → `content/getting-started/comparison.md`
- [ ] `project-structure.md` → `content/getting-started/project-structure.md`
- [ ] `tooling.md` → `content/getting-started/tooling.md`
- [ ] `supported-platforms.md` → `content/getting-started/supported-platforms.md`

### Priority 2: Component Documentation
Extract from `aspnetcore/blazor/components/`:

- [ ] `index.md` → `content/components/index.md`
- [ ] `render-modes.md` → `content/fundamentals/render-modes.md` (MOVED)
- [ ] `prerender.md` → `content/components/prerender.md`
- [ ] `rendering.md` → `content/components/rendering.md`
- [ ] `lifecycle.md` → `content/components/lifecycle.md`
- [ ] `cascading-values-and-parameters.md` → `content/components/cascading-values.md`
- [ ] `event-handling.md` → `content/components/event-handling.md`
- [ ] `data-binding.md` → `content/components/data-binding.md`
- [ ] `sync-context.md` → `content/components/sync-context.md`

### Priority 3: Fundamentals
Extract from `aspnetcore/blazor/fundamentals/`:

- [ ] `index.md` → `content/fundamentals/index.md`
- [ ] `routing.md` → `content/fundamentals/routing.md`
- [ ] `dependency-injection.md` → `content/fundamentals/dependency-injection.md`
- [ ] `configuration.md` → `content/fundamentals/configuration.md`
- [ ] `static-files.md` → `content/fundamentals/static-files.md`

### Priority 4: Forms
Extract from `aspnetcore/blazor/forms/`:

- [ ] `index.md` → `content/forms/index.md`
- [ ] `input-components.md` → `content/forms/input-components.md`
- [ ] `validation.md` → `content/forms/validation.md`

### Priority 5: Security
Extract from `aspnetcore/blazor/security/`:

- [ ] `index.md` → `content/security/index.md`
- [ ] `server/account-confirmation-and-password-recovery.md` → `content/security/account-confirmation.md`
- [ ] `server/interactive-server-side-rendering.md` → `content/security/interactive-ssr.md`
- [ ] `server/threat-mitigation.md` → `content/security/threat-mitigation.md`

### Priority 6: Advanced Topics
Extract from `aspnetcore/blazor/`:

- [ ] `performance.md` → `content/advanced/performance.md`
- [ ] `advanced-scenarios.md` → `content/advanced/scenarios.md`
- [ ] `globalization-localization.md` → `content/advanced/globalization.md`
- [ ] `call-web-api.md` → `content/advanced/call-web-api.md`

---

## 📈 Progress Tracking

### Phase Completion
- [ ] Phase 1: Environment Setup (30 min)
- [ ] Phase 2: Source Repository Setup (30 min)
- [ ] Phase 3: Content Extraction (10 min)
- [ ] Phase 4: Content Filtering (4-6 hours)
- [ ] Phase 5: Content Transformation (3-4 hours)
- [ ] Phase 6: Content Organization (2-3 hours)
- [ ] Phase 7: Lunet Configuration (1 hour)
- [ ] Phase 8: Build and Test (1-2 hours)
- [ ] Phase 9: Deployment (1 hour)
- [ ] Phase 10: Cleanup (5 min)

**Total Estimated Time**: 20-30 hours

### File Extraction Progress
- [ ] Priority 1: Core (5 files)
- [ ] Priority 2: Components (9 files)
- [ ] Priority 3: Fundamentals (5 files)
- [ ] Priority 4: Forms (3 files)
- [ ] Priority 5: Security (4 files)
- [ ] Priority 6: Advanced (4 files)

**Total Files**: ~30 files

---

## 🔗 Resources

### Official Documentation
- [Lunet Documentation](https://lunet.io)
- [Scriban Template Language](https://github.com/scriban/scriban)
- [Markdig Markdown Processor](https://github.com/xoofx/markdig)
- [ASP.NET Core Docs Source](https://github.com/dotnet/AspNetCore.Docs)
- [Blazor Official Docs](https://learn.microsoft.com/aspnet/core/blazor)

### Tools
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- [.NET SDK](https://dotnet.microsoft.com/download)

### Hosting Platforms
- [GitHub Pages](https://pages.github.com/)
- [Netlify](https://www.netlify.com/)
- [Vercel](https://vercel.com/)
- [Azure Static Web Apps](https://azure.microsoft.com/services/app-service/static/)

---

## 📝 Notes for Agents

### Decision Points
1. **If extraction script fails**: Manually download files from GitHub web interface
2. **If content filtering is too broad**: Err on side of keeping more content, filter later
3. **If build fails**: Check console output for specific file causing issue
4. **If deployment fails**: Try different hosting platform

### Validation Priority
1. **High Priority**: Site builds, pages load, links work
2. **Medium Priority**: Images display, formatting correct, content filtered
3. **Low Priority**: SEO optimization, analytics, custom domain

### Common Patterns
- Most files need frontmatter updates
- Most files need `<xref:...>` conversion
- Most files need image path updates
- Many files need moniker range removal

### Time-Saving Tips
- Use `find` and `sed` for batch operations
- Process files in priority order
- Build and test frequently
- Don't perfect filtering in first pass

---

**END OF PLAN**

*Last Updated: 2026-03-08*
*Version: 1.0*
