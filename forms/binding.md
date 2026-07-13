---
title: Forms binding in Blazor Static SSR
description: Bind posted form data to Razor component models in Blazor Static SSR.

section: Forms
toc: true
---

# Forms binding in Blazor Static SSR

Static SSR forms use normal HTTP POST requests. The server rerenders the component for each request and binds submitted form values to component properties marked with `[SupplyParameterFromForm]`.

## Basic form binding

Use `EditForm` with a model, a unique `FormName`, and submit callback:

```razor
@page "/starship"
@using System.ComponentModel.DataAnnotations

<EditForm Model="Model" FormName="starship" OnValidSubmit="Submit">
    <DataAnnotationsValidator />
    <AntiforgeryToken />

    <label>
        Identifier
        <InputText @bind-Value="Model.Identifier" />
    </label>
    <ValidationMessage For="() => Model.Identifier" />

    <button type="submit">Save</button>
</EditForm>

@if (saved)
{
    <p>Saved @Model.Identifier.</p>
}

@code {
    [SupplyParameterFromForm]
    private Starship Model { get; set; } = new();

    private bool saved;

    private void Submit()
    {
        saved = true;
    }

    private sealed class Starship
    {
        [Required]
        [StringLength(16)]
        public string? Identifier { get; set; }
    }
}
```

The model property can be private. Blazor binds it during the form POST before the submit handler runs.

## `Model` and `EditContext`

Assign either `Model` or `EditContext` to an `EditForm`, not both.

Use `Model` for the common case:

```razor
<EditForm Model="Model" FormName="profile" OnValidSubmit="Save">
    ...
</EditForm>
```

Use `EditContext` when you need direct access to validation state:

```razor
<EditForm EditContext="editContext" FormName="profile" OnValidSubmit="Save">
    ...
</EditForm>

@code {
    private EditContext? editContext;

    [SupplyParameterFromForm]
    private Profile Model { get; set; } = new();

    protected override void OnInitialized()
    {
        editContext = new(Model);
    }
}
```

## Form names

Static SSR forms must have a unique form name when they post to a Razor component endpoint:

```razor
<EditForm Model="Model" FormName="contact" OnSubmit="Submit">
    ...
</EditForm>
```

The form name is checked when the POST request arrives. Use `FormMappingScope` when reusable components might produce forms with the same name:

```razor
<FormMappingScope Name="Billing">
    <AddressForm />
</FormMappingScope>

<FormMappingScope Name="Shipping">
    <AddressForm />
</FormMappingScope>
```

## Binding multiple forms

Use `[SupplyParameterFromForm(FormName = "...")]` when a page has multiple forms and each form has a separate model:

```razor
@page "/account"
@using System.ComponentModel.DataAnnotations

<EditForm Model="Profile" FormName="profile" OnValidSubmit="SaveProfile">
    <InputText @bind-Value="Profile.DisplayName" />
    <button type="submit">Save profile</button>
</EditForm>

<EditForm Model="Password" FormName="password" OnValidSubmit="ChangePassword">
    <InputText type="password" @bind-Value="Password.CurrentPassword" />
    <InputText type="password" @bind-Value="Password.NewPassword" />
    <button type="submit">Change password</button>
</EditForm>

@code {
    [SupplyParameterFromForm(FormName = "profile")]
    private ProfileModel Profile { get; set; } = new();

    [SupplyParameterFromForm(FormName = "password")]
    private PasswordModel Password { get; set; } = new();

    private void SaveProfile() { }

    private void ChangePassword() { }
}
```

## Supported values

Static SSR form mapping supports common .NET values, including primitive types, enums, arrays, collections, and complex object graphs.

Use separate input models that contain only fields the caller is allowed to submit. Don't bind posted form data directly to persistence entities that include server-owned fields such as IDs, roles, tenant IDs, approval flags, or audit properties.

## Configure form mapping limits

Configure Static SSR form mapping limits with `AddRazorComponents`:

```csharp
builder.Services.AddRazorComponents(options =>
{
    options.FormMappingUseCurrentCulture = true;
    options.MaxFormMappingCollectionSize = 1024;
    options.MaxFormMappingErrorCount = 200;
    options.MaxFormMappingKeySize = 1024 * 2;
    options.MaxFormMappingRecursionDepth = 64;
});
```

These limits help protect the server from unexpectedly large or deeply nested form posts.

## Initialize form data

`OnInitialized{Async}` and `OnParametersSet{Async}` run on the initial GET request and on each form POST. Avoid overwriting submitted values when the component rerenders:

```razor
@code {
    [SupplyParameterFromForm]
    private ContactModel? Model { get; set; }

    protected override void OnInitialized()
    {
        Model ??= new ContactModel
        {
            Subscribe = true
        };
    }
}
```

Use the null-coalescing assignment pattern so default values are applied only when a posted model wasn't supplied.

## Antiforgery

`AddRazorComponents` registers antiforgery services. `EditForm` emits antiforgery metadata, and `<AntiforgeryToken />` renders the hidden request token.

In manually configured pipelines, place antiforgery middleware after authentication and authorization and before Razor component endpoints:

```csharp
app.UseAuthentication();
app.UseAuthorization();
app.UseAntiforgery();

app.MapRazorComponents<App>();
```

## Additional resources

- [Input components](/forms/input-components)
- [Validation](/forms/validation)
- [Threat mitigation](/security/threat-mitigation)
