---
title: Event handling in Blazor Static SSR
description: Understand which user interactions work in Static SSR and how to model them with form posts, links, and JavaScript.

section: Components
toc: true
---

# Event handling in Blazor Static SSR

Static SSR doesn't keep a live .NET renderer in the browser after the response is sent. Razor event handlers such as `@onclick`, `@onchange`, `@oninput`, and `@onsubmit` don't run from browser events unless the component adopts an interactive render mode.

For Static SSR, model user actions as HTTP requests:

- Use links for navigation and state that belongs in the URL.
- Use `EditForm` or HTML forms for commands that change state.
- Use server-side handlers such as `OnSubmit`, `OnValidSubmit`, and `OnInvalidSubmit` for form posts.
- Use JavaScript for browser-only behavior that doesn't need to call .NET after rendering.

## Button clicks

A button in a Static SSR component should normally submit a form or navigate through a link. This `@onclick` example renders a button, but selecting it doesn't call `Increment` in Static SSR:

```razor
<button @onclick="Increment">Count</button>

@code {
    private int count;

    private void Increment() => count++;
}
```

Use a form post instead:

```razor
@page "/counter"

<EditForm Model="Model" FormName="counter" OnSubmit="Increment">
    <input type="hidden" name="Count" value="@Model.Count" />
    <button type="submit">Count</button>
</EditForm>

<p>Current count: @Model.Count</p>

@code {
    [SupplyParameterFromForm]
    private CounterModel? Model { get; set; }

    protected override void OnInitialized()
    {
        Model ??= new();
    }

    private void Increment()
    {
        Model!.Count++;
    }

    private sealed class CounterModel
    {
        public int Count { get; set; }
    }
}
```

The hidden input posts the current request's count back to the server. For durable state, store values in a database, session state, a protected cookie, or another server-side store instead of trusting hidden fields.

## Form events

`EditForm` submit callbacks are the main server-side event pattern for Static SSR:

```razor
@page "/contact"
@using System.ComponentModel.DataAnnotations

<EditForm Model="Model" FormName="contact" OnValidSubmit="Submit">
    <DataAnnotationsValidator />
    <AntiforgeryToken />

    <label>
        Email
        <InputText @bind-Value="Model.Email" />
    </label>
    <ValidationMessage For="() => Model.Email" />

    <button type="submit">Send</button>
</EditForm>

@if (submitted)
{
    <p>Message received.</p>
}

@code {
    [SupplyParameterFromForm]
    private ContactModel Model { get; set; } = new();

    private bool submitted;

    private void Submit()
    {
        submitted = true;
    }

    private sealed class ContactModel
    {
        [Required, EmailAddress]
        public string? Email { get; set; }
    }
}
```

For Static SSR forms:

- Set a unique `FormName`.
- Add `<AntiforgeryToken />` unless the form intentionally posts without antiforgery protection.
- Bind posted values with `[SupplyParameterFromForm]`.
- Validate on the server after the request is submitted.

## Change events

Component change handlers such as `@onchange` don't run as browser events in Static SSR. To react to a selection, use a form submission or encode the selection in the URL:

```razor
@page "/products"

<form method="get">
    <label>
        Category
        <select name="category">
            <option value="">All</option>
            <option value="books" selected="@(Category == "books")">Books</option>
            <option value="tools" selected="@(Category == "tools")">Tools</option>
        </select>
    </label>
    <button type="submit">Apply</button>
</form>

@code {
    [SupplyParameterFromQuery]
    private string? Category { get; set; }
}
```

## Custom browser behavior

Use JavaScript when the behavior is entirely client-side, such as opening a disclosure widget, focusing an element, or integrating a third-party browser library. For page-specific scripts, use JavaScript initializers and handle enhanced navigation events so behavior is initialized again after Blazor patches new HTML into the document.

See [JavaScript with Static SSR](/advanced/javascript) for the recommended pattern.

## When to use an interactive render mode

Use an interactive render mode for UI that must handle .NET events without full page requests, such as drag-and-drop editors, live charts, real-time controls, or components that need .NET-to-JavaScript interop after rendering.

Keep the rest of the app Static SSR when possible, and isolate interactivity to the components that need it.
