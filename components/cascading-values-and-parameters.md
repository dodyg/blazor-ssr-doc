---
title: Cascading values and parameters in Blazor Static SSR
description: Flow values from ancestor components to descendants during Static SSR rendering.

section: Components
toc: true
---

# Cascading values and parameters in Blazor Static SSR

Cascading values flow data from an ancestor component to descendants without passing the same parameter through every component.

In Static SSR, cascading values are available while the server renders the request. After the response is sent, component instances and their cascaded state are discarded.

## CascadingValue component

Wrap descendant content in `CascadingValue`:

```razor
<CascadingValue Value="Theme">
    @Body
</CascadingValue>

@code {
    private ThemeInfo Theme { get; } = new()
    {
        ButtonClass = "btn-primary"
    };

    private sealed class ThemeInfo
    {
        public string ButtonClass { get; set; } = "";
    }
}
```

Read the value in a descendant with `[CascadingParameter]`:

```razor
<button class="@Theme?.ButtonClass">Save</button>

@code {
    [CascadingParameter]
    private ThemeInfo? Theme { get; set; }
}
```

## Named cascading values

Use names when more than one cascaded value has the same type:

```razor
<CascadingValue Name="PrimaryColor" Value="primary">
    <CascadingValue Name="DangerColor" Value="danger">
        @ChildContent
    </CascadingValue>
</CascadingValue>
```

```razor
@code {
    [CascadingParameter(Name = "PrimaryColor")]
    private string? PrimaryColor { get; set; }

    [CascadingParameter(Name = "DangerColor")]
    private string? DangerColor { get; set; }
}
```

## Root-level cascading values

Register root-level values for the whole component hierarchy:

```csharp
builder.Services.AddCascadingValue(_ => new TenantInfo
{
    Name = "Contoso"
});
```

Consume them in any component:

```razor
<p>@Tenant?.Name</p>

@code {
    [CascadingParameter]
    private TenantInfo? Tenant { get; set; }
}
```

Root-level values are useful for app-wide data such as tenant metadata, theme options, or request-independent feature flags.

## Static SSR limitations

Static SSR doesn't keep subscribers alive after the request. Notification patterns such as `CascadingValueSource<T>.NotifyChangedAsync` only matter for interactive components that can rerender after the initial response.

For Static SSR:

- Treat cascaded values as request-rendering inputs.
- Store durable state outside component instances.
- Don't expect changes in a singleton cascaded object to update already-rendered HTML.
- Avoid cascading `HttpContext` from long-lived state. Use the framework-provided cascading `HttpContext` only during the current request.

## Performance

Set `IsFixed` when a value won't change while descendants render:

```razor
<CascadingValue Value="Theme" IsFixed="true">
    @Body
</CascadingValue>
```

Fixed values avoid change-subscription overhead. In Static SSR this is usually the correct choice for theme, tenant, and configuration objects.

## Cascading values and forms

Cascading values can provide ambient form configuration, such as a form mapping scope:

```razor
<FormMappingScope Name="Billing">
    <AddressForm />
</FormMappingScope>
```

Use this when reusable components might render forms with names that collide with forms elsewhere on the page.

## Additional resources

- [Forms binding](/forms/binding)
- [HttpContext in Static SSR](/components/http-context)
- [Dependency injection](/fundamentals/dependency-injection)
