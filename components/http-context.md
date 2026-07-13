---
title: HttpContext in Blazor Static SSR
description: Use ASP.NET Core request and response data safely from statically rendered Razor components.
section: Components
toc: true
---

# `HttpContext` in Blazor Static SSR

Static SSR executes while ASP.NET Core is handling an HTTP request. A statically rendered root component can therefore receive the current [`HttpContext`](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.http.httpcontext) as a cascading parameter:

```razor
@using Microsoft.AspNetCore.Http

@code {
    [CascadingParameter]
    private HttpContext? HttpContext { get; set; }
}
```

The value is available during Static SSR, but is `null` during interactive rendering. Treat it as optional if a component can run under more than one render mode.

## Appropriate uses

During Static SSR, `HttpContext` is useful for request/response work such as:

- Reading request headers, cookies, the authenticated user, and endpoint metadata.
- Setting a response header or cookie before the response starts.
- Selecting content from request-specific information.
- Detecting whether a component is currently executing in a request/response context.

Prefer APIs that work across render modes when possible. Use `NavigationManager` for the current URL and redirects, and use `AuthenticationStateProvider` for authentication state in reusable components.

## Response headers and streaming

Headers and cookies become read-only after the response starts. Attempting to modify them later throws an `InvalidOperationException` with a message indicating that the response has already started.

This is especially important with [streaming rendering](/components/rendering#streaming-rendering): the first streamed batch commits the response. Complete cookie authentication, redirects, and other header changes before streaming begins. A call such as `SignInManager.PasswordSignInAsync` can't set its authentication cookie after the response is committed.

```razor
@code {
    protected override void OnInitialized()
    {
        if (HttpContext is { Response.HasStarted: false })
        {
            HttpContext.Response.Headers.Append("X-Page", "products");
        }
    }
}
```

## Reusable component guidance

Don't make a Razor class library depend on `HttpContext` unless the library is explicitly limited to Static SSR. A reusable component can accept it conditionally:

```csharp
[CascadingParameter]
private HttpContext? Context { get; set; }
```

The component must still behave correctly when `Context` is `null`. Never retain an `HttpContext` beyond its request or store it in a singleton service.

## Additional resources

- [Use `IHttpContextAccessor`/`HttpContext` in ASP.NET Core Blazor apps](https://learn.microsoft.com/aspnet/core/blazor/components/httpcontext?view=aspnetcore-10.0)
- [Control headers in ASP.NET Core Blazor](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/startup?view=aspnetcore-10.0#control-headers-in-c-code)

