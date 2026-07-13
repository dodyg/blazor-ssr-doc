---
title: Project structure for Blazor Static SSR
description: Understand the files and folders in a .NET 10 Blazor Web App configured for Static SSR.

section: Getting Started
toc: true
---

# Project structure for Blazor Static SSR

A Static SSR app uses the Blazor Web App template with interactivity set to `None`:

```bash
dotnet new blazor --interactivity None -o BlazorApp
```

The app is a normal ASP.NET Core project. Razor components render on the server for each request, and the browser receives HTML.

## Top-level files

| Path | Purpose |
| ---- | ------- |
| `Program.cs` | Configures services, middleware, static assets, antiforgery, and Razor component endpoints. |
| `App.razor` | Root document for the app, including `<head>`, `<body>`, routes, and the Blazor script. |
| `_Imports.razor` | Shared Razor `@using` directives for components. |
| `appsettings.json` | Production configuration. |
| `appsettings.Development.json` | Development-only configuration. |
| `Properties/launchSettings.json` | Local launch profiles for `dotnet run`, `dotnet watch`, and IDE debugging. |
| `wwwroot/` | Public static assets. |

## `Program.cs`

A Static SSR-only app registers Razor components without interactive services:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseAntiforgery();

app.MapStaticAssets();
app.MapRazorComponents<App>();

app.Run();
```

Do not add interactive component services or interactive render modes unless the app intentionally includes interactive islands.

## Components folder

The template places Razor component UI under `Components/`:

| Path | Purpose |
| ---- | ------- |
| `Components/Layout/` | Layout components such as `MainLayout` and navigation. |
| `Components/Pages/` | Routable page components with `@page` directives. |
| `Components/Routes.razor` | Configures the router. |
| `Components/_Imports.razor` | Shared imports for components in the folder tree. |

Routable Static SSR pages are ordinary Razor components:

```razor
@page "/products/{id:int}"

<h1>Product @Id</h1>

@code {
    [Parameter]
    public int Id { get; set; }
}
```

## Root document

`App.razor` defines the HTML document and loads routes:

```razor
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <base href="/" />
    <HeadOutlet />
</head>

<body>
    <Routes />
    <script src="_framework/blazor.web.js"></script>
</body>

</html>
```

Keep `_framework/blazor.web.js` when you use enhanced navigation, enhanced forms, streaming rendering, or JavaScript initializers. Loading this script doesn't create a SignalR circuit by itself.

## Static assets

Put public assets in `wwwroot/`, such as:

- `wwwroot/app.css`
- `wwwroot/favicon.png`
- `wwwroot/images/...`
- `wwwroot/js/...`

In .NET 10, `app.MapStaticAssets()` maps known static assets with build-time optimizations. Use [Static files](/fundamentals/static-files) for details.

## No `.Client` project

A Static SSR-only app doesn't need a `.Client` project, WebAssembly host, WebAssembly runtime files, or client-side render-mode setup.

If a solution contains a `.Client` project, it was created for client-side interactivity. Keep Static SSR pages in the server project unless the component intentionally runs in the browser.

## Not Found page

.NET 10 templates include a routable Not Found page. Configure the router with `NotFoundPage` and map status-code re-execution in `Program.cs`:

```razor
<Router AppAssembly="typeof(Program).Assembly"
        NotFoundPage="typeof(Pages.NotFound)">
    <Found Context="routeData">
        <RouteView RouteData="routeData" DefaultLayout="typeof(Layout.MainLayout)" />
    </Found>
</Router>
```

```csharp
app.UseStatusCodePagesWithReExecute(
    "/not-found",
    createScopeForStatusCodePages: true);
```

## Additional resources

- [Tooling for Blazor Static SSR](/getting-started/tooling)
- [Routing](/fundamentals/routing)
- [Render modes](/fundamentals/render-modes)
