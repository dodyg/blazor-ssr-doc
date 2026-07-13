---
title: Fundamentals
description: Core concepts of Blazor Static SSR including routing, dependency injection, configuration, and static files

section: Fundamentals
toc: true
---

# Fundamentals

Learn the core concepts that power Blazor Static SSR applications.

## Topics

### [Render Modes](/fundamentals/render-modes)
Understand Static SSR as the absence of an assigned interactive render mode and learn how to avoid accidentally enabling interactivity.

### [Routing](/fundamentals/routing)
Master URL navigation and routing in Static SSR. Learn how to define routes, handle parameters, redirects, Not Found responses, and enhanced navigation.

### [Dependency Injection](/fundamentals/dependency-injection)
Learn how to use dependency injection in Static SSR applications. Understand service lifetimes and how to inject services into components.

### [Configuration](/fundamentals/configuration)
Configure your Static SSR application using appsettings.json, environment variables, and other configuration sources.

### [Static Files](/fundamentals/static-files)
Serve static assets like CSS, JavaScript, images, and downloads in your Static SSR application.

## Core Concepts

Blazor Static SSR is built on several fundamental concepts:

### Static SSR

Static SSR renders Razor components to HTML on the server for each request. There is no `@rendermode Static`; a component renders statically when no interactive render mode is assigned or inherited.

### Component Model
Blazor uses Razor components (.razor files) that combine HTML markup with C# code. Components are the building blocks of your application.

### Server-side execution

In Static SSR, components execute on the server. HTML is generated and sent to the browser, providing fast initial load times and excellent SEO.

## Next Steps

After understanding the fundamentals, dive into [Components](/components/) to learn how to build reusable request-rendered UI.
