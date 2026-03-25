---
title: ASP.NET Core Razor Component Lifecycle
description: Learn about the Razor component lifecycle in Blazor Static SSR.

section: Components
toc: true
---

# ASP.NET Core Razor Component Lifecycle

This article explains the Razor component lifecycle in Blazor Static SSR.

## Lifecycle in Static SSR

In Static Server-Side Rendering, components follow a simpler lifecycle than interactive Blazor. Components are created, initialized, and rendered for each HTTP request.

### Lifecycle Events

1. **Set Parameters** - `SetParametersAsync`
2. **Initialize** - `OnInitialized` / `OnInitializedAsync`
3. **Set Parameters Again** - `OnParametersSet` / `OnParametersSetAsync`
4. **Render** - Component produces HTML output

**Important**: `OnAfterRender` and `OnAfterRenderAsync` are **never called** in Static SSR.

## SetParametersAsync

`SetParametersAsync` receives parameters from the parent component or route:

```razor
@page "/product/{id:int}"
@inject ProductService ProductService

<h1>Product @Id</h1>

@code {
    [Parameter]
    public int Id { get; set; }

    public override async Task SetParametersAsync(ParameterView parameters)
    {
        await base.SetParametersAsync(parameters);
        
        // Id is now available
        Console.WriteLine($"Product ID set to: {Id}");
    }
}
```

## OnInitialized / OnInitializedAsync

These methods run when the component is first created. Use them for one-time initialization:

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
            <li>@product.Name</li>
        }
    </ul>
}

@code {
    private List<Product>? products;

    protected override async Task OnInitializedAsync()
    {
        // Runs once per request
        products = await ProductService.GetProductsAsync();
    }
}
```

### When to Use OnInitializedAsync

- Loading data from APIs or databases
- One-time setup operations
- Initializing component state

### Synchronous vs Asynchronous

```csharp
// Synchronous
protected override void OnInitialized()
{
    // Quick synchronous initialization
    currentTime = DateTime.Now;
}

// Asynchronous
protected override async Task OnInitializedAsync()
{
    // Async operations like API calls
    data = await DataService.GetDataAsync();
}
```

## OnParametersSet / OnParametersSetAsync

These methods run after parameters have been set from a parent component:

```razor
@page "/search"
@inject SearchService SearchService

<h1>Search Results for "@Query"</h1>

@if (results != null)
{
    <ul>
        @foreach (var result in results)
        {
            <li>@result.Title</li>
        }
    </ul>
}

@code {
    [Parameter]
    public string? Query { get; set; }

    private List<SearchResult>? results;

    protected override async Task OnParametersSetAsync()
    {
        // Runs when Query changes
        if (!string.IsNullOrEmpty(Query))
        {
            results = await SearchService.SearchAsync(Query);
        }
    }
}
```

### When to Use OnParametersSetAsync

- Reacting to parameter changes
- Re-fetching data based on updated parameters
- Derived state calculations

## Component Lifecycle Example

```razor
@page "/lifecycle-demo/{id:int}"
@inject ProductService ProductService
@inject ILogger<LifecycleDemo> Logger

<h1>Lifecycle Demo</h1>
<p>Product ID: @Id</p>
<p>Product: @product?.Name</p>
<p>Processed at: @processedAt</p>

@code {
    [Parameter]
    public int Id { get; set; }

    private Product? product;
    private DateTime processedAt;

    public override Task SetParametersAsync(ParameterView parameters)
    {
        Logger.LogInformation("SetParametersAsync called");
        return base.SetParametersAsync(parameters);
    }

    protected override async Task OnInitializedAsync()
    {
        Logger.LogInformation("OnInitializedAsync called with Id={Id}", Id);
        product = await ProductService.GetProductAsync(Id);
    }

    protected override void OnParametersSet()
    {
        Logger.LogInformation("OnParametersSet called");
        processedAt = DateTime.Now;
    }
}
```

## Loading Data

The recommended pattern for loading data in Static SSR:

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
        // Load data during initialization
        forecasts = await WeatherService.GetForecastAsync();
    }
}
```

## Streaming Rendering

Use streaming rendering for long-running data operations:

```razor
@page "/slow-data"
@attribute [StreamRendering]
@inject DataService DataService

<h1>Slow Loading Data</h1>

@if (data == null)
{
    <p><em>Loading data (this may take a moment)...</em></p>
}
else
{
    <p>Data loaded: @data.Count items</p>
}

@code {
    private List<DataItem>? data;

    protected override async Task OnInitializedAsync()
    {
        // Initial HTML with "Loading..." is sent immediately
        // This data loads later and streams to the client
        data = await DataService.GetSlowDataAsync();
    }
}
```

## Handling Form Submissions

Use `[SupplyParameterFromForm]` to receive form data:

```razor
@page "/contact"

<h1>Contact Form</h1>

<EditForm Model="@model" OnValidSubmit="@HandleSubmit" FormName="ContactForm">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    
    <div>
        <label>Name:</label>
        <InputText @bind-Value="model.Name" />
    </div>
    
    <button type="submit">Submit</button>
</EditForm>

@if (submitted)
{
    <p>Form submitted successfully!</p>
}

@code {
    private ContactModel model = new();
    private bool submitted;

    [SupplyParameterFromForm]
    private ContactModel? FormData { get; set; }

    protected override void OnInitialized()
    {
        // On POST, FormData contains the submitted values
        if (FormData != null)
        {
            model = FormData;
            submitted = true;
        }
    }

    private void HandleSubmit()
    {
        // Process form submission
        submitted = true;
    }

    public class ContactModel
    {
        [Required]
        public string Name { get; set; } = "";
    }
}
```

## IDisposable

Implement `IDisposable` if your component needs cleanup:

```razor
@page "/timer"
@implements IDisposable
@inject TimerService TimerService

<h1>Timer Example</h1>
<p>Current time: @currentTime</p>

@code {
    private DateTime currentTime;
    private Timer? timer;

    protected override void OnInitialized()
    {
        currentTime = DateTime.Now;
        timer = new Timer(_ => 
        {
            // In Static SSR, this won't update the UI
            // This is just for demonstration
            currentTime = DateTime.Now;
        }, null, TimeSpan.FromSeconds(1), TimeSpan.FromSeconds(1));
    }

    public void Dispose()
    {
        timer?.Dispose();
    }
}
```

## Key Differences from Interactive Blazor

| Feature | Static SSR | Interactive Blazor |
|---------|-----------|-------------------|
| `OnAfterRender` | ❌ Never called | ✅ Called after render |
| `OnAfterRenderAsync` | ❌ Never called | ✅ Called after render |
| `StateHasChanged` | ❌ Not useful | ✅ Triggers rerender |
| Component lifetime | Per request | Until disposed |
| State persistence | Per request | Across interactions |

## Best Practices

1. **Load data in OnInitializedAsync** - This is the primary place for async data loading
2. **Handle loading states** - Show placeholders while data loads
3. **Don't rely on OnAfterRender** - It's never called in Static SSR
4. **Use streaming rendering** - For long-running operations
5. **Keep state simple** - Each request gets a fresh component instance

## Additional Resources

- [ASP.NET Core Blazor component rendering](https://learn.microsoft.com/aspnet/core/blazor/components/rendering)
- [ASP.NET Core Blazor components](https://learn.microsoft.com/aspnet/core/blazor/components)
