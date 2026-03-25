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

Blazor provides enhanced navigation that updates content without full page reloads:

```csharp
// Program.cs
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();
```

Enhanced navigation:
- Intercepts internal link clicks
- Fetches content via enhanced navigation request
- Updates DOM without full page reload
- Preserves scroll position

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

## Not Found Pages

Handle 404 scenarios:

```razor
@* Routes.razor *@
<Router AppAssembly="typeof(Program).Assembly">
    <Found Context="routeData">
        <RouteView RouteData="routeData" DefaultLayout="typeof(MainLayout)" />
    </Found>
    <NotFound>
        <PageTitle>Not found</PageTitle>
        <LayoutView Layout="typeof(MainLayout)">
            <h1>Page not found</h1>
            <p>The page you're looking for doesn't exist.</p>
            <a href="/">Go home</a>
        </LayoutView>
    </NotFound>
</Router>
```

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
