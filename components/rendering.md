---
title: ASP.NET Core Razor Component Rendering
description: Learn about component rendering in Blazor Static SSR.

section: Components
toc: true
---

# ASP.NET Core Razor Component Rendering

This article explains component rendering in Blazor Static SSR applications.

## Rendering in Static SSR

In Static SSR, rendering is straightforward:

1. **HTTP Request** - Browser requests a page
2. **Component Creation** - Server creates component instance
3. **Initialization** - Component lifecycle methods run
4. **HTML Generation** - Component renders to HTML
5. **Response** - HTML sent to browser

Unlike interactive Blazor, there's no circuit, no SignalR connection, and no client-side runtime.

## Streaming Rendering

Streaming rendering improves perceived performance by sending initial HTML immediately, then streaming content updates as async operations complete.

### Enable Streaming Rendering

```razor
@page "/weather"
@attribute [StreamRendering]
@inject WeatherService WeatherService

<h1>Weather Forecast</h1>

@if (forecasts == null)
{
    <p><em>Loading...</em></p>
}
else
{
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Temp. (C)</th>
                <th>Summary</th>
            </tr>
        </thead>
        <tbody>
            @foreach (var forecast in forecasts)
            {
                <tr>
                    <td>@forecast.Date.ToShortDateString()</td>
                    <td>@forecast.TemperatureC</td>
                    <td>@forecast.Summary</td>
                </tr>
            }
        </tbody>
    </table>
}

@code {
    private WeatherForecast[]? forecasts;

    protected override async Task OnInitializedAsync()
    {
        // Simulate slow data loading
        await Task.Delay(2000);
        forecasts = await WeatherService.GetForecastAsync();
    }
}
```

### How It Works

1. Server sends initial HTML with "Loading..." immediately
2. Async operation (data loading) executes
3. When complete, server streams updated HTML
4. Browser patches the new content in place

### When to Use Streaming Rendering

Use streaming rendering for:
- Database queries that take time
- External API calls
- Any async operation with noticeable latency

```razor
@page "/products"
@attribute [StreamRendering]

<h1>Products</h1>

@if (products == null)
{
    <div class="skeleton">
        <p>Loading products...</p>
    </div>
}
else
{
    <div class="product-grid">
        @foreach (var product in products)
        {
            <ProductCard Product="product" />
        }
    </div>
}

@code {
    private List<Product>? products;

    protected override async Task OnInitializedAsync()
    {
        products = await ProductService.GetProductsAsync();
    }
}
```

## Rendering Conventions

### Null Handling

Always handle null states gracefully:

```razor
@if (product == null)
{
    <p>Product not found</p>
}
else
{
    <h1>@product.Name</h1>
    <p>@product.Description</p>
}
```

### Loading States

Show loading indicators during async operations:

```razor
@if (data == null)
{
    <div class="loading-spinner">
        <p>Loading data...</p>
    </div>
}
else
{
    <!-- Display data -->
}
```

### Empty States

Handle empty collections:

```razor
@if (items == null)
{
    <p>Loading...</p>
}
else if (items.Count == 0)
{
    <p>No items found.</p>
}
else
{
    <ul>
        @foreach (var item in items)
        {
            <li>@item.Name</li>
        }
    </ul>
}
```

## Component Hierarchies

Components render top-down in the hierarchy:

```razor
@* Parent.razor *@
@page "/parent"

<h1>Parent Component</h1>
<Child Message="@message" />

@code {
    private string message = "Hello from parent";
}
```

```razor
@* Child.razor *@
<div class="child">
    <p>Message: @Message</p>
</div>

@code {
    [Parameter]
    public string? Message { get; set; }
}
```

### Parent-Child Data Flow

Data flows from parent to child via parameters:

```razor
@page "/dashboard"
@inject DashboardService DashboardService

@if (dashboardData == null)
{
    <p>Loading dashboard...</p>
}
else
{
    <DashboardHeader Title="@dashboardData.Title" />
    
    <div class="dashboard-content">
        <StatsWidget Stats="@dashboardData.Stats" />
        <ChartWidget Data="@dashboardData.ChartData" />
    </div>
    
    <DashboardFooter LastUpdated="@dashboardData.LastUpdated" />
}

@code {
    private DashboardData? dashboardData;

    protected override async Task OnInitializedAsync()
    {
        dashboardData = await DashboardService.GetDataAsync();
    }
}
```

## Enhanced Navigation

Blazor provides enhanced navigation that intercepts link clicks and updates content without full page reloads:

### Enable Enhanced Navigation

```csharp
// Program.cs
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents(); // Required for enhanced nav
```

### How It Works

1. User clicks a link
2. Blazor intercepts the navigation
3. Fetches new page content via enhanced navigation
4. Updates the DOM without full page reload

### Benefits

- Faster page transitions
- Preserved scroll position
- Smoother user experience

### Navigation Links

```razor
<nav>
    <a href="/">Home</a>
    <a href="/products">Products</a>
    <a href="/about">About</a>
</nav>
```

Enhanced navigation automatically applies to internal links.

## CSS Isolation

Components can have scoped CSS:

`ProductCard.razor`:

```razor
<div class="card">
    <h3>@Product?.Name</h3>
    <p>@Product?.Description</p>
</div>

@code {
    [Parameter]
    public Product? Product { get; set; }
}
```

`ProductCard.razor.css`:

```css
.card {
    border: 1px solid #ccc;
    padding: 1rem;
    border-radius: 8px;
}

.card h3 {
    margin-top: 0;
}
```

## RenderFragment

Use `RenderFragment` for flexible content composition:

```razor
@* Card.razor *@
<div class="card">
    @if (Header != null)
    {
        <div class="card-header">
            @Header
        </div>
    }
    <div class="card-body">
        @ChildContent
    </div>
    @if (Footer != null)
    {
        <div class="card-footer">
            @Footer
        </div>
    }
</div>

@code {
    [Parameter]
    public RenderFragment? ChildContent { get; set; }

    [Parameter]
    public RenderFragment? Header { get; set; }

    [Parameter]
    public RenderFragment? Footer { get; set; }
}
```

Usage:

```razor
<Card>
    <Header>
        <h2>Card Title</h2>
    </Header>
    <ChildContent>
        <p>This is the card body content.</p>
    </ChildContent>
    <Footer>
        <small>Footer content</small>
    </Footer>
</Card>
```

## Templated Components

Create reusable templates:

```razor
@* ListTemplate.razor *@
@if (Items != null)
{
    <ul class="@CssClass">
        @foreach (var item in Items)
        {
            <li>@ItemTemplate(item)</li>
        }
    </ul>
}

@code {
    [Parameter]
    public IEnumerable<T>? Items { get; set; }

    [Parameter]
    public RenderFragment<T>? ItemTemplate { get; set; }

    [Parameter]
    public string CssClass { get; set; } = "list";
}
```

Usage:

```razor
<ListTemplate Items="products" Context="product">
    <ItemTemplate>
        <strong>@product.Name</strong> - $@product.Price
    </ItemTemplate>
</ListTemplate>
```

## Best Practices

1. **Use streaming rendering** for async data loading
2. **Handle all states** - loading, empty, error, and success
3. **Keep components focused** - Single responsibility principle
4. **Use RenderFragments** for flexible composition
5. **Consider SEO** - Content should be available in initial HTML

## Differences from Interactive Blazor

| Feature | Static SSR | Interactive Blazor |
|---------|-----------|-------------------|
| Rendering | Per request | On state changes |
| `ShouldRender` | ❌ Not applicable | ✅ Controls rerendering |
| `StateHasChanged` | ❌ Not useful | ✅ Triggers rerender |
| Component state | Per request | Persistent |
| Client updates | Full page/stream | DOM patches |

## Additional Resources

- [ASP.NET Core Blazor components](https://learn.microsoft.com/aspnet/core/blazor/components)
- [ASP.NET Core Blazor component lifecycle](https://learn.microsoft.com/aspnet/core/blazor/components/lifecycle)
- [ASP.NET Core Blazor layouts](https://learn.microsoft.com/aspnet/core/blazor/components/layouts)
