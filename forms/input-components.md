---
title: Input components in Blazor Static SSR
description: Use built-in Blazor input components in Static SSR forms.

section: Forms
toc: true
---

# Input components in Blazor Static SSR

Blazor input components render ordinary HTML form controls and integrate with `EditForm`, model binding, and validation.

| Input component | Rendered HTML |
| --------------- | ------------- |
| `InputCheckbox` | `<input type="checkbox">` |
| `InputDate<TValue>` | `<input type="date">` |
| `InputFile` | `<input type="file">` |
| `InputNumber<TValue>` | `<input type="number">` |
| `InputRadio<TValue>` | `<input type="radio">` |
| `InputRadioGroup<TValue>` | A group of radio inputs |
| `InputSelect<TValue>` | `<select>` |
| `InputText` | `<input>` |
| `InputTextArea` | `<textarea>` |

## Static SSR behavior

In Static SSR, input components don't update .NET state while the user types. They bind submitted values when the form posts back to the server.

This means:

- `@bind-Value` is still the right way to connect an input to a model property.
- Validation messages update after the form is submitted and the server rerenders the page.
- Client-side validation and per-keystroke .NET change handling require an interactive render mode.
- Browser-native validation attributes, CSS, and JavaScript can still run on the client.

## Example form

```razor
@page "/profile"
@using System.ComponentModel.DataAnnotations

<EditForm Model="Model" FormName="profile" OnValidSubmit="Save">
    <DataAnnotationsValidator />
    <AntiforgeryToken />

    <div>
        <label>
            Name
            <InputText @bind-Value="Model.Name" />
        </label>
        <ValidationMessage For="() => Model.Name" />
    </div>

    <div>
        <label>
            Birth date
            <InputDate @bind-Value="Model.BirthDate" />
        </label>
        <ValidationMessage For="() => Model.BirthDate" />
    </div>

    <div>
        <label>
            Contact preference
            <InputSelect @bind-Value="Model.ContactPreference">
                <option value="">Select one</option>
                <option value="Email">Email</option>
                <option value="Phone">Phone</option>
            </InputSelect>
        </label>
        <ValidationMessage For="() => Model.ContactPreference" />
    </div>

    <button type="submit">Save</button>
</EditForm>

@if (saved)
{
    <p>Profile saved.</p>
}

@code {
    [SupplyParameterFromForm]
    private ProfileModel Model { get; set; } = new();

    private bool saved;

    private void Save()
    {
        saved = true;
    }

    private sealed class ProfileModel
    {
        [Required]
        public string? Name { get; set; }

        [Required]
        public DateOnly? BirthDate { get; set; }

        [Required]
        public string? ContactPreference { get; set; }
    }
}
```

## Preserve selected values

When a Static SSR form rerenders after POST, the server-rendered model controls the selected values. Initialize defaults only when a posted model isn't supplied, and keep the model populated with values you want to display again.

For plain HTML controls, set `selected`, `checked`, and `value` from the model:

```razor
<select name="category">
    <option value="books" selected="@(Model.Category == "books")">Books</option>
    <option value="tools" selected="@(Model.Category == "tools")">Tools</option>
</select>
```

Input components handle this for bound values.

## Multiple select

Bind a multiple-selection input to an array or collection property:

```razor
<InputSelect @bind-Value="Model.Categories" multiple>
    <option value="books">Books</option>
    <option value="tools">Tools</option>
    <option value="games">Games</option>
</InputSelect>

@code {
    [SupplyParameterFromForm]
    private SearchModel Model { get; set; } = new();

    private sealed class SearchModel
    {
        public string[] Categories { get; set; } = [];
    }
}
```

## File input

`InputFile` renders a file input. For Static SSR, design uploads as server-handled form posts and apply normal upload protections:

- Limit file size and count.
- Validate file type by inspecting content, not just extensions.
- Store uploads outside the app's executable content path unless they are intentionally public.
- Never trust a client-provided file name.

## Additional resources

- [Forms binding](/forms/binding)
- [Forms validation](/forms/validation)
- [Static SSR threat mitigation](/security/threat-mitigation)
