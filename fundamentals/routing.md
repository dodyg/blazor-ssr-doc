---
title: ASP.NET Core Blazor Routing
description: Learn about Blazor Static SSR routing and navigation.

section: Fundamentals
toc: true
---

# ASP.NET Core Blazor Routing

This article explains routing in Blazor Static SSR applications.

## Route Templates

Define routes with the `@page` directive:

```razor
@page "/"

<h1>Home</h1>
<p>Welcome to the home page.</p>
```

### Multiple Routes

A component can have multiple routes:

```razor
@page "/about"
@page "/about-us"

<h1>About Us</h1>
```

### Route Parameters

Capture route parameters:

```razor
@page "/product/{id:int}"

<h1>Product @Id</h1>

@code {
    [Parameter]
    public int Id { get; set; }
}
```

### Optional Parameters

Make parameters optional:

```razor
@page "/search/{query?}"

<h1>Search Results</h1>
<p>Searching for: @(Query ?? "all products")</p>

@code {
    [Parameter]
    public string? Query { get; set; }

    protected override void OnInitialized()
    {
        Query ??= ""; // Set default value
    }
}
```

### Route Constraints

Use constraints to enforce parameter types:

| Constraint | Example | Description |
|------------|---------|-------------|
| `int` | `{id:int}` | Integer |
| `long` | `{id:long}` | Long integer |
| `guid` | `{id:guid}` | GUID |
| `bool` | `{active:bool}` | Boolean |
| `datetime` | `{date:datetime}` | DateTime |
| `decimal` | `{price:decimal}` | Decimal |
| `double` | `{weight:double}` | Double |
| `float` | `{score:float}` | Float |

Example:

```razor
@page "/user/{id:guid}"
@page "/order/{orderId:int}"

<h1>Details</h1>

@code {
    [Parameter]
    public Guid Id { get; set; }

    [Parameter]
    public int OrderId { get; set; }
}
```

### Catch-All Routes

Capture multiple segments:

```razor
@page "/docs/{*pagePath}"

<h1>Documentation</h1>
<p>Path: @PagePath</p>

@code {
    [Parameter]
    public string? PagePath { get; set; }
}
```

## Query Strings

Access query string parameters:

```razor
@page "/search"
@inject NavigationManager Navigation

<h1>Search</h1>
<p>Query: @searchQuery</p>

@code {
    private string? searchQuery;

    protected override void OnInitialized()
    {
        var uri = new Uri(Navigation.Uri);
        searchQuery = System.Web.HttpUtility.ParseQueryString(uri.Query).Get("q");
    }
}
```

Or use `[SupplyParameterFromQuery]`:

```razor
@page "/products"

<h1>Products</h1>
<p>Category: @Category</p>
<p>Page: @Page</p>

@code {
    [SupplyParameterFromQuery]
    public string? Category { get; set; }

    [SupplyParameterFromQuery]
    public int Page { get; set; } = 1;
}
```

## Navigation

### NavigationManager

Inject `NavigationManager` for navigation features:

```razor
@page "/dashboard"
@inject NavigationManager Navigation

<h1>Dashboard</h1>

<button @onclick="NavigateHome">Go Home</button>
<a href="@Navigation.GetUriWithQueryParameter("page", 2)">Page 2</a>

@code {
    private void NavigateHome()
    {
        Navigation.NavigateTo("/");
    }
}
```

### Navigation Features

```razor
@page "/navigation-demo"
@inject NavigationManager Navigation

<h1>Navigation Features</h1>

<ul>
    <li>Base URI: @Navigation.BaseUri</li>
    <li>Current URI: @Navigation.Uri</li>
</ul>

<button @onclick="GoBack">Go Back</button>
<button @onclick="Refresh">Refresh</button>

@code {
    private void GoBack()
    {
        // Navigate back in history
        Navigation.NavigateTo(Navigation.Uri);
    }

    private void Refresh()
    {
        // Refresh current page
        Navigation.Refresh();
    }
}
```

### Navigation Links

Use standard anchor tags for navigation:

```razor
<nav>
    <a href="/">Home</a>
    <a href="/products">Products</a>
    <a href="/about">About</a>
</nav>
```

## Enhanced Navigation

Blazor provides enhanced navigation that updates content without full page reloads. It is available when the app loads `_framework/blazor.web.js`, the destination is inside the app's base URI, and the feature hasn't been disabled. No interactive render mode or SignalR circuit is required.

```csharp
// Program.cs
builder.Services.AddRazorComponents();

// Later in the pipeline:
app.MapRazorComponents<App>();
```

Enhanced navigation:
- Intercepts internal link clicks
- Fetches content via enhanced navigation request
- Updates DOM without full page reload
- Preserves scroll position

Disable it for one link or for a hierarchy of links with `data-enhance-nav="false"`:

```html
<a href="/reports" data-enhance-nav="false">Full-load reports</a>

<nav data-enhance-nav="false">
    <a href="/account">Account</a>
    <a href="/sign-out">Sign out</a>
</nav>
```

If the destination isn't a Blazor endpoint, the browser falls back to a full-page load. `NavigationManager.NavigateTo` uses enhanced navigation when available unless `forceLoad` is `true`. `NavigationManager.Refresh()` also prefers enhancement; call `NavigationManager.Refresh(forceLoad: true)` to guarantee a full request.

### Enhanced Form Posts

Enhanced forms post to the server and patch the response into the document:

```razor
<EditForm Model="Model" FormName="Search" Enhance
          OnValidSubmit="Search">
    ...
</EditForm>
```

For an HTML form, add `data-enhance` directly to the `<form>` element. Unlike link enhancement, form enhancement isn't inherited from an ancestor. Enhanced posts only work with Blazor endpoints.

JavaScript changes that aren't part of the server-rendered response may be undone by DOM patching. Add `data-permanent` to narrowly preserve a client-managed element, and use the `enhancedload` event to reapply page behavior. See [JavaScript with Static SSR](/advanced/javascript).

## Link Helpers

### NavLink Component

Highlight active navigation links:

```razor
<nav>
    <NavLink href="/" Match="NavLinkMatch.All" class="nav-link">
        Home
    </NavLink>
    <NavLink href="/products" Match="NavLinkMatch.Prefix" class="nav-link">
        Products
    </NavLink>
</nav>

<style>
    .nav-link.active {
        font-weight: bold;
    }
</style>
```

### Match Modes

- `NavLinkMatch.All` - Exact path match
- `NavLinkMatch.Prefix` - Path prefix match (default)

## Route to Components

Components are routed via the `App.razor` component:

```razor
@* App.razor *@
<!DOCTYPE html>
<html>
<head>
    <HeadOutlet />
</head>
<body>
    <Routes />
    <script src="_framework/blazor.web.js"></script>
</body>
</html>
```

```razor
@* Routes.razor *@
<Router AppAssembly="typeof(Program).Assembly">
    <Found Context="routeData">
        <RouteView RouteData="routeData" DefaultLayout="typeof(MainLayout)" />
        <FocusOnNavigate RouteData="routeData" Selector="h1" />
    </Found>
</Router>
```

## Layouts

Apply layouts to pages:

```razor
@page "/admin"
@layout AdminLayout

<h1>Admin Page</h1>
```

Or use `@layout` in `_Imports.razor`:

```razor
@* _Imports.razor *@
@layout MainLayout
```

### Default Layout

Set a default layout in `Routes.razor`:

```razor
<RouteView RouteData="routeData" DefaultLayout="typeof(MainLayout)" />
```

## Static vs Interactive Routing

In Static SSR:

- Each navigation triggers an HTTP request
- Server renders fresh HTML for each page
- Full page lifecycle executes per request
- Enhanced navigation can make the request with `fetch` and patch the returned HTML without creating an interactive router

## Redirects During Static SSR

Historically, `NavigationManager.NavigateTo` implemented a Static SSR redirect by throwing `NavigationException`, which the framework converted into a redirect response. In a .NET 10 project, opt into the non-throwing behavior with the following project property (new .NET 10 templates enable it by default):

```xml
<PropertyGroup>
  <BlazorDisableThrowNavigationException>true</BlazorDisableThrowNavigationException>
</PropertyGroup>
```

With the property enabled, code after `NavigateTo` runs. Without it, control doesn't return to the caller during Static SSR and a debugger may break on the framework-handled exception.

## Not Found Pages

In .NET 10, call `NavigationManager.NotFound()` when a requested resource doesn't exist. During Static SSR this sets the HTTP response status to 404:

```razor
@page "/products/{Id:int}"
@inject NavigationManager Navigation

@code {
    [Parameter]
    public int Id { get; set; }

    protected override async Task OnInitializedAsync()
    {
        var product = await Products.FindAsync(Id);

        if (product is null)
        {
            Navigation.NotFound();
        }
    }
}
```

The .NET 10 `Router` no longer supports the old `<NotFound>...</NotFound>` render fragment. Assign a routable Not Found component to `NotFoundPage`:

```razor
@* Routes.razor *@
<Router AppAssembly="typeof(Program).Assembly"
        NotFoundPage="typeof(Pages.NotFound)">
    <Found Context="routeData">
        <RouteView RouteData="routeData" DefaultLayout="typeof(MainLayout)" />
    </Found>
</Router>
```

```razor
@* Pages/NotFound.razor *@
@page "/not-found"
@layout MainLayout

<PageTitle>Not found</PageTitle>
<h1>Page not found</h1>
<p>The requested content doesn't exist.</p>
```

For unknown browser URLs and non-Blazor endpoints, configure Status Code Pages re-execution before mapping components:

```csharp
app.UseStatusCodePagesWithReExecute(
    "/not-found", createScopeForStatusCodePages: true);
```

A routable page is also required to display Not Found content after a streaming response begins. With enhanced navigation, Blazor can patch that page into the document; without enhancement, it reloads the Not Found URL.

## Best Practices

1. **Use route constraints** to enforce parameter types
2. **Handle optional parameters** with default values
3. **Use NavLink** for active link highlighting
4. **Organize routes** logically
5. **Consider SEO** - use clean, semantic URLs

## Additional Resources

- [ASP.NET Core Blazor routing](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/routing)
- [ASP.NET Core Blazor layouts](https://learn.microsoft.com/aspnet/core/blazor/components/layouts)
- [ASP.NET Core Blazor navigation](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/navigation)
