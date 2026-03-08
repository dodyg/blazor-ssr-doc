---
title: ASP.NET Core Blazor static files
description: Learn how to configure and manage static files for Blazor apps.
layout: page
section: Fundamentals
toc: true
---

# ASP.NET Core Blazor static files


This article describes Blazor app configuration for serving static files.

:::moniker range=">= aspnetcore-9.0"

For general information on serving static files with Map Static Assets routing endpoint conventions, see [static-files](https://learn.microsoft.com/aspnet/core/fundamentals/static-files) before reading this article.

:::moniker-end

:::moniker range=">= aspnetcore-10.0"

## Preloaded Blazor framework static assets

In Blazor Web Apps, framework static assets are automatically preloaded using [`Link` headers](https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers/Link), which allows the browser to preload resources before the initial page is fetched and rendered.

In standalone Blazor WebAssembly apps, framework assets are scheduled for high priority downloading and caching early in browser `index.html` page processing when:

* The `OverrideHtmlAssetPlaceholders` MSBuild property in the app's project file (`.csproj`) is set to `true`:

  ```xml
  <PropertyGroup>
    <OverrideHtmlAssetPlaceholders>true</OverrideHtmlAssetPlaceholders>
  </PropertyGroup>
  ```

* The following `<link>` element containing [`rel="preload"`](https://developer.mozilla.org/docs/Web/HTML/Reference/Attributes/rel/preload) is present in the `<head>` content of `wwwroot/index.html`:

  ```html
  <link rel="preload" id="webassembly" />
  ```

:::moniker-end

## Static asset delivery in server-side Blazor apps

:::moniker range=">= aspnetcore-9.0"

Serving static assets is managed by either routing endpoint conventions or a middleware described in the following table.

Feature | API | .NET Version | Description
--- | --- | :---: | ---
Map Static Assets routing endpoint conventions | [Microsoft.AspNetCore.Builder.StaticAssetsEndpointRouteBuilderExtensions.MapStaticAssets *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticassetsendpointroutebuilderextensions.mapstaticassets%2a) | .NET 9 or later | Optimizes the delivery of static assets to clients.
Static File Middleware | [Microsoft.AspNetCore.Builder.StaticFileExtensions.UseStaticFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticfileextensions.usestaticfiles%2a) | All .NET versions | Serves static assets to clients without the optimizations of Map Static Assets but useful for some tasks that Map Static Assets isn't capable of managing.

Map Static Assets can replace [Microsoft.AspNetCore.Builder.StaticFileExtensions.UseStaticFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticfileextensions.usestaticfiles%2a) in most situations. However, Map Static Assets is optimized for serving the assets from known locations in the app at build and publish time. If the app serves assets from other locations, such as disk or embedded resources, [Microsoft.AspNetCore.Builder.StaticFileExtensions.UseStaticFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticfileextensions.usestaticfiles%2a) should be used.

Map Static Assets ([Microsoft.AspNetCore.Builder.StaticAssetsEndpointRouteBuilderExtensions.MapStaticAssets *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticassetsendpointroutebuilderextensions.mapstaticassets%2a)) also replaces calling [Microsoft.AspNetCore.Builder.ComponentsWebAssemblyApplicationBuilderExtensions.UseBlazorFrameworkFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.componentswebassemblyapplicationbuilderextensions.useblazorframeworkfiles%2a) in apps that serve Blazor WebAssembly framework files, and explicitly calling [Microsoft.AspNetCore.Builder.ComponentsWebAssemblyApplicationBuilderExtensions.UseBlazorFrameworkFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.componentswebassemblyapplicationbuilderextensions.useblazorframeworkfiles%2a) in a Blazor Web App isn't necessary because the API is automatically called when invoking [Microsoft.Extensions.DependencyInjection.WebAssemblyRazorComponentsBuilderExtensions.AddInteractiveWebAssemblyComponents *](https://learn.microsoft.com/dotnet/api/microsoft.extensions.dependencyinjection.webassemblyrazorcomponentsbuilderextensions.addinteractivewebassemblycomponents%2a).

When [Interactive WebAssembly or Interactive Auto render modes](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/index#render-modes) are enabled:

* Blazor creates an endpoint to expose the resource collection as a JS module.
* The URL is emitted to the body of the request as persisted component state when a WebAssembly component is rendered into the page.
* During WebAssembly boot, Blazor retrieves the URL, imports the module, and calls a function to retrieve the asset collection and reconstruct it in memory. The URL is specific to the content and cached forever, so this overhead cost is only paid once per user until the app is updated.
* The resource collection is also exposed at a human-readable URL (`_framework/resource-collection.js`), so JS has access to the resource collection for [enhanced navigation](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/navigation#enhanced-navigation-and-form-handling) or to implement features of other frameworks and third-party components.

Static File Middleware ([Microsoft.AspNetCore.Builder.StaticFileExtensions.UseStaticFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticfileextensions.usestaticfiles%2a)) is useful in the following situations that Map Static Assets ([Microsoft.AspNetCore.Builder.StaticAssetsEndpointRouteBuilderExtensions.MapStaticAssets *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticassetsendpointroutebuilderextensions.mapstaticassets%2a)) can't handle:

* Serving files from disk that aren't part of the build or publish process, for example, files added to the application folder during or after deployment.
* Applying a path prefix to Blazor WebAssembly static asset files, which is covered in the [Prefix for Blazor WebAssembly assets](#prefix-for-blazor-webassembly-assets) section.
* Configuring file mappings of extensions to specific content types and setting static file options, which is covered in the [File mappings and static file options](#file-mappings-and-static-file-options) section.
      
For more information, see [static-files](https://learn.microsoft.com/aspnet/core/fundamentals/static-files).

## Deliver assets with Map Static Assets routing endpoint conventions

*This section applies to server-side Blazor apps.*

Assets are delivered via the [Microsoft.AspNetCore.Components.ComponentBase.Assets?displayProperty=nameWithType](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.componentbase.assets?displayproperty=namewithtype) property, which resolves the fingerprinted URL for a given asset. In the following example, Bootstrap, the Blazor project template app stylesheet (`app.css`), and the [CSS isolation stylesheet](https://learn.microsoft.com/aspnet/core/blazor/components/css-isolation) (based on an app's namespace of `BlazorSample`) are linked in a root component, typically the `App` component (`Components/App.razor`):

```razor
<link rel="stylesheet" href="@Assets["bootstrap/bootstrap.min.css"]" />
<link rel="stylesheet" href="@Assets["app.css"]" />
<link rel="stylesheet" href="@Assets["BlazorSample.styles.css"]" />
```

## `ImportMap` component

*This section applies to Blazor Web Apps that call [Microsoft.AspNetCore.Builder.RazorComponentsEndpointRouteBuilderExtensions.MapRazorComponents *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.razorcomponentsendpointroutebuilderextensions.maprazorcomponents%2a).*

The `ImportMap` component ([Microsoft.AspNetCore.Components.ImportMap](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.importmap)) represents an import map element (`<script type="importmap"></script>`) that defines the import map for module scripts. The Import Map component is placed in `<head>` content of the root component, typically the `App` component (`Components/App.razor`).

```razor
<ImportMap />
```

If a custom [Microsoft.AspNetCore.Components.ImportMapDefinition](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.importmapdefinition) isn't assigned to an Import Map component, the import map is generated based on the app's assets.

> [!NOTE]
> [Microsoft.AspNetCore.Components.ImportMapDefinition](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.importmapdefinition) instances are expensive to create, so we recommended caching them when creating an additional instance.

The following examples demonstrate custom import map definitions and the import maps that they create.

Basic import map:

```csharp
new ImportMapDefinition(
    new Dictionary<string, string>
    {
        { "jquery", "https://cdn.example.com/jquery.js" },
    },
    null,
    null);
```

The preceding code results in the following import map:

```json
{
  "imports": {
    "jquery": "https://cdn.example.com/jquery.js"
  }
}
```

Scoped import map:

```csharp
new ImportMapDefinition(
    null,
    new Dictionary<string, IReadOnlyDictionary<string, string>>
    {
        ["/scoped/"] = new Dictionary<string, string>
        {
            { "jquery", "https://cdn.example.com/jquery.js" },
        }
    },
    null);
```

The preceding code results in the following import map:

```json
{
  "scopes": {
    "/scoped/": {
      "jquery": "https://cdn.example.com/jquery.js"
    }
  }
}
```

Import map with integrity:

```csharp
new ImportMapDefinition(
    new Dictionary<string, string>
    {
        { "jquery", "https://cdn.example.com/jquery.js" },
    },
    null,
    new Dictionary<string, string>
    {
        { "https://cdn.example.com/jquery.js", "sha384-abc123" },
    });
```

The preceding code results in the following import map:

```json
{
  "imports": {
    "jquery": "https://cdn.example.com/jquery.js"
  },
  "integrity": {
    "https://cdn.example.com/jquery.js": "sha384-abc123"
  }
}
```

Combine import map definitions ([Microsoft.AspNetCore.Components.ImportMapDefinition](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.importmapdefinition)) with [Microsoft.AspNetCore.Components.ImportMapDefinition.Combine *?displayProperty=nameWithType](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.importmapdefinition.combine%2a?displayproperty=namewithtype).

Import map created from a [Microsoft.AspNetCore.Components.ResourceAssetCollection](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.resourceassetcollection) that maps static assets to their corresponding unique URLs:

```csharp
ImportMapDefinition.FromResourceCollection(
    new ResourceAssetCollection(
    [
        new ResourceAsset(
            "jquery.fingerprint.js",
            [
                new ResourceAssetProperty("integrity", "sha384-abc123"),
                new ResourceAssetProperty("label", "jquery.js"),
            ])
    ]));
```

The preceding code results in the following import map:

```json
{
  "imports": {
    "./jquery.js": "./jquery.fingerprint.js"
  },
  "integrity": {
    "jquery.fingerprint.js": "sha384-abc123"
  }
}
```

## Import map Content Security Policy (CSP) violations

*This section applies to Blazor Web Apps that call [Microsoft.AspNetCore.Builder.RazorComponentsEndpointRouteBuilderExtensions.MapRazorComponents *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.razorcomponentsendpointroutebuilderextensions.maprazorcomponents%2a).*

The `ImportMap` component is rendered as an inline `<script>` tag, which violates a strict [Content Security Policy (CSP)](https://developer.mozilla.org/docs/Web/HTTP/Guides/CSP) that sets the `default-src` or `script-src` directive.

For examples of how to address the policy violation with Subresource Integrity (SRI) or a cryptographic nonce, see [Resolving CSP violations with Subresource Integrity (SRI) or a nonce](https://learn.microsoft.com/aspnet/core/blazor/security/content-security-policy#resolving-csp-violations-with-subresource-integrity-sri-or-a-cryptographic-nonce).

:::moniker-end

:::moniker range="< aspnetcore-9.0"

Configure Static File Middleware to serve static assets to clients by calling [Microsoft.AspNetCore.Builder.StaticFileExtensions.UseStaticFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticfileextensions.usestaticfiles%2a) in the app's request processing pipeline. For more information, see [static-files](https://learn.microsoft.com/aspnet/core/fundamentals/static-files).

In releases prior to .NET 8, Blazor framework static files, such as the Blazor script, are served via Static File Middleware. In .NET 8 or later, Blazor framework static files are mapped using endpoint routing, and Static File Middleware is no longer used.

:::moniker-end

:::moniker range=">= aspnetcore-10.0"

## Fingerprint client-side static assets in standalone Blazor WebAssembly apps

In standalone Blazor WebAssembly apps during build and publish, the framework overrides placeholders in `index.html` with values computed during build to fingerprint static assets for client-side rendering. A [fingerprint](https://wikipedia.org/wiki/Fingerprint_(computing)) is placed into the `blazor.webassembly.js` script file name, and an import map is generated for other .NET assets.

The following configuration must be present in the `wwwwoot/index.html` file of a standalone Blazor WebAssembly app to adopt fingerprinting:

```html
<head>
    ...
    <script type="importmap"></script>
    ...
</head>

<body>
    ...
    <script src="_framework/blazor.webassembly#[.{fingerprint}].js"></script>
    ...
</body>

</html>
```

In the project file (`.csproj`), the `<OverrideHtmlAssetPlaceholders>` property is set to `true`:

```xml
<PropertyGroup>
  <OverrideHtmlAssetPlaceholders>true</OverrideHtmlAssetPlaceholders>
</PropertyGroup>
```

When resolving imports for JavaScript interop, the import map is used by the browser resolve fingerprinted files.

In the following example, all developer-supplied JS files are modules with a `.js` file extension.

A module named `scripts.js` in the app's `wwwroot/js` folder is fingerprinted by adding `#[.{fingerprint}]` before the file extension (`.js`):

```html
<script type="module" src="js/scripts#[.{fingerprint}].js"></script>
```

Specify the fingerprint expression with the `<StaticWebAssetFingerprintPattern>` property in the app's project file (`.csproj`):

```xml
<ItemGroup>
  <StaticWebAssetFingerprintPattern Include="JSModule" Pattern="*.js" 
    Expression="#[.{fingerprint}]!" />
</ItemGroup>
```

Any JS file (`*.js`) in `index.html` with the fingerprint marker is fingerprinted by the framework, including when the app is published.

## Fingerprint client-side static assets in Blazor Web Apps

For client-side rendering (CSR) in Blazor Web Apps (Interactive Auto or Interactive WebAssembly render modes), static asset server-side [fingerprinting](https://wikipedia.org/wiki/Fingerprint_(computing)) is enabled by adopting [Map Static Assets routing endpoint conventions (`MapStaticAssets`)](https://learn.microsoft.com/aspnet/core/fundamentals/static-files), [`ImportMap` component](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/static-files#importmap-component), and the [Microsoft.AspNetCore.Components.ComponentBase.Assets?displayProperty=nameWithType](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.componentbase.assets?displayproperty=namewithtype) property (`@Assets["..."]`). For more information, see [static-files](https://learn.microsoft.com/aspnet/core/fundamentals/static-files).

To fingerprint additional JavaScript modules for CSR, use the `<StaticWebAssetFingerprintPattern>` item in the app's project file (`.csproj`). In the following example, a fingerprint is added for all developer-supplied `.mjs` files in the app:

```xml
<ItemGroup>
  <StaticWebAssetFingerprintPattern Include="JSModule" Pattern="*.mjs" 
    Expression="#[.{fingerprint}]!" />
</ItemGroup>
```

When resolving imports for JavaScript interop, the import map is used by the browser resolve fingerprinted files.

:::moniker-end

## Summary of static file `<link>` `href` formats

*This section applies to all .NET releases and Blazor apps.*

The following tables summarize static file `<link>` `href` formats by .NET release.

:::moniker range=">= aspnetcore-6.0"

For the location of `<head>` content where static file links are placed, see [project-structure](https://learn.microsoft.com/aspnet/core/blazor/project-structure#location-of-head-and-body-content). Static asset links can also be supplied using [`<HeadContent>` components](https://learn.microsoft.com/aspnet/core/blazor/components/control-head-content) in individual Razor components.

:::moniker-end

:::moniker range="< aspnetcore-6.0"

For the location of `<head>` content where static file links are placed, see [project-structure](https://learn.microsoft.com/aspnet/core/blazor/project-structure#location-of-head-and-body-content).

:::moniker-end

### .NET 9 or later

App type | `href` value | Examples
--- | --- | ---
Blazor Web App | `@Assets["{PATH}"]` | `<link rel="stylesheet" href="@Assets["app.css"]" />`<br>`<link href="@Assets["_content/ComponentLib/styles.css"]" rel="stylesheet" />`
Blazor Server&dagger; | `@Assets["{PATH}"]` | `<link href="@Assets["css/site.css"]" rel="stylesheet" />`<br>`<link href="@Assets["_content/ComponentLib/styles.css"]" rel="stylesheet" />`
Standalone Blazor WebAssembly | `{PATH}` | `<link rel="stylesheet" href="css/app.css" />`<br>`<link href="_content/ComponentLib/styles.css" rel="stylesheet" />`

### .NET 8.x

App type | `href` value | Examples
--- | --- | ---
Blazor Web App | `{PATH}` | `<link rel="stylesheet" href="app.css" />`<br>`<link href="_content/ComponentLib/styles.css" rel="stylesheet" />`
Blazor Server&dagger; | `{PATH}` | `<link href="css/site.css" rel="stylesheet" />`<br>`<link href="_content/ComponentLib/styles.css" rel="stylesheet" />`
Standalone Blazor WebAssembly | `{PATH}` | `<link rel="stylesheet" href="css/app.css" />`<br>`<link href="_content/ComponentLib/styles.css" rel="stylesheet" />`

### .NET 7.x or earlier

App type | `href` value | Examples
--- | --- | ---
Blazor Server&dagger; | `{PATH}` | `<link href="css/site.css" rel="stylesheet" />`<br>`<link href="_content/ComponentLib/styles.css" rel="stylesheet" />`
Hosted Blazor WebAssembly&Dagger; | `{PATH}` | `<link href="css/app.css" rel="stylesheet" />`<br>`<link href="_content/ComponentLib/styles.css" rel="stylesheet" />`
Blazor WebAssembly | `{PATH}` | `<link href="css/app.css" rel="stylesheet" />`<br>`<link href="_content/ComponentLib/styles.css" rel="stylesheet" />`

&dagger;Blazor Server is supported in .NET 8 or later but is no longer a project template after .NET 7.  
&Dagger;We recommend updating Hosted Blazor WebAssembly apps to Blazor Web Apps when adopting .NET 8 or later.


## Static Web Asset Project Mode

*This section applies to the `.Client` project of a Blazor Web App.*

The required `<StaticWebAssetProjectMode>Default</StaticWebAssetProjectMode>` setting in the `.Client` project of a Blazor Web App reverts Blazor WebAssembly static asset behaviors back to the defaults, so that the project behaves as part of the hosted project. The Blazor WebAssembly SDK (`Microsoft.NET.Sdk.BlazorWebAssembly`) configures static web assets in a specific way to work in "standalone" mode with a server simply consuming the outputs from the library. This isn't appropriate for a Blazor Web App, where the WebAssembly portion of the app is a logical part of the host and must behave more like a library. For example, the project doesn't expose the styles bundle (for example, `BlazorSample.Client.styles.css`) and instead only provides the host with the project bundle, so that the host can include it in its own styles bundle.

Changing the value (`Default`) of `<StaticWebAssetProjectMode>` or removing the property from the `.Client` project isn't supported.



## Prefix for Blazor WebAssembly assets

*This section applies to Blazor Web Apps.*

Use the [Microsoft.AspNetCore.Components.WebAssembly.Server.WebAssemblyComponentsEndpointOptions.PathPrefix?displayProperty=nameWithType](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.webassembly.server.webassemblycomponentsendpointoptions.pathprefix?displayproperty=namewithtype) endpoint option to set the path string that indicates the prefix for Blazor WebAssembly assets. The path must correspond to a referenced Blazor WebAssembly application project.

```csharp
endpoints.MapRazorComponents<App>()
    .AddInteractiveWebAssemblyRenderMode(options => 
        options.PathPrefix = "{PATH PREFIX}");
```

In the preceding example, the `{PATH PREFIX}` placeholder is the path prefix and must start with a forward slash (`/`).

In the following example, the path prefix is set to `/path-prefix`:

```csharp
endpoints.MapRazorComponents<App>()
    .AddInteractiveWebAssemblyRenderMode(options => 
        options.PathPrefix = "/path-prefix");
```


## Static web asset base path


*This section applies to standalone Blazor WebAssembly apps.*

Publishing the app places the app's static assets, including Blazor framework files (`_framework` folder assets), at the root path (`/`) in published output. The `<StaticWebAssetBasePath>` property specified in the project file (`.csproj`) sets the base path to a non-root path:

```xml
<PropertyGroup>
  <StaticWebAssetBasePath>{PATH}</StaticWebAssetBasePath>
</PropertyGroup>
```

In the preceding example, the `{PATH}` placeholder is the path.

Without setting the `<StaticWebAssetBasePath>` property, a standalone app is published at `/BlazorStandaloneSample/bin/Release/{TFM}/publish/wwwroot/`.

In the preceding example, the `{TFM}` placeholder is the [Target Framework Moniker (TFM)](/dotnet/standard/frameworks).

If the `<StaticWebAssetBasePath>` property in a standalone Blazor WebAssembly app sets the published static asset path to `app1`, the root path to the app in published output is `/app1`.

In the standalone Blazor WebAssembly app's project file (`.csproj`):

```xml
<PropertyGroup>
  <StaticWebAssetBasePath>app1</StaticWebAssetBasePath>
</PropertyGroup>
```

In published output, the path to the standalone Blazor WebAssembly app is `/BlazorStandaloneSample/bin/Release/{TFM}/publish/wwwroot/app1/`.

In the preceding example, the `{TFM}` placeholder is the [Target Framework Moniker (TFM)](/dotnet/standard/frameworks).





## Serve files from multiple locations

*The guidance in this section only applies to Blazor Web Apps.*

To serve files from multiple locations with a [Microsoft.Extensions.FileProviders.CompositeFileProvider](https://learn.microsoft.com/dotnet/api/microsoft.extensions.fileproviders.compositefileprovider):

* Add the namespace for [Microsoft.Extensions.FileProviders?displayProperty=fullName](https://learn.microsoft.com/dotnet/api/microsoft.extensions.fileproviders?displayproperty=fullname) to the top of the `Program` file of the server project.
* In the server project's `Program` file ***before*** the call to [Microsoft.AspNetCore.Builder.StaticFileExtensions.UseStaticFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticfileextensions.usestaticfiles%2a):
  * Create a [Microsoft.Extensions.FileProviders.PhysicalFileProvider](https://learn.microsoft.com/dotnet/api/microsoft.extensions.fileproviders.physicalfileprovider) with the path to the static assets.
  * Create a [Microsoft.Extensions.FileProviders.CompositeFileProvider](https://learn.microsoft.com/dotnet/api/microsoft.extensions.fileproviders.compositefileprovider) from the [Microsoft.AspNetCore.Hosting.IWebHostEnvironment.WebRootFileProvider](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.hosting.iwebhostenvironment.webrootfileprovider) and the [Microsoft.Extensions.FileProviders.PhysicalFileProvider](https://learn.microsoft.com/dotnet/api/microsoft.extensions.fileproviders.physicalfileprovider). Assign the composite file provider back to the app's [Microsoft.AspNetCore.Hosting.IWebHostEnvironment.WebRootFileProvider](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.hosting.iwebhostenvironment.webrootfileprovider).

Example:

Create a new folder in the server project named `AdditionalStaticAssets`. Place an image into the folder.

Add the following `using` statement to the top of the server project's `Program` file:

```csharp
using Microsoft.Extensions.FileProviders;
```

In the server project's `Program` file ***before*** the call to [Microsoft.AspNetCore.Builder.StaticFileExtensions.UseStaticFiles *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.builder.staticfileextensions.usestaticfiles%2a), add the following code:

```csharp
var secondaryProvider = new PhysicalFileProvider(
    Path.Combine(builder.Environment.ContentRootPath, "AdditionalStaticAssets"));
app.Environment.WebRootFileProvider = new CompositeFileProvider(
    app.Environment.WebRootFileProvider, secondaryProvider);
```

In the app's `Home` component (`Home.razor`) markup, reference the image with an `<img>` tag:

```razor
<img src="{IMAGE FILE NAME}" alt="{ALT TEXT}" />
```

In the preceding example:

* The `{IMAGE FILE NAME}` placeholder is the image file name. There's no need to provide a path segment if the image file is at the root of the `AdditionalStaticAssets` folder.
* The `{ALT TEXT}` placeholder is the image alternate text.

Run the app.


## Additional resources


* [app-base-path](https://learn.microsoft.com/aspnet/core/blazor/host-and-deploy/app-base-path)
* [Avoid file capture in a route parameter](/fundamentals/routing#avoid-file-capture-in-a-route-parameter)


