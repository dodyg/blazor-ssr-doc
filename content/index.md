---
title: Blazor SSR Documentation
description: Comprehensive guide to Blazor Server-Side Rendering (Static Rendering) - Build fast, SEO-friendly web applications with Blazor
layout: index
---

# Welcome to Blazor SSR Documentation

> Your comprehensive guide to **Blazor Server-Side Rendering (SSR)**, also known as static rendering.

## What is Blazor SSR?

Blazor SSR (Server-Side Rendering) is a hosting model for Blazor applications where components are rendered on the server and delivered as static HTML to the browser. This approach offers:

- **Fast Initial Load**: HTML is rendered server-side and delivered immediately
- **SEO-Friendly**: Content is available to search engines without JavaScript execution
- **Full .NET Runtime**: Access to complete .NET APIs on the server
- **Low Client Requirements**: Works on any browser without WebAssembly support

## Two Types of SSR

### 1. Static SSR (Non-Interactive)

Components are rendered to static HTML with **no interactivity**. Perfect for:

- Content-focused websites
- Blogs and documentation sites
- Marketing pages
- SEO-critical pages

```razor
@page "/about"
@attribute [RenderMode.Static]

<h1>About Us</h1>
<p>This page is rendered as static HTML.</p>
```

### 2. Interactive SSR (Server-Side)

Components are rendered with **full interactivity** via SignalR. Ideal for:

- Interactive web applications
- Real-time updates
- Complex forms and workflows
- Dashboards

```razor
@page "/counter"
@attribute [RenderMode.InteractiveServer]
@rendermode InteractiveServer

<h1>Counter</h1>
<p>Current count: @currentCount</p>
<button @onclick="IncrementCount">Click me</button>

@code {
    private int currentCount = 0;
    
    private void IncrementCount()
    {
        currentCount++;
    }
}
```

## Why Choose Blazor SSR?

### Advantages

✅ **Fast Time to First Byte (TTFB)** - HTML is rendered on the server  
✅ **Excellent SEO** - Content available immediately to crawlers  
✅ **Full .NET API Access** - Use any .NET library server-side  
✅ **Small Payload** - No WebAssembly runtime to download  
✅ **Thin Client Support** - Works on low-powered devices  
✅ **Code Security** - Application logic stays on the server  

### Considerations

⚠️ **Server Resources** - Requires server-side processing  
⚠️ **Network Latency** - User interactions require server round-trip  
⚠️ **No Offline Support** - Requires active server connection  

## Quick Start

### Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) or later
- Your favorite code editor (Visual Studio, VS Code, etc.)

### Create Your First Blazor SSR App

```bash
# Create a new Blazor Web App (includes SSR support)
dotnet new blazor -o MyBlazorApp --interactivity Server

# Navigate to the project
cd MyBlazorApp

# Run the application
dotnet run
```

Open your browser to `https://localhost:5001` to see your Blazor SSR app in action!

### Understanding Render Modes

In your `_Imports.razor` file, you can set default render modes:

```razor
@using static Microsoft.AspNetCore.Components.Web.RenderMode

// For static SSR (no interactivity)
@attribute [rendermode: Static]

// For interactive SSR
@attribute [rendermode: InteractiveServer]

// Per-page override
@page "/mypage"
@rendermode InteractiveServer
```

## Documentation Sections

### 🚀 [Getting Started](/getting-started/)
Learn the basics of Blazor SSR and get up and running quickly.

**Topics:**
- [What is Blazor SSR?](/getting-started/what-is-ssr)
- [Quick Start Guide](/getting-started/quick-start)
- [SSR vs WebAssembly vs Hybrid](/getting-started/comparison)

### 📚 [Fundamentals](/fundamentals/)
Understand core concepts and architecture of Blazor SSR.

**Topics:**
- [Render Modes](/fundamentals/render-modes) - Static vs Interactive
- [Routing](/fundamentals/routing) - Navigation and URL handling
- [Dependency Injection](/fundamentals/dependency-injection) - Service management
- [Configuration](/fundamentals/configuration) - App settings

### 🧩 [Components](/components/)
Deep dive into Razor components and how they work in SSR.

**Topics:**
- [Component Basics](/components/index) - Structure and syntax
- [Render Modes](/components/render-modes) - Component-level control
- [Lifecycle](/components/lifecycle) - Component events
- [Prerendering](/components/prerender) - Optimization techniques

### 📝 [Forms](/forms/)
Handle user input with forms and validation in SSR.

### 🔒 [Security](/security/)
Implement authentication and authorization for your SSR apps.

### ⚡ [Advanced](/advanced/)
Performance optimization, deployment, and advanced scenarios.

## Example: Static SSR Page

```razor
@page "/products"
@attribute [RenderMode.Static]

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
        // Runs on the server during rendering
        products = await ProductService.GetProductsAsync();
    }
}
```

## Example: Interactive SSR Component

```razor
@page "/todos"
@rendermode InteractiveServer
@inject TodoService TodoService

<h1>Todo List (@todos.Count(t => !t.IsComplete))</h1>

<ul>
    @foreach (var todo in todos)
    {
        <li>
            <input type="checkbox" @bind="todo.IsComplete" />
            <span>@todo.Title</span>
            <button @onclick="() => DeleteTodo(todo)">Delete</button>
        </li>
    }
</ul>

<input @bind="newTodoTitle" placeholder="Add todo..." />
<button @onclick="AddTodo">Add</button>

@code {
    private List<Todo> todos = new();
    private string newTodoTitle = "";
    
    protected override async Task OnInitializedAsync()
    {
        todos = await TodoService.GetTodosAsync();
    }
    
    private async Task AddTodo()
    {
        if (!string.IsNullOrWhiteSpace(newTodoTitle))
        {
            var todo = await TodoService.AddTodoAsync(newTodoTitle);
            todos.Add(todo);
            newTodoTitle = "";
        }
    }
    
    private async Task DeleteTodo(Todo todo)
    {
        await TodoService.DeleteTodoAsync(todo.Id);
        todos.Remove(todo);
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
- [Blazor Gitter](https://gitter.im/aspnet/Blazor) - Chat with the community
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

Ready to build your first Blazor SSR application?

<div class="call-to-action">

[**🚀 Quick Start Guide**](/getting-started/quick-start) | [**📖 Full Documentation**](/getting-started/)

</div>
