---
title: Supported platforms for Blazor Static SSR
description: Browser, server, and hosting requirements for Blazor Static SSR apps.

section: Getting Started
toc: true
---

# Supported platforms for Blazor Static SSR

Blazor Static SSR runs as an ASP.NET Core server app. The browser receives HTML, CSS, static assets, and optional progressive-enhancement JavaScript.

## Browsers

Static SSR pages work in current desktop and mobile browsers that support ordinary HTML forms and navigation:

| Browser | Version |
| ------- | ------- |
| Apple Safari | Current |
| Google Chrome | Current |
| Microsoft Edge | Current |
| Mozilla Firefox | Current |

The `Current` version means the latest stable browser version. Static SSR doesn't require WebAssembly support.

## Server runtime

Use the target .NET SDK and runtime for the app. For this guide, that means .NET 10:

```bash
dotnet --version
```

A deployed Static SSR app needs an ASP.NET Core host. The published output isn't a static-file-only site, because Razor components execute on the server for each request.

## Hosting

Static SSR can run anywhere ASP.NET Core apps are supported, including:

- Kestrel behind a reverse proxy
- IIS on Windows
- Linux services
- Containers
- Cloud app hosting platforms that support ASP.NET Core

Enable HTTPS in production and configure normal ASP.NET Core hosting concerns such as forwarded headers, logging, health checks, and secret storage.

## Progressive enhancement

Enhanced navigation, enhanced forms, streaming rendering, and JavaScript initializers require `_framework/blazor.web.js`. This script doesn't create a SignalR circuit by itself and doesn't require an interactive render mode.

If JavaScript is unavailable, ordinary links and form posts still work when the page is designed with a proper HTML fallback.

## Additional resources

- [Tooling for Blazor Static SSR](/getting-started/tooling)
- [Static files](/fundamentals/static-files)
- [Routing and enhanced navigation](/fundamentals/routing)
