---
title: Prerendering and Streaming Rendering
description: Learn about prerendering and streaming rendering in Blazor Static SSR.
layout: page
section: Components
toc: true
---

# Prerendering and Streaming Rendering

This article explains prerendering and streaming rendering for Blazor Static SSR applications.

## What is Prerendering?

Prerendering is the process of rendering page content on the server to deliver HTML to the browser as quickly as possible. In Static SSR, prerendering is the default behavior - components are rendered on every request.

Prerendering provides:

- **Fast initial load**: Users see content immediately
- **SEO benefits**: Search engines can index the fully rendered content
- **Progressive enhancement**: Content is available before JavaScript loads

## Streaming Rendering

Streaming rendering improves the user experience for pages that perform long-running asynchronous operations. Instead of waiting for all data to load before sending any content, streaming rendering sends initial content immediately and streams updates as data becomes available.

### Enable Streaming Rendering

Add the `[StreamRendering]` attribute to your component:

```razor
@page "/weather"
@attribute [StreamRendering]
@inject WeatherService WeatherService

<h1>Weather Forecast</h1>

@if (forecasts == null)
{
    <p><em>Loading weather data...</em></p>
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
        // Simulate a long-running operation
        await Task.Delay(2000);
        forecasts = await WeatherService.GetForecastAsync();
    }
}
```

### How Streaming Rendering Works

1. **Initial Response**: The server sends the initial HTML with the "Loading..." message
2. **Async Operation**: The `OnInitializedAsync` method executes
3. **Streaming Update**: When data is available, the server streams the updated content
4. **DOM Update**: The browser patches the new content into the page

### When to Use Streaming Rendering

Use streaming rendering when your component:

- Performs database queries
- Calls external APIs
- Has significant async initialization
- Would benefit from showing placeholder content

## Static SSR Rendering Patterns

### Per-Request Rendering

In Static SSR, components are rendered for each HTTP request:

```razor
@page "/time"

<h1>Current Time</h1>
<p>The server time is: @DateTime.Now</p>
```

Each time a user navigates to this page, the server renders a fresh response with the current time.

### Data Loading

Load data during initialization for Static SSR:

```razor
@page "/products"
@inject ProductService ProductService

<h1>Products</h1>

@if (products == null)
{
    <p>Loading products...</p>
}
else if (products.Length == 0)
{
    <p>No products found.</p>
}
else
{
    <ul>
        @foreach (var product in products)
        {
            <li>@product.Name - $@product.Price</li>
        }
    </ul>
}

@code {
    private Product[]? products;

    protected override async Task OnInitializedAsync()
    {
        products = await ProductService.GetProductsAsync();
    }
}
```

### Streaming with Long-Running Operations

For operations that take time, combine streaming rendering with a good loading UX:

```razor
@page "/search"
@attribute [StreamRendering]
@inject SearchService SearchService

<h1>Search Results</h1>

<EditForm Model="@searchModel" OnValidSubmit="@HandleSearch" FormName="SearchForm">
    <AntiforgeryToken />
    <InputText @bind-Value="searchModel.Query" placeholder="Search..." />
    <button type="submit">Search</button>
</EditForm>

@if (results != null)
{
    @if (results.Length == 0)
    {
        <p>No results found for "@searchModel.Query"</p>
    }
    else
    {
        <ul>
            @foreach (var result in results)
            {
                <li>
                    <a href="@result.Url">@result.Title</a>
                    <p>@result.Description</p>
                </li>
            }
        </ul>
    }
}

@code {
    private SearchModel searchModel = new();
    private SearchResult[]? results;

    [SupplyParameterFromForm]
    private SearchModel? FormSearchModel { get; set; }

    protected override async Task OnInitializedAsync()
    {
        if (FormSearchModel != null)
        {
            searchModel = FormSearchModel;
            await HandleSearch();
        }
    }

    private async Task HandleSearch()
    {
        results = await SearchService.SearchAsync(searchModel.Query);
    }

    public class SearchModel
    {
        [Required]
        public string Query { get; set; } = "";
    }
}
```

## Limitations in Static SSR

Remember these limitations:

- **No `OnAfterRender`**: This lifecycle method is never called in Static SSR
- **No JavaScript interop during render**: JS calls only work after the page loads
- **No circuit state**: Each request is independent

## Best Practices

1. **Use streaming rendering** for long-running async operations
2. **Show loading states** while data is being fetched
3. **Handle null/empty states** gracefully
4. **Keep async operations focused** to avoid long wait times
5. **Consider caching** for frequently accessed data

## Additional Resources

- [ASP.NET Core Blazor component rendering](https://learn.microsoft.com/aspnet/core/blazor/components/rendering)
- [ASP.NET Core Blazor fundamentals](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/)
