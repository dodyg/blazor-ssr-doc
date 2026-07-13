---
title: Globalization and localization in Blazor Static SSR
description: Configure cultures, formatting, and localized resources for Blazor Static SSR apps.

section: Advanced
toc: true
---

# Globalization and localization in Blazor Static SSR

Static SSR uses the server's .NET runtime to format values and resolve localized resources while rendering each request.

## Supported localization services

Use the standard .NET localization services:

- `IStringLocalizer`
- `IStringLocalizer<T>`
- `.resx` resource files
- Data annotation localization through `DisplayAttribute.ResourceType` and `ValidationAttribute.ErrorMessageResourceType`

`IHtmlLocalizer` and `IViewLocalizer` are MVC view features and aren't used by Razor components.

## Configure localization

Register localization services and configure request localization before mapping Razor components:

```csharp
using System.Globalization;
using Microsoft.AspNetCore.Localization;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddLocalization();
builder.Services.AddRazorComponents();

var app = builder.Build();

var supportedCultures = new[]
{
    new CultureInfo("en-US"),
    new CultureInfo("es-CR")
};

app.UseRequestLocalization(new RequestLocalizationOptions
{
    DefaultRequestCulture = new RequestCulture("en-US"),
    SupportedCultures = supportedCultures,
    SupportedUICultures = supportedCultures
});

app.MapRazorComponents<App>();

app.Run();
```

Request Localization Middleware must run before middleware or endpoints that read the current culture.

## Use localized resources

Inject a localizer into a component:

```razor
@page "/hello"
@inject IStringLocalizer<Hello> Localizer

<h1>@Localizer["Hello"]</h1>
<p>@Localizer["Today is {0:D}.", DateTime.Today]</p>
```

Resource files are resolved on the server during rendering. No browser-side resource download is needed for Static SSR.

## Culture from the request

Static SSR commonly uses the browser's `Accept-Language` header through Request Localization Middleware. You can also use cookies, route values, or query string providers:

```csharp
var options = new RequestLocalizationOptions
{
    DefaultRequestCulture = new RequestCulture("en-US"),
    SupportedCultures = supportedCultures,
    SupportedUICultures = supportedCultures
};

options.RequestCultureProviders.Insert(0, new CookieRequestCultureProvider());

app.UseRequestLocalization(options);
```

## Culture selector

A culture selector can post to the server and set a localization cookie:

```razor
@page "/culture"
@using Microsoft.AspNetCore.Localization

<EditForm Model="Model" FormName="culture" OnSubmit="SetCulture">
    <AntiforgeryToken />

    <select name="Culture">
        <option value="en-US" selected="@(Model.Culture == "en-US")">English (United States)</option>
        <option value="es-CR" selected="@(Model.Culture == "es-CR")">Spanish (Costa Rica)</option>
    </select>

    <button type="submit">Apply</button>
</EditForm>

@code {
    [CascadingParameter]
    private HttpContext HttpContext { get; set; } = default!;

    [SupplyParameterFromForm]
    private CultureForm Model { get; set; } = new();

    private void SetCulture()
    {
        var culture = Model.Culture ?? "en-US";
        var cookieValue = CookieRequestCultureProvider.MakeCookieValue(
            new RequestCulture(culture));

        HttpContext.Response.Cookies.Append(
            CookieRequestCultureProvider.DefaultCookieName,
            cookieValue,
            new CookieOptions
            {
                Expires = DateTimeOffset.UtcNow.AddYears(1),
                IsEssential = true,
                SameSite = SameSiteMode.Lax
            });
    }

    private sealed class CultureForm
    {
        public string? Culture { get; set; }
    }
}
```

If the response has already started, headers and cookies can't be changed. Set cookies before streaming output begins.

## Formatting and binding

`CultureInfo.CurrentCulture` controls server-side formatting:

```razor
@using System.Globalization

<p>@DateTime.Today.ToString("D")</p>
<p>@12345.67m.ToString("C")</p>
<p>@CultureInfo.CurrentCulture.DisplayName</p>
```

For form fields, Blazor's binding uses the current culture where appropriate. HTML input types such as `date` and `number` still follow browser rules for their wire format.

## HTML language

Set the page language for accessibility and search engines. If the culture is static, set it on the root document:

```html
<html lang="en">
```

If it changes per request, render it from the current culture in the app shell:

```razor
@using System.Globalization

<html lang="@CultureInfo.CurrentUICulture.Name">
```

## Static SSR scope

Do not use WebAssembly globalization properties for Static SSR, such as `BlazorWebAssemblyLoadAllGlobalizationData` or WebAssembly ICU data settings. Those properties apply to .NET running in the browser, not to server-rendered Static SSR components.

## Additional resources

- [ASP.NET Core localization](https://learn.microsoft.com/aspnet/core/fundamentals/localization)
- [.NET globalization](https://learn.microsoft.com/dotnet/core/extensions/globalization)
- [.NET localization](https://learn.microsoft.com/dotnet/core/extensions/localization)
