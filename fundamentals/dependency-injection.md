---
title: ASP.NET Core Blazor dependency injection
description: Learn how Blazor Static SSR apps can inject services into components.
layout: page
section: Fundamentals
toc: true
---

# ASP.NET Core Blazor Dependency Injection

This article explains how Blazor Static SSR apps can inject services into components.

[Dependency injection (DI)](https://learn.microsoft.com/aspnet/core/fundamentals/dependency-injection) is a technique for accessing services configured in a central location. Blazor uses ASP.NET Core's built-in DI container.

## Default Services

The services shown in the following table are commonly used in Blazor Static SSR apps.

| Service | Lifetime | Description |
| ------- | -------- | ----------- |
| [System.Net.Http.HttpClient](https://learn.microsoft.com/dotnet/api/system.net.http.httpclient) | Scoped | Provides methods for sending HTTP requests. Register with `AddHttpClient()`. |
| [Microsoft.AspNetCore.Components.NavigationManager](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.navigationmanager) | Scoped | Contains helpers for working with URIs and navigation. |
| [Microsoft.Extensions.Configuration.IConfiguration](https://learn.microsoft.com/dotnet/api/microsoft.extensions.configuration.iconfiguration) | Singleton | Application configuration. |
| [Microsoft.Extensions.Logging.ILogger](https://learn.microsoft.com/dotnet/api/microsoft.extensions.logging.ilogger) | Scoped | Logging service. |

## Register Services

Register services in your `Program.cs` file:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add Razor components
builder.Services.AddRazorComponents();

// Add custom services
builder.Services.AddScoped<ProductService>();
builder.Services.AddSingleton<WeatherService>();
builder.Services.AddTransient<EmailService>();

// Add HttpClient
builder.Services.AddHttpClient();

var app = builder.Build();

app.MapRazorComponents<App>();

app.Run();
```

## Service Lifetimes

Services can be configured with the following lifetimes:

| Lifetime | Description |
| -------- | ----------- |
| **Scoped** | Created once per HTTP request. Best for most services in Static SSR. |
| **Singleton** | Created once for the application lifetime. Use for stateless services, caches, and configuration. |
| **Transient** | Created each time they're requested. Use for lightweight, stateless services. |

In Static SSR, **Scoped** services are created fresh for each HTTP request, making them ideal for:
- Database contexts
- User-specific data services
- Request-specific operations

## Inject Services into Components

Use the `@inject` directive to inject services into components:

```razor
@page "/products"
@inject ProductService ProductService
@inject NavigationManager Navigation

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

### Multiple Services

Inject multiple services with multiple `@inject` directives:

```razor
@page "/dashboard"
@inject UserService UserService
@inject OrderService OrderService
@inject ILogger<Dashboard> Logger

<h1>Dashboard</h1>

<p>Welcome, @user?.Name</p>
<p>You have @orderCount orders</p>

@code {
    private User? user;
    private int orderCount;

    protected override async Task OnInitializedAsync()
    {
        user = await UserService.GetCurrentUserAsync();
        orderCount = await OrderService.GetOrderCountAsync(user?.Id);
        Logger.LogInformation("Dashboard loaded for user {UserId}", user?.Id);
    }
}
```

## Constructor Injection

For code-behind files, use constructor injection:

`MyComponent.razor`:

```razor
@page "/my-page"

<h1>My Component</h1>
<p>@Message</p>
```

`MyComponent.razor.cs`:

```csharp
public partial class MyComponent
{
    private string Message => _service.GetMessage();

    private readonly IMyService _service;

    public MyComponent(IMyService service)
    {
        _service = service;
    }
}
```

## Inject Services into Services

Services can depend on other services via constructor injection:

```csharp
public class OrderService : IOrderService
{
    private readonly IDbContextFactory<AppDbContext> _dbContextFactory;
    private readonly ILogger<OrderService> _logger;
    private readonly IEmailService _emailService;

    public OrderService(
        IDbContextFactory<AppDbContext> dbContextFactory,
        ILogger<OrderService> logger,
        IEmailService emailService)
    {
        _dbContextFactory = dbContextFactory;
        _logger = logger;
        _emailService = emailService;
    }

    public async Task<Order> CreateOrderAsync(OrderRequest request)
    {
        await using var dbContext = await _dbContextFactory.CreateDbContextAsync();
        
        var order = new Order { /* ... */ };
        dbContext.Orders.Add(order);
        await dbContext.SaveChangesAsync();
        
        _logger.LogInformation("Order {OrderId} created", order.Id);
        await _emailService.SendOrderConfirmationAsync(order);
        
        return order;
    }
}
```

## HttpClient Configuration

Register HttpClient for API calls:

```csharp
// Program.cs

// Basic HttpClient
builder.Services.AddHttpClient();

// Named client
builder.Services.AddHttpClient("ProductsApi", client =>
{
    client.BaseAddress = new Uri("https://api.example.com/products/");
});

// Typed client
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    client.BaseAddress = new Uri("https://api.example.com/products/");
});
```

Use in components:

```razor
@page "/products"
@inject HttpClient Http
@inject IHttpClientFactory HttpClientFactory

@code {
    protected override async Task OnInitializedAsync()
    {
        // Using injected HttpClient
        var products1 = await Http.GetFromJsonAsync<Product[]>("https://api.example.com/products");
        
        // Using named client from factory
        var client = HttpClientFactory.CreateClient("ProductsApi");
        var products2 = await client.GetFromJsonAsync<Product[]>("");
    }
}
```

## Access HttpContext

In Static SSR, you can access `HttpContext` via cascading parameter:

```razor
@page "/user-profile"
@inject UserService UserService

<h1>User Profile</h1>

@if (user != null)
{
    <p>Welcome, @user.Name</p>
}

@code {
    [CascadingParameter]
    private HttpContext? HttpContext { get; set; }

    private User? user;

    protected override async Task OnInitializedAsync()
    {
        if (HttpContext != null)
        {
            var userId = HttpContext.User.FindFirst("sub")?.Value;
            user = await UserService.GetUserAsync(userId);
        }
    }
}
```

## Entity Framework Core

Use `IDbContextFactory` for database access in Static SSR:

```csharp
// Program.cs
builder.Services.AddDbContextFactory<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
```

```razor
@page "/products"
@inject IDbContextFactory<AppDbContext> DbContextFactory

<h1>Products</h1>

<ul>
    @foreach (var product in products)
    {
        <li>@product.Name</li>
    }
</ul>

@code {
    private List<Product> products = new();

    protected override async Task OnInitializedAsync()
    {
        await using var dbContext = await DbContextFactory.CreateDbContextAsync();
        products = await dbContext.Products.ToListAsync();
    }
}
```

## Best Practices

1. **Use Scoped lifetime** for most services in Static SSR
2. **Inject services** rather than creating instances directly
3. **Use IDbContextFactory** for Entity Framework Core contexts
4. **Avoid Singleton services** that hold user-specific state
5. **Dispose resources properly** when services implement `IDisposable`

## Additional Resources

- [Dependency injection in ASP.NET Core](https://learn.microsoft.com/aspnet/core/fundamentals/dependency-injection)
- [Dependency injection into views in ASP.NET Core](https://learn.microsoft.com/aspnet/core/mvc/views/dependency-injection)
- [Blazor with Entity Framework Core](https://learn.microsoft.com/aspnet/core/blazor/blazor-ef-core)
