---
title: Static files in Blazor Static SSR
description: Serve CSS, JavaScript, images, and downloads from a Blazor Static SSR app.

section: Fundamentals
toc: true
---

# Static files in Blazor Static SSR

Static SSR apps serve public assets from the ASP.NET Core app, usually from `wwwroot`.

Common assets include:

- CSS files
- JavaScript modules
- images and fonts
- downloadable public files
- CSS isolation bundles

## Map static assets

In .NET 10, use `MapStaticAssets` for files known at build and publish time:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents();

var app = builder.Build();

app.UseHttpsRedirection();
app.UseAntiforgery();

app.MapStaticAssets();
app.MapRazorComponents<App>();

app.Run();
```

`MapStaticAssets` provides optimized endpoint conventions for static assets. Use `UseStaticFiles` when you need to serve files from locations or with options that `MapStaticAssets` doesn't cover.

## Reference assets

Reference public files from Razor markup with normal URLs:

```razor
<link rel="stylesheet" href="app.css" />
<img src="images/logo.svg" alt="Company logo" />
```

For fingerprinted assets, use the component asset collection:

```razor
<link rel="stylesheet" href="@Assets["app.css"]" />
<link rel="stylesheet" href="@Assets["BlazorApp.styles.css"]" />
```

CSS isolation output is usually referenced from the root document with the app's generated styles bundle.

## Blazor script

Static SSR doesn't require an interactive runtime, but `_framework/blazor.web.js` enables progressive enhancement features:

```razor
<script src="_framework/blazor.web.js"></script>
```

Keep the script when the app uses enhanced navigation, enhanced forms, streaming rendering updates, or JavaScript initializers. Loading it doesn't create a SignalR circuit by itself.

## JavaScript files

Place app-wide scripts in `wwwroot/js` and load them from the root document:

```razor
<script src="js/site.js"></script>
```

For page-specific behavior, prefer JavaScript initializers and enhanced-navigation lifecycle events. A `<script>` tag rendered by a page component may not execute again when enhanced navigation patches new HTML into the document.

See [JavaScript with Static SSR](/advanced/javascript).

## File downloads

Static SSR can't use .NET-to-JavaScript streaming interop after rendering. Serve downloadable content from a URL and use an ordinary anchor:

```razor
<a href="/downloads/invoice/@InvoiceId" download>
    Download invoice
</a>
```

The URL can map to a public static file or to an authorized endpoint that returns a file:

```csharp
app.MapGet("/downloads/invoice/{id:int}", async (
    int id,
    InvoiceService invoices,
    ClaimsPrincipal user) =>
{
    var file = await invoices.GetInvoiceFileAsync(id, user);

    return file is null
        ? Results.NotFound()
        : Results.File(file.Content, file.ContentType, file.FileName);
});
```

For protected downloads:

- Validate authorization on the server.
- Don't combine user input directly into physical paths.
- Store uploaded/downloaded files where they can't execute as code.
- Validate file names, extensions, content types, and sizes.
- Apply rate limits for expensive or sensitive downloads.

## Uploaded files

Don't serve user uploads from a public directory unless they are intentionally public and validated. For private uploads, store metadata in a database and serve files through an authorized endpoint.

## Additional resources

- [ASP.NET Core static files](https://learn.microsoft.com/aspnet/core/fundamentals/static-files)
- [JavaScript with Static SSR](/advanced/javascript)
- [Threat mitigation](/security/threat-mitigation)
