---
title: Components
description: Deep dive into Razor components and how they work in Blazor Static SSR
layout: page
section: Components
toc: true
---

# Components

Components are the building blocks of Blazor applications. Learn how to create, use, and optimize components in your Static SSR applications.

## Topics

### [Component Basics](/components/index)
Learn the fundamentals of Razor components: their structure, syntax, and how to create reusable UI elements.

### [Rendering](/components/rendering)
Understand how components are rendered in Blazor Static SSR. Learn about rendering concepts, streaming rendering, and best practices.

### [Prerendering](/components/prerender)
Improve perceived performance with prerendering. Learn how to pre-render components to static HTML.

### [Lifecycle](/components/lifecycle)
Master the component lifecycle methods. Learn when to use OnInitialized, OnParametersSet, and other lifecycle events.

### [Cascading Values and Parameters](/components/cascading-values-and-parameters)
Share data across the component hierarchy using cascading values and parameters.

### [Data Binding](/components/data-binding)
Bind data between your components and the UI. Learn about one-way binding patterns in Static SSR.

## Component Structure

A typical Razor component consists of:

```razor
@page "/products"
@inject ProductService ProductService

<h1>Products</h1>

@if (products == null)
{
    <p>Loading...</p>
}
else
{
    <ul>
        @foreach (var product in products)
        {
            <li>
                <strong>@product.Name</strong>
                <span>$@product.Price</span>
            </li>
        }
    </ul>
}

@code {
    private List<Product>? products;

    protected override async Task OnInitializedAsync()
    {
        products = await ProductService.GetProductsAsync();
    }
}
```

## Static SSR Component Patterns

### Data Display

Components excel at displaying data from the server:

```razor
@page "/weather"
@inject WeatherService WeatherService

<h1>Weather Forecast</h1>

@if (forecasts == null)
{
    <p><em>Loading...</em></p>
}
else
{
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Temperature (C)</th>
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
        forecasts = await WeatherService.GetForecastAsync();
    }
}
```

### Reusable Components

Create reusable components that accept parameters:

```razor
@* ProductCard.razor *@
<div class="product-card">
    <h3>@Product?.Name</h3>
    <p>@Product?.Description</p>
    <span class="price">$@Product?.Price</span>
    @if (OnAddToCart.HasDelegate)
    {
        <a href="/cart/add/@Product?.Id" class="btn">Add to Cart</a>
    }
</div>

@code {
    [Parameter]
    public Product? Product { get; set; }

    [Parameter]
    public EventCallback OnAddToCart { get; set; }
}
```

### Layout Components

Define consistent page layouts:

```razor
@* MainLayout.razor *@
@inherits LayoutComponentBase

<header>
    <nav>
        <a href="/">Home</a>
        <a href="/products">Products</a>
        <a href="/about">About</a>
    </nav>
</header>

<main>
    @Body
</main>

<footer>
    <p>&copy; @DateTime.Now.Year - My Application</p>
</footer>
```

## Best Practices

- **Keep components small and focused**: Each component should have a single responsibility
- **Use parameters for input**: Pass data into components via parameters
- **Leverage cascading values**: Share common data without prop drilling
- **Handle null states**: Always handle loading and null states gracefully
- **Use streaming rendering**: For long-running data operations

## Differences from Interactive Blazor

In Static SSR, keep in mind:

| Feature | Static SSR | Interactive Blazor |
|---------|-----------|-------------------|
| Event handlers (`@onclick`) | ❌ Not available | ✅ Available |
| Two-way binding (`@bind`) | ✅ In forms | ✅ Everywhere |
| `OnAfterRender` | ❌ Never called | ✅ Called after render |
| `StateHasChanged` | ❌ Not useful | ✅ Triggers rerender |
| JavaScript interop | ⚠️ After page load | ✅ Anytime |

## Next Steps

After mastering components, explore [Forms](/forms/) to learn about handling user input with validation.
