---
title: Getting Started
description: Learn the basics of Blazor Static SSR and get up and running quickly

section: Getting Started
toc: true
---

# Getting Started

Welcome to Blazor Static SSR! This section will help you understand what Blazor Static SSR is and how to get started building server-side rendered web applications.

## What You'll Learn

- **What is Blazor Static SSR?** - Understanding static server-side rendering in Blazor
- **When to Use Static SSR** - Choosing the right approach for your project
- **Project Structure** - Understanding the layout of a Blazor Static SSR project
- **Tooling** - Development tools and IDE support
- **Supported Platforms** - Platform requirements and compatibility

## Topics

### [When to Use Static SSR](/getting-started/comparison)
Learn about the advantages and limitations of Static SSR and when it's the right choice for your project.

### [Project Structure](/getting-started/project-structure)
Understand how a Blazor Static SSR project is organized and what each file does.

### [Tooling](/getting-started/tooling)
Get familiar with the development tools available for building Blazor applications.

### [Supported Platforms](/getting-started/supported-platforms)
Learn about the platform requirements and browser compatibility for Blazor Static SSR.

## Prerequisites

Before you begin, ensure you have:

- [.NET 10.0 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) or later
- A code editor (Visual Studio 2022, VS Code, or JetBrains Rider)
- Basic knowledge of C# and web development

## Quick Start

Create your first Blazor Static SSR application:

```bash
# Create a new Blazor Web App (Static SSR by default)
dotnet new blazor -o MyBlazorApp

# Navigate to the project
cd MyBlazorApp

# Run the application
dotnet run
```

Open your browser to the URL shown in the console output to see your Blazor Static SSR app!

## Key Concepts

### Static Server-Side Rendering

In Static SSR, your Blazor components are rendered on the server for each request, producing pure HTML that's sent to the browser:

```razor
@page "/hello"

<h1>Hello, World!</h1>
<p>The current time is: @DateTime.Now</p>
```

### No Interactive Circuit

Unlike interactive Blazor modes, Static SSR doesn't maintain a persistent connection. User interactions occur through:

- **Form submissions** - Traditional POST requests
- **Navigation** - Link clicks and redirects
- **Query strings** - URL parameters

### Component Lifecycle

In Static SSR, components follow a simpler lifecycle:

1. `SetParametersAsync` - Parameters are set
2. `OnInitialized` / `OnInitializedAsync` - Initialization
3. `OnParametersSet` / `OnParametersSetAsync` - After parameters set
4. HTML is rendered and sent to the browser

**Note**: `OnAfterRender` is not called in Static SSR.

## Next Steps

Once you've completed the getting started guide, explore the [Fundamentals](/fundamentals/) section to learn about core concepts like routing, and dependency injection.
