---
title: Static SSR Threat Mitigation
description: Security guidance for request-response Blazor applications that use Static SSR.
section: Security
toc: true
---

# Static SSR Threat Mitigation

Static SSR uses the traditional HTTP request/response model. Apply normal ASP.NET Core security controls to every request and treat all client input as untrusted, including route values, query strings, form fields, headers, and cookies that aren't protected by the server.

## Authenticate and authorize on the server

During Static SSR, endpoint routing and authorization run in the ASP.NET Core middleware pipeline. An `[Authorize]` attribute on a routable page protects its endpoint, but `<NotAuthorized>` content from `AuthorizeRouteView` isn't displayed for a rejected Static SSR request. Configure cookie login paths or an authorization middleware result handler to produce redirects and access-denied responses.

Don't rely on conditionally hiding UI with `AuthorizeView` to protect data or operations. Recheck authorization when performing the server-side action.

## Validate, constrain, and encode input

- Use typed route constraints and validate route and query values before use.
- Check model binding and validation results before processing a form.
- Use parameterized database access; never concatenate input into SQL.
- Validate redirect destinations with `LocalRedirect` or an equivalent local-URL check.
- Let Razor encode output. Only render `MarkupString` from trusted or correctly sanitized HTML.

`EditForm.OnValidSubmit` isn't invoked when form mapping or validation errors are present, but business rules and authorization still belong in the submit handler.

## Protect form posts from CSRF

`AddRazorComponents` registers antiforgery services. Place `UseAntiforgery` after authentication and authorization middleware and before mapped endpoints when configuring the pipeline manually:

```csharp
app.UseAuthentication();
app.UseAuthorization();
app.UseAntiforgery();

app.MapRazorComponents<App>();
```

`EditForm` automatically includes antiforgery protection. An HTML `<form>` should include `<AntiforgeryToken />`. A failed check returns `400 Bad Request` and the form handler doesn't run. Disabling antiforgery with `[RequireAntiforgeryToken(required: false)]` is unsafe for public forms that change server state.

## Prevent overposting

Static SSR form mapping binds request values to `[SupplyParameterFromForm]` properties. Use separate input models that contain only fields the caller is allowed to change. Don't bind persistence entities with administrative or ownership properties and then save them directly.

```csharp
public sealed class UpdateProfileInput
{
    [Required, StringLength(100)]
    public string DisplayName { get; set; } = "";
}
```

Load the protected entity on the server, authorize access to it, and copy only approved values from the input model.

## Isolate per-request state

Static SSR scoped and transient services usually live for one HTTP request. A singleton is shared by all users and must never hold user-specific form, authentication, or request state. Don't retain `HttpContext` after the request completes.

If the same service may also run in Interactive Server mode, scoped state can outlive a single request for the life of a circuit. Design the service safely for both lifetimes.

## Bound server work

Form mapping has configurable limits for collection size, recursion depth, error count, and key size. Keep conservative limits and add app-specific bounds for uploads, searches, pagination, and operations whose cost grows with user-controlled values.

Also apply request body, header, rate, timeout, memory, network, and storage limits appropriate to the endpoint. A small request must not be able to trigger unbounded work.

## Errors, streaming, and secrets

Log security-relevant failures without returning sensitive details. Errors after a streaming response has begun are rendered as a generic error in production because the status and headers may already be committed.

Static SSR code remains on the server, but secrets can still leak through rendered HTML, logs, exception pages, response headers, or serialized component state. Use ASP.NET Core Data Protection for app-specific protected payloads and never render credentials or tokens into the page.

## Review checklist

- Require authentication and authorization at the endpoint and action.
- Validate and sanitize every client-controlled value.
- Keep antiforgery enabled for state-changing form posts.
- Use narrow form input models to prevent overposting.
- Keep user state out of singletons and dispose request resources.
- Bound request sizes and server work.
- Return generic production errors and audit important failures.
- Protect sensitive payloads and keep secrets out of HTML.

## Additional resources

- [Threat mitigation for Blazor Static SSR](https://learn.microsoft.com/aspnet/core/blazor/security/static-server-side-rendering?view=aspnetcore-10.0)
- [Blazor security overview](https://learn.microsoft.com/aspnet/core/blazor/security/?view=aspnetcore-10.0)
- [Blazor antiforgery support](https://learn.microsoft.com/aspnet/core/blazor/forms/?view=aspnetcore-10.0#antiforgery-support)

