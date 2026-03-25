---
title: When to Use Blazor Static SSR
description: Learn when to choose Blazor Static SSR for your web applications.
layout: page
section: Getting Started
toc: true
---

# When to Use Blazor Static SSR

This article helps you decide when Blazor Static Server-Side Rendering (Static SSR) is the right choice for your web application.

## Understanding Static SSR

Blazor Static SSR renders Razor components on the server to produce static HTML that's sent to the browser. Unlike interactive Blazor modes, Static SSR doesn't maintain a persistent connection (circuit) between the client and server.

## Static SSR Advantages

| Advantage | Description |
|-----------|-------------|
| **Fast Initial Load** | HTML is rendered on the server and delivered immediately |
| **Excellent SEO** | All content is available to search engines without JavaScript |
| **Simple Scaling** | Scales like traditional ASP.NET Core web apps |
| **Full .NET API Access** | Use any .NET library, including server-specific APIs |
| **Low Client Requirements** | Works on any browser without WebAssembly or WebSocket support |
| **Code Security** | Application logic stays on the server |
| **Small Payload** | No client-side runtime or SignalR connection needed |

## Static SSR Limitations

| Limitation | Impact |
|------------|--------|
| **No Real-time Interactivity** | User interactions require form posts or navigation |
| **No Event Handlers** | `@onclick`, `@onchange` etc. don't work |
| **No Circuit State** | No persistent state between requests |
| **Server Resources** | Each request requires server processing |

## Ideal Use Cases for Static SSR

### 1. Content-Driven Websites

Perfect for sites where content is the primary focus:

- **Blogs and articles**
- **Documentation sites**
- **Marketing websites**
- **News sites**
- **Product catalogs**

```razor
@page "/blog/{slug}"
@inject BlogService BlogService

@code {
    [Parameter]
    public string? Slug { get; set; }
    
    private BlogPost? post;
    
    protected override async Task OnInitializedAsync()
    {
        post = await BlogService.GetPostAsync(Slug!);
    }
}

@if (post != null)
{
    <article>
        <h1>@post.Title</h1>
        <time>@post.PublishedDate.ToString("MMMM dd, yyyy")</time>
        @((MarkupString)post.Content)
    </article>
}
```

### 2. SEO-Critical Applications

When search engine visibility is crucial:

- **E-commerce product pages**
- **Public-facing business pages**
- **Landing pages**
- **Informational pages**

### 3. Form-Based Applications

Traditional web application patterns:

- **Contact forms**
- **Surveys and questionnaires**
- **Data entry applications**
- **CRUD operations**

```razor
@page "/register"
@inject UserService UserService

<h1>Register</h1>

<EditForm Model="@model" OnValidSubmit="@HandleRegister" FormName="RegisterForm">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    
    <div>
        <label>Username:</label>
        <InputText @bind-Value="model.Username" />
        <ValidationMessage For="@(() => model.Username)" />
    </div>
    
    <div>
        <label>Email:</label>
        <InputText @bind-Value="model.Email" />
        <ValidationMessage For="@(() => model.Email)" />
    </div>
    
    <button type="submit">Register</button>
</EditForm>

@code {
    private RegisterModel model = new();
    
    private async Task HandleRegister()
    {
        await UserService.RegisterAsync(model);
    }
    
    public class RegisterModel
    {
        [Required]
        public string Username { get; set; } = "";
        
        [Required]
        [EmailAddress]
        public string Email { get; set; } = "";
    }
}
```

### 4. Applications Requiring Server APIs

When you need direct access to server resources:

- **Database operations**
- **File system access**
- **Server-side caching**
- **Background services**

### 5. Simple Scaling Requirements

When traditional web app scaling patterns are sufficient:

- **Stateless request handling**
- **Load balancer friendly**
- **No sticky sessions required**

## When NOT to Use Static SSR

Consider alternatives when your application requires:

### Real-time Features
- Live dashboards
- Chat applications
- Collaborative editing
- Real-time notifications

### Rich Client Interactivity
- Drag-and-drop interfaces
- Dynamic filtering without page reload
- Instant validation feedback
- Interactive data visualization

### Offline Support
- Progressive Web Apps (PWA)
- Offline-first applications

## Comparison with Other Approaches

### Static SSR vs Traditional ASP.NET Core MVC/Razor Pages

| Feature | Static SSR | MVC/Razor Pages |
|---------|-----------|-----------------|
| Component model | ✅ Razor components | ❌ Views/Pages |
| Reusable components | ✅ Easy composition | ⚠️ Partial views |
| C# in markup | ✅ Natural syntax | ⚠️ Razor syntax |
| Form handling | ✅ EditForm | ⚠️ Tag helpers |
| Familiar patterns | ✅ Similar concepts | ✅ Well established |

### Static SSR vs Static Site Generators

| Feature | Static SSR | Static Site Generators |
|---------|-----------|------------------------|
| Dynamic content | ✅ Per-request | ❌ Build time only |
| Personalization | ✅ Full support | ❌ Limited |
| Database access | ✅ Direct | ❌ Requires API |
| Deployment | ⚠️ Server required | ✅ Static hosting |
| Build time | ✅ No build step | ⚠️ Can be slow |

## Decision Matrix

Use this matrix to help decide if Static SSR is right for your project:

| Requirement | Recommendation |
|-------------|----------------|
| SEO is critical | ✅ Static SSR |
| Content-focused site | ✅ Static SSR |
| Form-based data entry | ✅ Static SSR |
| Need server API access | ✅ Static SSR |
| Real-time updates needed | ❌ Consider Interactive SSR |
| Offline support needed | ❌ Consider PWA |
| Rich client interactions | ❌ Consider Interactive modes |
| Simple deployment only | ⚠️ Consider alternatives |

## Mixing Rendering Modes

You can use Static SSR alongside interactive rendering in the same application:

- **Static SSR** for public, SEO-critical pages
- **Interactive rendering** for admin dashboards, complex forms

This hybrid approach gives you the best of both worlds.

## Getting Started

To create a Blazor Web App focused on Static SSR:

```bash
# Create a new Blazor Web App (Static SSR by default)
dotnet new blazor -o MyStaticApp

cd MyStaticApp
dotnet run
```

By default, the template creates an app that uses Static SSR without interactive rendering.

## Additional Resources

- [ASP.NET Core Blazor fundamentals](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/)
- [ASP.NET Core Blazor render modes](https://learn.microsoft.com/aspnet/core/blazor/components/render-modes)
- [Blazor Static SSR samples](https://github.com/dotnet/blazor-samples)
