---
title: Advanced Static SSR scenarios
description: Advanced implementation notes for Blazor Static SSR components.

section: Advanced
toc: true
---

# Advanced Static SSR scenarios

Most Static SSR components should be written as `.razor` files. The compiler generates efficient render-tree code and keeps the markup readable. Use lower-level rendering APIs only when ordinary components can't express the scenario.

## Manual render tree construction

`RenderTreeBuilder` can build component output manually:

```csharp
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Rendering;

public sealed class ProductSummary : ComponentBase
{
    [Parameter]
    public string? Name { get; set; }

    [Parameter]
    public decimal Price { get; set; }

    protected override void BuildRenderTree(RenderTreeBuilder builder)
    {
        builder.OpenElement(0, "article");
        builder.OpenElement(1, "h2");
        builder.AddContent(2, Name);
        builder.CloseElement();
        builder.OpenElement(3, "p");
        builder.AddContent(4, Price.ToString("C"));
        builder.CloseElement();
        builder.CloseElement();
    }
}
```

This works in Static SSR because rendering occurs on the server during the request.

## Sequence numbers

Hardcode sequence numbers. They represent source locations, not runtime execution order:

```csharp
if (showDetails)
{
    builder.AddContent(10, "Details");
}

builder.AddContent(20, "Summary");
```

Do not generate sequence numbers with a counter:

```csharp
var seq = 0;
builder.AddContent(seq++, "Summary");
```

Generated sequence numbers hide useful structure from Blazor's diffing algorithm. Even in Static SSR, components can rerender during a request, and the same component code might later be used interactively.

## Prefer regions for generated blocks

If a helper method emits a repeated or generated block, wrap it in a region so sequence numbers inside the helper have a separate range:

```csharp
builder.OpenRegion(100);
BuildProductRows(builder, products);
builder.CloseRegion();
```

## Dynamic components

Use `DynamicComponent` when choosing a component type at runtime:

```razor
<DynamicComponent Type="selectedComponent"
                  Parameters="parameters" />

@code {
    private Type selectedComponent = typeof(ProductSummary);

    private Dictionary<string, object?> parameters = new()
    {
        ["Name"] = "Trail map",
        ["Price"] = 12.50m
    };
}
```

The selected component still renders statically unless it or an ancestor is assigned an interactive render mode.

## Security warning

Manual render-tree construction can produce invalid markup or unsafe output if used carelessly. Prefer normal Razor syntax and let Razor encode untrusted text. When emitting markup manually, don't pass untrusted HTML through `MarkupString` unless it has been sanitized by a trusted HTML sanitizer.

## Additional resources

- [Components](/components/)
- [Rendering](/components/rendering)
- [Threat mitigation](/security/threat-mitigation)
