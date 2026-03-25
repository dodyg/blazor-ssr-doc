---
title: ASP.NET Core Blazor Data Binding
description: Learn about data binding features in Blazor Static SSR applications.
layout: page
section: Components
toc: true
---

# ASP.NET Core Blazor Data Binding

This article explains data binding features for Blazor Static SSR applications.

## Understanding Binding in Static SSR

In Static SSR, data binding works differently than in interactive Blazor:

- **One-way binding**: Display data from C# code to HTML
- **Form binding**: Use forms to capture user input via POST requests
- **No event handlers**: `@onclick`, `@onchange`, etc. don't work in Static SSR

## One-Way Data Binding

Display C# values in your markup using `@` syntax:

```razor
@page "/profile"

<h1>@Title</h1>
<p>Welcome, @userName!</p>
<p>Today is @DateTime.Now.ToString("D")</p>

@code {
    private string Title = "User Profile";
    private string userName = "John Doe";
}
```

### Binding to Properties

Bind to component properties and fields:

```razor
@page "/product"
@inject ProductService ProductService

<h1>@product?.Name</h1>
<p>Price: $@product?.Price</p>
<p>Description: @product?.Description</p>

@code {
    private Product? product;

    protected override async Task OnInitializedAsync()
    {
        product = await ProductService.GetProductAsync(1);
    }
}
```

### Collections

Render collections with `@foreach`:

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
                <strong>@product.Name</strong> - $@product.Price
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

### Conditional Rendering

Use `@if`, `@else`, and `@switch`:

```razor
@page "/status"

<h1>Order Status</h1>

@if (order == null)
{
    <p>Order not found</p>
}
else
{
    @switch (order.Status)
    {
        case OrderStatus.Pending:
            <p class="text-warning">Your order is pending</p>
            break;
        case OrderStatus.Processing:
            <p class="text-info">Your order is being processed</p>
            break;
        case OrderStatus.Shipped:
            <p class="text-success">Your order has been shipped</p>
            break;
        default:
            <p>Unknown status</p>
            break;
    }
}

@code {
    private Order? order = new() { Status = OrderStatus.Processing };
}
```

## Form Binding

In Static SSR, forms are the primary way to capture user input.

### EditForm with Model

```razor
@page "/contact"
@inject EmailService EmailService

<h1>Contact Us</h1>

<EditForm Model="@contactForm" OnValidSubmit="@HandleSubmit" FormName="ContactForm">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    
    <div>
        <label for="name">Name:</label>
        <InputText id="name" @bind-Value="contactForm.Name" />
        <ValidationMessage For="@(() => contactForm.Name)" />
    </div>
    
    <div>
        <label for="email">Email:</label>
        <InputText id="email" @bind-Value="contactForm.Email" />
        <ValidationMessage For="@(() => contactForm.Email)" />
    </div>
    
    <div>
        <label for="message">Message:</label>
        <InputTextArea id="message" @bind-Value="contactForm.Message" />
        <ValidationMessage For="@(() => contactForm.Message)" />
    </div>
    
    <button type="submit">Send Message</button>
</EditForm>

@if (submitted)
{
    <p class="text-success">Thank you! Your message has been sent.</p>
}

@code {
    private ContactForm contactForm = new();
    private bool submitted;

    [SupplyParameterFromForm]
    private ContactForm? FormData { get; set; }

    protected override void OnInitialized()
    {
        if (FormData != null)
        {
            contactForm = FormData;
            submitted = true;
        }
    }

    private async Task HandleSubmit()
    {
        await EmailService.SendAsync(contactForm);
        submitted = true;
    }

    public class ContactForm
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = "";

        [Required]
        [EmailAddress]
        public string Email { get; set; } = "";

        [Required]
        public string Message { get; set; } = "";
    }
}
```

### Input Components

Blazor provides input components for form binding:

| Component | HTML Element | Usage |
|-----------|-------------|-------|
| `InputText` | `<input type="text">` | Text input |
| `InputNumber<T>` | `<input type="number">` | Numeric input |
| `InputDate<T>` | `<input type="date">` | Date input |
| `InputTextArea` | `<textarea>` | Multi-line text |
| `InputSelect<T>` | `<select>` | Dropdown |
| `InputCheckbox` | `<input type="checkbox">` | Boolean |
| `InputFile` | `<input type="file">` | File upload |

### Select Binding

```razor
@page "/order"
@inject OrderService OrderService

<h1>Create Order</h1>

<EditForm Model="@order" OnValidSubmit="@HandleSubmit" FormName="OrderForm">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    
    <div>
        <label for="product">Product:</label>
        <InputSelect id="product" @bind-Value="order.ProductId">
            <option value="">Select a product</option>
            @foreach (var product in products)
            {
                <option value="@product.Id">@product.Name ($@product.Price)</option>
            }
        </InputSelect>
        <ValidationMessage For="@(() => order.ProductId)" />
    </div>
    
    <div>
        <label for="quantity">Quantity:</label>
        <InputNumber id="quantity" @bind-Value="order.Quantity" />
    </div>
    
    <button type="submit">Place Order</button>
</EditForm>

@code {
    private OrderModel order = new();
    private List<Product> products = new();

    [SupplyParameterFromForm]
    private OrderModel? FormData { get; set; }

    protected override async Task OnInitializedAsync()
    {
        products = await OrderService.GetProductsAsync();
        
        if (FormData != null)
        {
            order = FormData;
        }
    }

    private async Task HandleSubmit()
    {
        await OrderService.CreateOrderAsync(order);
    }

    public class OrderModel
    {
        [Required]
        public int ProductId { get; set; }

        [Range(1, 100)]
        public int Quantity { get; set; } = 1;
    }
}
```

### Checkbox Binding

```razor
@page "/preferences"

<h1>Preferences</h1>

<EditForm Model="@preferences" OnValidSubmit="@HandleSubmit" FormName="PreferencesForm">
    <AntiforgeryToken />
    
    <div>
        <InputCheckbox @bind-Value="preferences.ReceiveNewsletter" />
        <label>Receive newsletter</label>
    </div>
    
    <div>
        <InputCheckbox @bind-Value="preferences.DarkMode" />
        <label>Enable dark mode</label>
    </div>
    
    <button type="submit">Save Preferences</button>
</EditForm>

@code {
    private UserPreferences preferences = new();

    [SupplyParameterFromForm]
    private UserPreferences? FormData { get; set; }

    protected override void OnInitialized()
    {
        if (FormData != null)
        {
            preferences = FormData;
        }
    }

    private void HandleSubmit()
    {
        // Save preferences
    }

    public class UserPreferences
    {
        public bool ReceiveNewsletter { get; set; }
        public bool DarkMode { get; set; }
    }
}
```

## Cascading Values

Pass data through the component hierarchy using cascading values:

### Define Cascading Value

```razor
@page "/dashboard"
@inject UserService UserService

<CascadingValue Value="currentUser">
    <DashboardLayout>
        <UserStats />
        <RecentActivity />
    </DashboardLayout>
</CascadingValue>

@code {
    private User? currentUser;

    protected override async Task OnInitializedAsync()
    {
        currentUser = await UserService.GetCurrentUserAsync();
    }
}
```

### Receive Cascading Parameter

```razor
@* UserStats.razor *@

<h2>User Statistics</h2>

<p>Welcome, @User?.Name!</p>
<p>Member since: @User?.JoinDate.ToString("d")</p>

@code {
    [CascadingParameter]
    public User? User { get; set; }
}
```

## Component Parameters

Pass data to child components via parameters:

```razor
@page "/product-details"
@inject ProductService ProductService

<h1>Product Details</h1>

@if (product != null)
{
    <ProductCard Product="product" ShowDetails="true" />
}

@code {
    private Product? product;

    protected override async Task OnInitializedAsync()
    {
        product = await ProductService.GetProductAsync(1);
    }
}
```

`ProductCard.razor`:

```razor
<div class="product-card">
    <h3>@Product?.Name</h3>
    <p>@Product?.Description</p>
    <span class="price">$@Product?.Price</span>
    
    @if (ShowDetails)
    {
        <a href="/products/@Product?.Id">View Details</a>
    }
</div>

@code {
    [Parameter]
    public Product? Product { get; set; }

    [Parameter]
    public bool ShowDetails { get; set; }
}
```

## Binding in Static SSR vs Interactive Blazor

| Feature | Static SSR | Interactive Blazor |
|---------|-----------|-------------------|
| One-way binding (`@value`) | ✅ Yes | ✅ Yes |
| Form binding | ✅ Via POST | ✅ Any method |
| Event handlers (`@onclick`) | ❌ No | ✅ Yes |
| Two-way binding (`@bind`) | ✅ Forms only | ✅ Everywhere |
| `StateHasChanged` | ❌ Not useful | ✅ Yes |

## Best Practices

1. **Use forms for input** - In Static SSR, forms are the way to capture user data
2. **Include antiforgery tokens** - Always use `<AntiforgeryToken />` in forms
3. **Validate on server** - All validation happens on form submission
4. **Handle loading states** - Show placeholders while data loads
5. **Use `[SupplyParameterFromForm]`** - To receive form data on POST

## Additional Resources

- [ASP.NET Core Blazor forms](https://learn.microsoft.com/aspnet/core/blazor/forms)
- [ASP.NET Core Blazor components](https://learn.microsoft.com/aspnet/core/blazor/components)
- [Cascading values and parameters](https://learn.microsoft.com/aspnet/core/blazor/components/cascading-values-and-parameters)
