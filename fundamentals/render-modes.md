---
title: ASP.NET Core Blazor Static Server-Side Rendering
description: Learn about Blazor Static SSR and how it renders components on the server as static HTML.

section: Fundamentals
toc: true
---

# ASP.NET Core Blazor Static Server-Side Rendering

This article explains static server-side rendering (Static SSR) in Blazor Web Apps.

## What is Static SSR?

Static Server-Side Rendering (Static SSR) is a rendering mode where Razor components are rendered on the server to produce static HTML that's sent to the browser. Unlike interactive rendering modes, Static SSR does not establish a SignalR connection for real-time interactivity.

Key characteristics of Static SSR:

- **Server-side rendering**: Components execute on the server for each request
- **Static HTML output**: The browser receives pure HTML without client-side interactivity
- **No circuit**: No persistent connection between client and server
- **Traditional web patterns**: User interactions occur through form posts and navigation

## When to Use Static SSR

Static SSR is ideal for:

- **Content-focused pages**: Blogs, documentation, marketing pages
- **SEO-critical content**: Pages that need to be indexed by search engines
- **Form-based applications**: CRUD operations, data entry, surveys
- **Public-facing websites**: Where fast initial load and SEO are priorities
- **Simple applications**: That don't require real-time interactivity

## Configuring Static SSR

A Blazor Web App uses Static SSR by default when no interactive render mode is specified.

### Basic Setup

In your `Program.cs` file:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services for Razor components
builder.Services.AddRazorComponents();

var app = builder.Build();

// Map Razor components
app.MapRazorComponents<App>();

app.Run();
```

This configuration renders all components using Static SSR by default.

### Per-Page Static SSR

To explicitly use Static SSR for a specific page, you can use the `@attribute` directive:

```razor
@page "/about"
@attribute [RenderMode.Static]

<h1>About Us</h1>
<p>This page is rendered using Static SSR.</p>
```

Or apply it via the `@rendermode` directive:

```razor
@page "/about"
@rendermode Static

<h1>About Us</h1>
```

## Component Rendering

### Rendering Process

When a request arrives for a Static SSR page:

1. **Request received**: The server receives an HTTP request
2. **Component execution**: The Razor component executes on the server
3. **HTML generation**: Component output is rendered to HTML
4. **Response sent**: Static HTML is sent to the browser

### Lifecycle Methods

In Static SSR, the following lifecycle methods execute:

- `SetParametersAsync` - Parameters are set
- `OnInitialized` / `OnInitializedAsync` - Component initialization
- `OnParametersSet` / `OnParametersSetAsync` - After parameters are set

**Note**: `OnAfterRender` and `OnAfterRenderAsync` are **not called** during Static SSR because there's no interactive DOM to update.

### Data Loading

Load data in `OnInitializedAsync` for Static SSR:

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
            <li>@product.Name - $@product.Price</li>
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

## Handling User Input

### Form Handling

In Static SSR, forms use traditional POST requests:

```razor
@page "/contact"
@inject EmailService EmailService

<h1>Contact Us</h1>

<EditForm Model="@model" OnValidSubmit="@HandleSubmit" FormName="ContactForm">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    
    <div>
        <label for="name">Name:</label>
        <InputText id="name" @bind-Value="model.Name" />
        <ValidationMessage For="@(() => model.Name)" />
    </div>
    
    <div>
        <label for="email">Email:</label>
        <InputText id="email" @bind-Value="model.Email" />
        <ValidationMessage For="@(() => model.Email)" />
    </div>
    
    <div>
        <label for="message">Message:</label>
        <InputTextArea id="message" @bind-Value="model.Message" />
        <ValidationMessage For="@(() => model.Message)" />
    </div>
    
    <button type="submit">Send</button>
</EditForm>

@if (submitted)
{
    <p>Thank you for your message!</p>
}

@code {
    private ContactModel model = new();
    private bool submitted;

    protected override void OnInitialized()
    {
        // Check if form was submitted (POST request)
        submitted = HttpContext?.Request.Method == "POST";
    }

    private async Task HandleSubmit()
    {
        await EmailService.SendAsync(model);
        submitted = true;
    }

    public class ContactModel
    {
        [Required]
        public string Name { get; set; } = "";

        [Required]
        [EmailAddress]
        public string Email { get; set; } = "";

        [Required]
        public string Message { get; set; } = "";
    }
}
```

### Navigation

Navigation in Static SSR triggers a full page request:

```razor
@page "/"

<h1>Welcome</h1>

<nav>
    <a href="/about">About</a>
    <a href="/products">Products</a>
    <a href="/contact">Contact</a>
</nav>
```

## Prerendering

Prerendering is the default behavior in Static SSR. Content is rendered on the server before being sent to the client.

### Streaming Rendering

For long-running operations, use streaming rendering to improve perceived performance:

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
                <th>Temp. (F)</th>
                <th>Summary</th>
            </tr>
        </thead>
        <tbody>
            @foreach (var forecast in forecasts)
            {
                <tr>
                    <td>@forecast.Date.ToShortDateString()</td>
                    <td>@forecast.TemperatureC</td>
                    <td>@forecast.TemperatureF</td>
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

The `[StreamRendering]` attribute (in .NET 9+) or `[StreamRendering(true)]` (in .NET 8) enables streaming, which sends initial content quickly while async operations complete.

## Enhanced Navigation

Blazor provides enhanced navigation for Static SSR pages that intercepts link clicks and updates the page content without a full page reload:

```csharp
// Program.cs
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents(); // Required for enhanced navigation
```

Enhanced navigation provides:
- Smooth transitions between pages
- Preserved scroll position
- Faster perceived navigation

## Limitations of Static SSR

Be aware of these limitations when using Static SSR:

- **No event handlers**: `@onclick`, `@onchange`, etc. don't work
- **No JavaScript interop during render**: JS calls only work after page load
- **No circuit**: No persistent state between requests
- **No `OnAfterRender`**: This lifecycle method is never called
- **Forms require POST**: All form submissions trigger server requests

## When to Choose Interactive Rendering

Consider interactive rendering when your application needs:

- Real-time updates without page refresh
- Rich client-side interactivity (drag-and-drop, dynamic filtering)
- Event-driven UI with immediate feedback
- WebSocket-based features

You can mix Static SSR for content pages with interactive rendering for specific features.

## Additional Resources

- [ASP.NET Core Blazor render modes](https://learn.microsoft.com/aspnet/core/blazor/components/render-modes)
- [ASP.NET Core Blazor component rendering](https://learn.microsoft.com/aspnet/core/blazor/components/rendering)
- [ASP.NET Core Blazor forms](https://learn.microsoft.com/aspnet/core/blazor/forms)
