---
title: Razor Class Libraries with Static SSR
description: Design reusable Razor components that support Static SSR and progressive enhancement.
section: Components
toc: true
---

# Razor Class Libraries with Static SSR

Razor class library (RCL) components can support Static SSR without holding a circuit or downloading a .NET runtime to the browser. After the server sends the response, the component instance and renderer state are discarded and only HTML remains.

Read-only components naturally work in Static SSR. Event handlers such as `@onclick` don't run because no .NET runtime is active in the browser. Form submission is the important exception: `EditForm` and HTML forms can post to the server and invoke submit handlers.

## Choose a compatibility strategy

Component authors generally choose one of these approaches:

1. **Render read-only content.** The component produces HTML and works under every render mode.
2. **Require interactivity.** Rich editors, collaborative UI, and other event-driven components document that an interactive render mode is required.
3. **Use progressive enhancement.** Provide a useful HTML baseline for Static SSR and add richer behavior when interactivity or JavaScript is available.

Examples of progressive enhancement include a grid that pages with links under Static SSR, tabs whose state is stored in the URL, and a file input that works natively before adding upload progress interactively.

## Leave render mode selection to the app

Reusable components normally shouldn't declare `@rendermode`. The consuming app knows which interactive modes are configured and may intentionally use the component statically. Only couple a library component to a specific render mode when its implementation fundamentally can't run elsewhere.

To select an appropriate fallback at runtime, inspect `RendererInfo` and `AssignedRenderMode`:

```razor
@if (AssignedRenderMode is null)
{
    <form action="/products">
        <input name="filter" />
        <button type="submit">Search</button>
    </form>
}
else
{
    <input @bind="filter" />
    <button @onclick="Search">Search</button>
}
```

An unassigned render mode (`AssignedRenderMode is null`) means the component inherits its parent's mode. When there is no interactive ancestor, it adopts Static SSR.

## Forms across render modes

An `EditForm` can use the same component API in static and interactive modes:

```razor
<EditForm Enhance FormName="NewProduct" Model="Model"
          OnValidSubmit="Save">
    <DataAnnotationsValidator />
    <ValidationSummary />

    <label>Name: <InputText @bind-Value="Model!.Name" /></label>
    <button type="submit">Save</button>
</EditForm>

@code {
    [SupplyParameterFromForm]
    private Product? Model { get; set; }

    protected override void OnInitialized() => Model ??= new();

    private Task Save() => ProductStore.SaveAsync(Model!);
}
```

`Enhance`, `FormName`, and `[SupplyParameterFromForm]` enable Static SSR form handling and don't interfere with interactive rendering. Form names must be unique within their form-mapping scope.

## Streaming and links

Library components can apply `[StreamRendering]` to stream long-running async results during Static SSR. Children inherit streaming from a parent unless they explicitly disable it.

Use ordinary `<a>` elements for navigation. They continue to work with full page loads, enhanced navigation, and an interactive router, so the library doesn't have to assume a particular hosting configuration.

## Static SSR-friendly grids

For tabular data, keep paging and sorting state in query parameters and render links for state changes. In .NET 10, `QuickGrid` supports URL-based navigation so pagination and sorting can work without interactivity while preserving shareable URLs and browser history.

## Additional resources

- [Razor class libraries with Static SSR](https://learn.microsoft.com/aspnet/core/blazor/components/class-libraries-and-static-server-side-rendering?view=aspnetcore-10.0)
- [`QuickGrid` component](https://learn.microsoft.com/aspnet/core/blazor/components/quickgrid?view=aspnetcore-10.0)

