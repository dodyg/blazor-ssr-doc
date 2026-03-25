---
title: Fundamentals
description: Core concepts of Blazor SSR including render modes, routing, and dependency injection

section: Fundamentals
toc: true
---

# Fundamentals

Learn the core concepts that power Blazor Server-Side Rendering applications.

## Topics

### [Render Modes](/fundamentals/render-modes)
Understand the different render modes available in Blazor: Static SSR, Interactive Server, and Interactive Auto. Learn when to use each mode and how they affect your application's behavior.

### [Routing](/fundamentals/routing)
Master URL navigation and routing in Blazor SSR. Learn how to define routes, handle parameters, and navigate between pages.

### [Dependency Injection](/fundamentals/dependency-injection)
Learn how to use dependency injection in your Blazor SSR applications. Understand service lifetimes and how to inject services into components.

### [Configuration](/fundamentals/configuration)
Configure your Blazor SSR application using appsettings.json, environment variables, and other configuration sources.

### [Static Files](/fundamentals/static-files)
Serve static assets like CSS, JavaScript, and images in your Blazor SSR application.

## Core Concepts

Blazor SSR is built on several fundamental concepts:

### Render Modes
Blazor components can be rendered in different modes:
- **Static SSR**: Renders as static HTML with no interactivity
- **Interactive Server**: Renders with full interactivity via SignalR
- **Interactive Auto**: Chooses the best render mode based on capabilities

### Component Model
Blazor uses Razor components (.razor files) that combine HTML markup with C# code. Components are the building blocks of your application.

### Server-Side Execution
In SSR mode, components execute on the server. HTML is generated and sent to the browser, providing fast initial load times and excellent SEO.

## Next Steps

After understanding the fundamentals, dive into [Components](/components/) to learn how to build interactive and reusable UI elements.
