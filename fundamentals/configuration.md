---
title: ASP.NET Core Blazor configuration
description: Learn about Blazor Static SSR app configuration, including app settings and logging.

section: Fundamentals
toc: true
---

# ASP.NET Core Blazor Configuration

This article explains how to configure Blazor Static SSR apps using ASP.NET Core configuration patterns.

## Configuration in Static SSR

In Blazor Static SSR, configuration follows standard ASP.NET Core patterns. Configuration is loaded on the server for each request.

### App Settings Files

Configuration is loaded from:

- `appsettings.json` - Default configuration
- `appsettings.{Environment}.json` - Environment-specific configuration
- Environment variables
- Command-line arguments
- Custom configuration providers

### Example Configuration

`appsettings.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=MyApp;Trusted_Connection=True;"
  },
  "ApiSettings": {
    "BaseUrl": "https://api.example.com",
    "ApiKey": "your-api-key",
    "Timeout": 30
  },
  "Features": {
    "EnableNewDashboard": true,
    "MaxItemsPerPage": 50
  }
}
```

`appsettings.Development.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft.AspNetCore": "Information"
    }
  },
  "ApiSettings": {
    "BaseUrl": "https://dev-api.example.com"
  }
}
```

## Access Configuration in Components

Inject `IConfiguration` into components:

```razor
@page "/settings"
@inject IConfiguration Configuration

<h1>Application Settings</h1>

<p>API Base URL: @apiBaseUrl</p>
<p>Max Items: @maxItems</p>

@code {
    private string? apiBaseUrl;
    private int maxItems;

    protected override void OnInitialized()
    {
        apiBaseUrl = Configuration["ApiSettings:BaseUrl"];
        maxItems = Configuration.GetValue<int>("Features:MaxItemsPerPage");
    }
}
```

## Options Pattern

Use the Options pattern for strongly-typed configuration:

### Define Options Class

```csharp
public class ApiSettings
{
    public string BaseUrl { get; set; } = "";
    public string ApiKey { get; set; } = "";
    public int Timeout { get; set; } = 30;
}

public class FeatureSettings
{
    public bool EnableNewDashboard { get; set; }
    public int MaxItemsPerPage { get; set; } = 20;
}
```

### Register Options

```csharp
// Program.cs
builder.Services.Configure<ApiSettings>(
    builder.Configuration.GetSection("ApiSettings"));

builder.Services.Configure<FeatureSettings>(
    builder.Configuration.GetSection("Features"));
```

### Use Options in Components

```razor
@page "/api-data"
@inject IOptions<ApiSettings> ApiSettings
@inject IOptions<FeatureSettings> FeatureSettings

<h1>API Data</h1>

<p>API URL: @ApiSettings.Value.BaseUrl</p>
<p>Timeout: @ApiSettings.Value.Timeout seconds</p>
<p>Max Items: @FeatureSettings.Value.MaxItemsPerPage</p>

@code {
    // Options are available via the Value property
}
```

### Use Options in Services

```csharp
public class ProductService
{
    private readonly HttpClient _httpClient;
    private readonly ApiSettings _settings;

    public ProductService(
        HttpClient httpClient,
        IOptions<ApiSettings> apiSettings)
    {
        _httpClient = httpClient;
        _settings = apiSettings.Value;
        
        _httpClient.BaseAddress = new Uri(_settings.BaseUrl);
        _httpClient.Timeout = TimeSpan.FromSeconds(_settings.Timeout);
    }

    public async Task<List<Product>> GetProductsAsync()
    {
        var request = new HttpRequestMessage(HttpMethod.Get, "products");
        request.Headers.Add("X-API-Key", _settings.ApiKey);
        
        var response = await _httpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();
        
        return await response.Content.ReadFromJsonAsync<List<Product>>() ?? new();
    }
}
```

## Connection Strings

Access connection strings for database operations:

```csharp
// Program.cs
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContextFactory<AppDbContext>(options =>
    options.UseSqlServer(connectionString));
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

## Environment-Specific Configuration

Access the current environment:

```razor
@page "/"
@inject IWebHostEnvironment Environment

<h1>Environment: @Environment.EnvironmentName</h1>

@if (Environment.IsDevelopment())
{
    <p>Running in development mode</p>
}
else if (Environment.IsProduction())
{
    <p>Running in production mode</p>
}
```

## Logging Configuration

Configure logging in `appsettings.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  }
}
```

Use logging in components:

```razor
@page "/checkout"
@inject ILogger<Checkout> Logger
@inject OrderService OrderService

<h1>Checkout</h1>

@code {
    protected override async Task OnInitializedAsync()
    {
        Logger.LogInformation("Checkout page initialized");
    }

    private async Task ProcessOrder()
    {
        Logger.LogInformation("Processing order for user {UserId}", userId);
        
        try
        {
            await OrderService.ProcessOrderAsync();
            Logger.LogInformation("Order processed successfully");
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Order processing failed");
        }
    }
}
```

## Custom Configuration Providers

Add custom configuration sources:

```csharp
// Program.cs

// Add environment variables
builder.Configuration.AddEnvironmentVariables();

// Add user secrets (development only)
if (builder.Environment.IsDevelopment())
{
    builder.Configuration.AddUserSecrets<Program>();
}

// Add command-line arguments
builder.Configuration.AddCommandLine(args);

// Add in-memory collection
builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
{
    ["CustomSetting"] = "CustomValue"
});
```

## Configuration Best Practices

1. **Use the Options pattern** for strongly-typed settings
2. **Separate concerns** - different options classes for different features
3. **Never store secrets** in appsettings.json - use:
   - User Secrets (development)
   - Azure Key Vault (production)
   - Environment variables
4. **Validate configuration** on startup

### Validate Options

```csharp
using Microsoft.Extensions.Options;

public class ApiSettingsValidation : IValidateOptions<ApiSettings>
{
    public ValidateOptionsResult Validate(string? name, ApiSettings options)
    {
        if (string.IsNullOrEmpty(options.BaseUrl))
        {
            return ValidateOptionsResult.Fail("BaseUrl is required");
        }

        if (!Uri.TryCreate(options.BaseUrl, UriKind.Absolute, out _))
        {
            return ValidateOptionsResult.Fail("BaseUrl must be a valid URL");
        }

        return ValidateOptionsResult.Success;
    }
}

// Program.cs
builder.Services.AddSingleton<IValidateOptions<ApiSettings>, ApiSettingsValidation>();
builder.Services.AddOptions<ApiSettings>()
    .Bind(builder.Configuration.GetSection("ApiSettings"))
    .ValidateOnStart();
```

## Additional Resources

- [Configuration in ASP.NET Core](https://learn.microsoft.com/aspnet/core/fundamentals/configuration/)
- [Options pattern in ASP.NET Core](https://learn.microsoft.com/aspnet/core/fundamentals/configuration/options)
- [Logging in ASP.NET Core](https://learn.microsoft.com/aspnet/core/fundamentals/logging/)
