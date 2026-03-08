---
title: Blazor Static SSR Documentation
description: Comprehensive guide to Blazor Static Server-Side Rendering - Build fast, SEO-friendly web applications with Blazor
layout: index
---

# Welcome to Blazor Static SSR Documentation

> Your comprehensive guide to **Blazor Static Server-Side Rendering (Static SSR)**.

## What is Blazor Static SSR?

Blazor Static SSR (Static Server-Side Rendering) is a rendering mode for Blazor applications where components are rendered on the server and delivered as static HTML to the browser with **no interactivity over SignalR**. This approach offers:

- **Fast Initial Load**: HTML is rendered server-side and delivered immediately
- **SEO-Friendly**: Content is available to search engines without JavaScript execution
- **Full .NET Runtime**: Access to complete .NET APIs on the server
- **Low Client Requirements**: Works on any browser without WebAssembly support
- **Simple Deployment**: No circuit management, scales like traditional web apps

## Why Choose Static SSR?

### Advantages

✅ **Fast Time to First Byte (TTFB)** - HTML is rendered on the server  
✅ **Excellent SEO** - Content available immediately to crawlers  
✅ **Full .NET API Access** - Use any .NET library server-side  
✅ **Small Payload** - No WebAssembly runtime or SignalR connection to maintain  
✅ **Thin Client Support** - Works on low-powered devices  
✅ **Code Security** - Application logic stays on the server  
✅ **Simple Scaling** - No circuit state to manage, scales like any ASP.NET Core app  

### Considerations

⚠️ **Server Resources** - Requires server-side processing for each request  
⚠️ **No Real-time Interactivity** - User interactions require form posts or page navigation  
⚠️ **No Offline Support** - Requires active server connection  

## When to Use Static SSR

Static SSR is ideal for:

- **Content-focused websites** - Blogs, documentation, marketing pages
- **SEO-critical applications** - E-commerce product pages, public content
- **Form-based applications** - CRUD operations, data entry, surveys
- **Applications requiring .NET server APIs** - Direct database access, file system operations
- **Simple scaling requirements** - Traditional web app scaling patterns

## Quick Start

### Prerequisites

- [.NET 10.0 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) or later
- Your favorite code editor (Visual Studio, VS Code, etc.)

### Create Your First Blazor Static SSR App

```bash
# Create a new Blazor Web App without interactivity
dotnet new blazor -o MyBlazorApp

# Navigate to the project
cd MyBlazorApp

# Run the application
dotnet run
```

Open your browser to `https://localhost:5001` to see your Blazor Static SSR app!

### Understanding Static SSR

In Static SSR, components are rendered to HTML on the server for each request. User interactions are handled through traditional form posts and navigation:

```razor
@page "/about"

<h1>About Us</h1>
<p>This page is rendered as static HTML.</p>

<p>Current time: @DateTime.Now</p>
```

## Static SSR vs Interactive Rendering

| Feature | Static SSR | Interactive SSR/WebAssembly |
|---------|-----------|---------------------------|
| Rendering | Server per request | Server/client with circuit |
| Interactivity | Form posts, navigation | Real-time events, callbacks |
| Scaling | Traditional web app | Requires circuit management |
| SEO | Excellent | Requires prerendering |
| Initial load | Fast | Depends on mode |
| Use case | Content, forms, CRUD | Real-time, interactive UIs |

## Documentation Sections

### 🚀 [Getting Started](/getting-started/)
Learn the basics of Blazor Static SSR and get up and running quickly.

**Topics:**
- [Project Structure](/getting-started/project-structure)
- [Tooling](/getting-started/tooling)
- [Supported Platforms](/getting-started/supported-platforms)

### 📚 [Fundamentals](/fundamentals/)
Understand core concepts and architecture of Blazor Static SSR.

**Topics:**
- [Render Modes](/fundamentals/render-modes) - Understanding Static SSR
- [Routing](/fundamentals/routing) - Navigation and URL handling
- [Dependency Injection](/fundamentals/dependency-injection) - Service management
- [Configuration](/fundamentals/configuration) - App settings

### 🧩 [Components](/components/)
Deep dive into Razor components and how they work in Static SSR.

**Topics:**
- [Component Basics](/components/index) - Structure and syntax
- [Rendering](/components/rendering) - How components render in Static SSR
- [Lifecycle](/components/lifecycle) - Component events
- [Prerendering](/components/prerender) - Optimization techniques

### 📝 [Forms](/forms/)
Handle user input with forms and validation in Static SSR.

### 🔒 [Security](/security/)
Implement authentication and authorization for your Static SSR apps.

### ⚡ [Advanced](/advanced/)
Performance optimization, deployment, and advanced scenarios.

## Example: Static SSR Page

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
            <h2>@product.Name</h2>
            <p>@product.Description</p>
            <p>Price: $@product.Price</p>
        </li>
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

## Example: Form with Static SSR

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
    
    <button type="submit">Send Message</button>
</EditForm>

@if (messageSent)
{
    <p>Thank you! Your message has been sent.</p>
}

@code {
    private ContactForm contactForm = new();
    private bool messageSent = false;

    private async Task HandleSubmit()
    {
        await EmailService.SendAsync(contactForm);
        messageSent = true;
    }

    public class ContactForm
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = "";

        [Required]
        [EmailAddress]
        public string Email { get; set; } = "";
    }
}
```

## Resources

### Official Documentation
- [ASP.NET Core Blazor](https://learn.microsoft.com/aspnet/core/blazor) - Complete official docs
- [Blazor GitHub Repository](https://github.com/dotnet/aspnetcore) - Source code and issues

### Learning Resources
- [Blazor Workshop](https://github.com/dotnet-presentations/blazor-workshop/) - Hands-on tutorial
- [Blazor University](https://blazor-university.com/) - Community tutorials

### Community
- [Stack Overflow](https://stackoverflow.com/questions/tagged/blazor) - Q&A
- [Reddit r/blazor](https://reddit.com/r/blazor) - Community discussions

## Contributing

This documentation is extracted from the [official ASP.NET Core documentation](https://github.com/dotnet/AspNetCore.Docs). 

To contribute to the source documentation:
1. Visit the [AspNetCore.Docs repository](https://github.com/dotnet/AspNetCore.Docs)
2. Fork the repository
3. Make your changes
4. Submit a pull request

## License

Documentation content is sourced from Microsoft's ASP.NET Core Documentation under the [Creative Commons Attribution 4.0 International Public License](https://creativecommons.org/licenses/by/4.0/).

---

## Get Started Now!

Ready to build your first Blazor Static SSR application?

<div class="call-to-action">

[**🚀 Quick Start Guide**](/getting-started/) | [**📖 Full Documentation**](/fundamentals/)

</div>
