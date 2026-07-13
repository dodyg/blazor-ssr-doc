---
title: Forms validation in Blazor Static SSR
description: Validate Static SSR forms on the server with data annotations and custom validation.

section: Forms
toc: true
---

# Forms validation in Blazor Static SSR

Static SSR forms are validated on the server after the form is submitted. Client-side validation that depends on a live Blazor circuit isn't available unless the component adopts an interactive render mode.

## Data annotations

Use `DataAnnotationsValidator`, validation message components, and validation attributes on the posted model:

```razor
@page "/register"
@using System.ComponentModel.DataAnnotations

<EditForm Model="Model" FormName="register" OnValidSubmit="Register">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    <ValidationSummary />

    <label>
        Email
        <InputText @bind-Value="Model.Email" />
    </label>
    <ValidationMessage For="() => Model.Email" />

    <label>
        Display name
        <InputText @bind-Value="Model.DisplayName" />
    </label>
    <ValidationMessage For="() => Model.DisplayName" />

    <button type="submit">Register</button>
</EditForm>

@if (created)
{
    <p>Account created.</p>
}

@code {
    [SupplyParameterFromForm]
    private RegisterModel Model { get; set; } = new();

    private bool created;

    private void Register()
    {
        created = true;
    }

    private sealed class RegisterModel
    {
        [Required, EmailAddress]
        public string? Email { get; set; }

        [Required, StringLength(40)]
        public string? DisplayName { get; set; }
    }
}
```

`OnValidSubmit` runs only after model validation succeeds. Use `OnInvalidSubmit` when you need explicit handling for invalid posts.

## Manual validation

Use `OnSubmit` with an `EditContext` when validation combines data annotations with custom server logic:

```razor
@page "/booking"
@using System.ComponentModel.DataAnnotations

<EditForm EditContext="editContext" FormName="booking" OnSubmit="Submit">
    <DataAnnotationsValidator />
    <ValidationSummary />
    <AntiforgeryToken />

    <InputDate @bind-Value="Model.Date" />
    <button type="submit">Book</button>
</EditForm>

@code {
    [SupplyParameterFromForm]
    private BookingModel Model { get; set; } = new();

    private EditContext? editContext;
    private ValidationMessageStore? messages;

    protected override void OnInitialized()
    {
        editContext = new(Model);
        messages = new(editContext);
    }

    private void Submit()
    {
        messages!.Clear();

        if (editContext!.Validate() && Model.Date < DateOnly.FromDateTime(DateTime.Today))
        {
            messages.Add(() => Model.Date, "Choose today or a future date.");
        }

        editContext.NotifyValidationStateChanged();

        if (!editContext.GetValidationMessages().Any())
        {
            // Process the valid booking.
        }
    }

    private sealed class BookingModel
    {
        [Required]
        public DateOnly? Date { get; set; }
    }
}
```

For models bound from POST data, combine this pattern with `[SupplyParameterFromForm]` and recreate the `EditContext` for the current request.

## Business-rule validation

Prefer server-side validation for rules that depend on private data, such as account ownership, inventory, authorization, pricing, or database state. Browser validation can improve usability, but it can't be trusted.

Example submit handler:

```csharp
private async Task Submit()
{
    messages!.Clear();

    if (!editContext!.Validate())
    {
        return;
    }

    if (!await Inventory.HasStockAsync(Model.Sku, Model.Quantity))
    {
        messages.Add(() => Model.Quantity, "Not enough stock is available.");
        editContext.NotifyValidationStateChanged();
        return;
    }

    await Orders.CreateAsync(Model);
}
```

## Custom validation attributes

Custom data annotation attributes work in Static SSR because validation runs on the server:

```csharp
public sealed class FutureDateAttribute : ValidationAttribute
{
    public override bool IsValid(object? value)
    {
        return value is DateOnly date &&
            date >= DateOnly.FromDateTime(DateTime.Today);
    }
}
```

Apply the attribute to the form model and include `DataAnnotationsValidator`.

## Validation and enhanced forms

Enhanced forms can patch the rerendered response into the existing document instead of performing a full reload. Validation still happens on the server, and the server-rendered validation messages are returned in the response.

```razor
<EditForm Model="Model"
          FormName="contact"
          Enhance
          OnValidSubmit="Submit">
    ...
</EditForm>
```

Design the form so it also works as a normal POST when JavaScript or enhanced form handling is unavailable.

## Security notes

- Validate again on the server even if you add browser-side checks.
- Use input models instead of binding directly to persistence entities.
- Keep antiforgery enabled for state-changing form posts.
- Treat route values, query strings, form fields, headers, and cookies as untrusted input.

## Additional resources

- [Forms binding](/forms/binding)
- [Input components](/forms/input-components)
- [Static SSR threat mitigation](/security/threat-mitigation)
