---
title: Tooling for Blazor Static SSR
description: Create, run, debug, and publish a .NET 10 Blazor Web App configured for Static SSR.
section: Getting Started
toc: true
---

# Tooling for Blazor Static SSR

Blazor Static SSR uses the **Blazor Web App** project template with interactivity set to **None**. You only need the .NET SDK and an editor or IDE. A WebAssembly toolchain, `.Client` project, and SignalR configuration aren't required.

## Prerequisites

Install the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) and confirm the active version:

```bash
dotnet --version
```

You can develop on Windows, macOS, or Linux with any editor. Common choices are:

- [Visual Studio](https://visualstudio.microsoft.com/) on Windows with the **ASP.NET and web development** workload.
- [Visual Studio Code](https://code.visualstudio.com/) with the [C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit).
- The cross-platform [.NET CLI](https://learn.microsoft.com/dotnet/core/tools/).

## Create a Static SSR App

### .NET CLI

Create a Blazor Web App with interactivity explicitly disabled:

```bash
dotnet new blazor --interactivity None -o BlazorApp
cd BlazorApp
```

Use `--empty` when you don't want the sample pages and Bootstrap-based styling:

```bash
dotnet new blazor --interactivity None --empty -o BlazorApp
```

The template otherwise defaults to `Server` interactivity, so specify `--interactivity None` for a Static SSR-only app.

### Visual Studio

1. Select **Create a new project**.
2. Choose **Blazor Web App** and select **Next**.
3. Enter the project name and location.
4. In **Additional information**, select **None** for **Interactive render mode**.
5. Choose whether to include sample pages, then select **Create**.

Don't choose **Blazor WebAssembly Standalone App**, which creates a client-side application rather than a Static SSR app.

### Visual Studio Code

1. Open the Command Palette with <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> (Windows/Linux) or <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> (macOS).
2. Run **.NET: New Project**.
3. Select **Blazor Web App**.
4. Select **Show all template options** and set **Interactivity** to **None**.
5. Choose a project folder and name.

You can also run the .NET CLI commands from VS Code's integrated terminal.

## Verify the Static SSR Configuration

A Static SSR-only `Program.cs` registers and maps Razor components without adding interactive component services or render modes:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseStatusCodePagesWithReExecute(
    "/not-found", createScopeForStatusCodePages: true);
app.UseHttpsRedirection();
app.UseAntiforgery();
app.MapStaticAssets();
app.MapRazorComponents<App>();

app.Run();
```

For a Static SSR-only app:

- Don't call `AddInteractiveServerComponents` or `AddInteractiveWebAssemblyComponents`.
- Don't call `AddInteractiveServerRenderMode` or `AddInteractiveWebAssemblyRenderMode`.
- Don't apply an interactive `@rendermode` to pages or components.
- Keep `_framework/blazor.web.js` when you want enhanced navigation, enhanced forms, streaming updates, or Static SSR JavaScript lifecycle events. It doesn't create a SignalR circuit by itself.

## Run and Debug

From the project directory, run with hot reload:

```bash
dotnet watch --launch-profile https
```

Or run without file watching:

```bash
dotnet run --launch-profile https
```

The terminal displays the local URL, usually `https://localhost:{PORT}`. Change local URLs in `Properties/launchSettings.json` if a port is already in use.

In Visual Studio or VS Code:

- Press <kbd>F5</kbd> to run with the debugger.
- Press <kbd>Ctrl</kbd>+<kbd>F5</kbd> to run without the debugger.
- Press <kbd>Shift</kbd>+<kbd>F5</kbd> to stop debugging.

Static SSR component code executes on the server, so set breakpoints in `.razor` files, code-behind files, services, and `Program.cs` as you would for other ASP.NET Core server code.

## Trust the Development Certificate

If the browser doesn't trust the local HTTPS certificate, run:

```bash
dotnet dev-certs https --trust
```

On platforms where `--trust` isn't supported, follow the [.NET HTTPS development certificate guidance](https://learn.microsoft.com/aspnet/core/security/enforcing-ssl#trust-the-aspnet-core-https-development-certificate).

## Build and Publish

Build the app:

```bash
dotnet build
```

Create a production deployment:

```bash
dotnet publish -c Release -o ./publish
```

Static SSR still requires an ASP.NET Core server at runtime. The word “static” describes the noninteractive HTML response; it doesn't mean the published output can be hosted as a static-file-only website.

## Relevant Template Options

| Option | Static SSR use |
| --- | --- |
| `--interactivity None` | Creates a Static SSR-only app. |
| `--empty` | Omits sample pages and their styling. |
| `--auth None` | Creates an app without authentication. This is the default. |
| `--auth Individual` | Adds ASP.NET Core Identity; account pages use Static SSR because they work with HTTP cookies. |
| `--use-local-db` | Uses LocalDB instead of SQLite with Individual authentication. |
| `--no-https` | Disables the generated HTTPS launch profile. Avoid this outside constrained local scenarios. |
| `--localhost-tld` | Uses a project-specific `.dev.localhost` development URL. |

Options such as `--all-interactive` don't apply when interactivity is `None`.

To inspect the options supported by the installed SDK:

```bash
dotnet new blazor --help
```

## Additional Resources

- [Tooling for ASP.NET Core Blazor](https://learn.microsoft.com/aspnet/core/blazor/tooling?view=aspnetcore-10.0)
- [Blazor project structure](/getting-started/project-structure)
- [Static SSR render modes](/fundamentals/render-modes)
- [.NET CLI documentation](https://learn.microsoft.com/dotnet/core/tools/)
