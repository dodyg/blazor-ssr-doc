---
title: ASP.NET Core Blazor input components
description: Learn about built-in Blazor input components.
layout: page
section: Forms
toc: true
---

# ASP.NET Core Blazor input components


This article describes Blazor's built-in input components.

## Input components

The Blazor framework provides built-in input components to receive and validate user input. The built-in input components in the following table are supported in an [Microsoft.AspNetCore.Components.Forms.EditForm](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editform) with an [Microsoft.AspNetCore.Components.Forms.EditContext](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editcontext).

:::moniker range=">= aspnetcore-7.0"

The components in the table are also supported outside of a form in Razor component markup. Inputs are validated when they're changed and when a form is submitted.

:::moniker-end

:::moniker range=">= aspnetcore-5.0"

| Input component | Rendered as&hellip; |
| --------------- | ------------------- |
| [Microsoft.AspNetCore.Components.Forms.InputCheckbox](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputcheckbox) | `<input type="checkbox">` |
| [Microsoft.AspNetCore.Components.Forms.InputDate`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputdate%601) | `<input type="date">` |
| [Microsoft.AspNetCore.Components.Forms.InputFile](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputfile) | `<input type="file">` |
| [Microsoft.AspNetCore.Components.Forms.InputNumber`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputnumber%601) | `<input type="number">` |
| [Microsoft.AspNetCore.Components.Forms.InputRadio`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputradio%601) | `<input type="radio">` |
| [Microsoft.AspNetCore.Components.Forms.InputRadioGroup`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputradiogroup%601) | Group of child [Microsoft.AspNetCore.Components.Forms.InputRadio`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputradio%601) |
| [Microsoft.AspNetCore.Components.Forms.InputSelect`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputselect%601) | `<select>` |
| [Microsoft.AspNetCore.Components.Forms.InputText](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputtext) | `<input>` |
| [Microsoft.AspNetCore.Components.Forms.InputTextArea](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputtextarea) | `<textarea>` |
| [`Label<TValue>`](#label-component) (.NET 11 or later) | `<label>` |

For more information on the [Microsoft.AspNetCore.Components.Forms.InputFile](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputfile) component, see [file-uploads](https://learn.microsoft.com/aspnet/core/blazor/file-uploads).

:::moniker-end

:::moniker range="< aspnetcore-5.0"

| Input component | Rendered as&hellip; |
| --------------- | ------------------- |
| [Microsoft.AspNetCore.Components.Forms.InputCheckbox](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputcheckbox) | `<input type="checkbox">` |
| [Microsoft.AspNetCore.Components.Forms.InputDate`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputdate%601) | `<input type="date">` |
| [Microsoft.AspNetCore.Components.Forms.InputNumber`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputnumber%601) | `<input type="number">` |
| [Microsoft.AspNetCore.Components.Forms.InputSelect`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputselect%601) | `<select>` |
| [Microsoft.AspNetCore.Components.Forms.InputText](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputtext) | `<input>` |
| [Microsoft.AspNetCore.Components.Forms.InputTextArea](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputtextarea) | `<textarea>` |

> [!NOTE]
> [Microsoft.AspNetCore.Components.Forms.InputRadio`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputradio%601) and [Microsoft.AspNetCore.Components.Forms.InputRadioGroup`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputradiogroup%601) components are available in .NET 5 or later. For more information, select a .NET 5 or later version of this article.

:::moniker-end

All of the input components, including [Microsoft.AspNetCore.Components.Forms.EditForm](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editform), support arbitrary attributes. Any attribute that doesn't match a component parameter is added to the rendered HTML element.

Input components provide default behavior for validating when a field is changed:

* For input components in a form with an [Microsoft.AspNetCore.Components.Forms.EditContext](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editcontext), the default validation behavior includes updating the field CSS class to reflect the field's state as valid or invalid with validation styling of the underlying HTML element.
* For controls that don't have an [Microsoft.AspNetCore.Components.Forms.EditContext](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editcontext), the default validation reflects the valid or invalid state but doesn't provide validation styling to the underlying HTML element.

Some components include useful parsing logic. For example, [Microsoft.AspNetCore.Components.Forms.InputDate`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputdate%601) and [Microsoft.AspNetCore.Components.Forms.InputNumber`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputnumber%601) handle unparseable values gracefully by registering unparseable values as validation errors. Types that can accept null values also support nullability of the target field (for example, `int?` for a nullable integer).

:::moniker range=">= aspnetcore-9.0"

The [Microsoft.AspNetCore.Components.Forms.InputNumber`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputnumber%601) component supports the [`type="range"` attribute](https://developer.mozilla.org/docs/Web/HTML/Element/input/range), which creates a range input that supports model binding and form validation, typically rendered as a slider or dial control rather than a text box:

```razor
<InputNumber @bind-Value="..." max="..." min="..." step="..." type="range" />
```

:::moniker-end

:::moniker range=">= aspnetcore-5.0"

For more information on the [Microsoft.AspNetCore.Components.Forms.InputFile](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputfile) component, see [file-uploads](https://learn.microsoft.com/aspnet/core/blazor/file-uploads).

:::moniker-end

## Example form

The following `Starship` type, which is used in several of this article's examples and examples in other *Forms* node articles, defines a diverse set of properties with data annotations:

* `Id` is required because it's annotated with the [System.ComponentModel.DataAnnotations.RequiredAttribute](https://learn.microsoft.com/dotnet/api/system.componentmodel.dataannotations.requiredattribute). `Id` requires a value of at least one character but no more than 16 characters using the [System.ComponentModel.DataAnnotations.StringLengthAttribute](https://learn.microsoft.com/dotnet/api/system.componentmodel.dataannotations.stringlengthattribute).
* `Description` is optional because it isn't annotated with the [System.ComponentModel.DataAnnotations.RequiredAttribute](https://learn.microsoft.com/dotnet/api/system.componentmodel.dataannotations.requiredattribute).
* `Classification` is required.
* The `MaximumAccommodation` property defaults to zero but requires a value from one to 100,000 per its [System.ComponentModel.DataAnnotations.RangeAttribute](https://learn.microsoft.com/dotnet/api/system.componentmodel.dataannotations.rangeattribute).
* `IsValidatedDesign` requires that the property have a `true` value, which matches a selected state when the property is bound to a checkbox in the UI (`<input type="checkbox">`).
* `ProductionDate` is a [System.DateTime](https://learn.microsoft.com/dotnet/api/system.datetime) and required.

`Starship.cs`:

:::moniker range=">= aspnetcore-9.0"

:::code language="csharp" source="~/../blazor-samples/9.0/BlazorSample_BlazorWebApp/Starship.cs":::

:::moniker-end

:::moniker range=">= aspnetcore-8.0 < aspnetcore-9.0"

:::code language="csharp" source="~/../blazor-samples/8.0/BlazorSample_BlazorWebApp/Starship.cs":::

:::moniker-end

:::moniker range=">= aspnetcore-7.0 < aspnetcore-8.0"

:::code language="csharp" source="~/../blazor-samples/7.0/BlazorSample_WebAssembly/Starship.cs":::

:::moniker-end

:::moniker range=">= aspnetcore-6.0 < aspnetcore-7.0"

:::code language="csharp" source="~/../blazor-samples/6.0/BlazorSample_WebAssembly/Starship.cs":::

:::moniker-end

:::moniker range=">= aspnetcore-5.0 < aspnetcore-6.0"

:::code language="csharp" source="~/../blazor-samples/5.0/BlazorSample_WebAssembly/Starship.cs":::

:::moniker-end

:::moniker range="< aspnetcore-5.0"

:::code language="csharp" source="~/../blazor-samples/3.1/BlazorSample_WebAssembly/Starship.cs":::

:::moniker-end

The following form accepts and validates user input using:

* The properties and validation defined in the preceding `Starship` model.
* Several of Blazor's built-in input components.

When the model property for the ship's classification (`Classification`) is set, the option matching the model is checked. For example, `checked="@(Model!.Classification == "Exploration")"` for the classification of an exploration ship. The reason for explicitly setting the checked option is that the value of a `<select>` element is only present in the browser. If the form is rendered on the server after it's submitted, any state from the client is overridden with state from the server, which doesn't ordinarily mark an option as checked. By setting the checked option from the model property, the classification always reflects the model's state. This preserves the classification selection across form submissions that result in the form rerendering on the server. In situations where the form isn't rerendered on the server, such as when the Interactive Server render mode is applied directly to the component, explicit assignment of the checked option from the model isn't necessary because Blazor preserves the state for the `<select>` element on the client.

`Starship3.razor`:

:::moniker range=">= aspnetcore-9.0"

:::code language="razor" source="~/../blazor-samples/9.0/BlazorSample_BlazorWebApp/Components/Pages/Starship3.razor":::

:::moniker-end

:::moniker range=">= aspnetcore-8.0 < aspnetcore-9.0"

:::code language="razor" source="~/../blazor-samples/8.0/BlazorSample_BlazorWebApp/Components/Pages/Starship3.razor":::

:::moniker-end


The [Microsoft.AspNetCore.Components.Forms.EditForm](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editform) in the preceding example creates an [Microsoft.AspNetCore.Components.Forms.EditContext](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editcontext) based on the assigned `Starship` instance (`Model="..."`) and handles a valid form. The next example demonstrates how to assign an [Microsoft.AspNetCore.Components.Forms.EditContext](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editcontext) to a form and validate when the form is submitted.

In the following example:

* A shortened version of the earlier `Starfleet Starship Database` form (`Starship3` component) is used that only accepts a value for the starship's Id. The other `Starship` properties receive valid default values when an instance of the `Starship` type is created.
* The `Submit` method executes when the **`Submit`** button is selected.
* The form is validated by calling [Microsoft.AspNetCore.Components.Forms.EditContext.Validate *?displayProperty=nameWithType](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editcontext.validate%2a?displayproperty=namewithtype) in the `Submit` method.
* Logging is executed depending on the validation result.

`Starship4.razor`:

:::moniker range=">= aspnetcore-9.0"

:::code language="razor" source="~/../blazor-samples/9.0/BlazorSample_BlazorWebApp/Components/Pages/Starship4.razor":::

:::moniker-end

:::moniker range=">= aspnetcore-8.0 < aspnetcore-9.0"

:::code language="razor" source="~/../blazor-samples/8.0/BlazorSample_BlazorWebApp/Components/Pages/Starship4.razor":::

:::moniker-end


> [!NOTE]
> Changing the [Microsoft.AspNetCore.Components.Forms.EditContext](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.editcontext) after it's assigned is **not** supported.

:::moniker range=">= aspnetcore-6.0"

## Multiple option selection with the `InputSelect` component

Binding supports [`multiple`](https://developer.mozilla.org/docs/Web/HTML/Attributes/multiple) option selection with the [Microsoft.AspNetCore.Components.Forms.InputSelect`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputselect%601) component. The [`@onchange`](https://learn.microsoft.com/aspnet/core/mvc/views/razor#onevent) event provides an array of the selected options via [event arguments (`ChangeEventArgs`)](https://learn.microsoft.com/aspnet/core/blazor/components/event-handling#event-arguments). The value must be bound to an array type, which results in the [Microsoft.AspNetCore.Components.Forms.InputSelect`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputselect%601) component automatically adding the [`multiple` attribute](https://developer.mozilla.org/docs/Web/HTML/Attributes/multiple) to the `<select>` element when the component is rendered.

In the following example, the user must select at least two starship classifications but no more than three classifications.

`Starship5.razor`:

:::moniker-end

:::moniker range=">= aspnetcore-9.0"

:::code language="razor" source="~/../blazor-samples/9.0/BlazorSample_BlazorWebApp/Components/Pages/Starship5.razor":::

:::moniker-end

:::moniker range=">= aspnetcore-8.0 < aspnetcore-9.0"

:::code language="razor" source="~/../blazor-samples/8.0/BlazorSample_BlazorWebApp/Components/Pages/Starship5.razor":::

:::moniker-end

:::moniker range=">= aspnetcore-6.0 < aspnetcore-8.0"

```razor
@page "/starship-5"
@using System.ComponentModel.DataAnnotations
@inject ILogger<Starship5> Logger

<h1>Bind Multiple <code>InputSelect</code> Example</h1>

<EditForm EditContext="editContext" OnValidSubmit="Submit">
    <DataAnnotationsValidator />
    <ValidationSummary />
    <div>
        <label>
            Select classifications (Minimum: 2, Maximum: 3):
            <InputSelect @bind-Value="Model!.SelectedClassification">
                <option value="@Classification.Exploration">Exploration</option>
                <option value="@Classification.Diplomacy">Diplomacy</option>
                <option value="@Classification.Defense">Defense</option>
                <option value="@Classification.Research">Research</option>
            </InputSelect>
        </label>
    </div>
    <div>
        <button type="submit">Submit</button>
    </div>
</EditForm>

@if (Model?.SelectedClassification?.Length > 0)
{
    <div>@string.Join(", ", Model.SelectedClassification)</div>
}

@code {
    private EditContext? editContext;

    private Starship? Model { get; set; }

    protected override void OnInitialized()
    {
        Model ??= new();
        editContext = new(Model);
    }

    private void Submit()
    {
        Logger.LogInformation("Submit called: Processing the form");
    }

    private class Starship
    {
        [Required]
        [MinLength(2, ErrorMessage = "Select at least two classifications.")]
        [MaxLength(3, ErrorMessage = "Select no more than three classifications.")]
        public Classification[]? SelectedClassification { get; set; } =
            new[] { Classification.None };
    }

    private enum Classification { None, Exploration, Diplomacy, Defense, Research }
}
```

<!--
:::code language="razor" source="~/../blazor-samples/7.0/BlazorSample_WebAssembly/Pages/forms-and-validation/Starship5.razor":::
-->

:::moniker-end

:::moniker range=">= aspnetcore-6.0"

For information on how empty strings and `null` values are handled in data binding, see the [Binding `InputSelect` options to C# object `null` values](#binding-inputselect-options-to-c-object-null-values) section.

:::moniker-end

## Binding `InputSelect` options to C# object `null` values

For information on how empty strings and `null` values are handled in data binding, see [data-binding](https://learn.microsoft.com/aspnet/core/blazor/components/data-binding#binding-select-element-options-to-c-object-null-values).

:::moniker range=">= aspnetcore-5.0"

## Display name support

Several built-in components support display names with the [Microsoft.AspNetCore.Components.Forms.InputBase`1.DisplayName *?displayProperty=nameWithType](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputbase%601.displayname%2a?displayproperty=namewithtype) parameter.

In the `Starfleet Starship Database` form (`Starship3` component) of the [Example form](#example-form) section, the production date of a new starship doesn't specify a display name:

```razor
<label>
    Production Date:
    <InputDate @bind-Value="Model!.ProductionDate" />
</label>
```

If the field contains an invalid date when the form is submitted, the error message doesn't display a friendly name. The field name, "`ProductionDate`" doesn't have a space between "`Production`" and "`Date`" when it appears in the validation summary:

> The ProductionDate field must be a date.

Set the [Microsoft.AspNetCore.Components.Forms.InputBase`1.DisplayName *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputbase%601.displayname%2a) property to a friendly name with a space between the words "`Production`" and "`Date`":

```razor
<label>
    Production Date:
    <InputDate @bind-Value="Model!.ProductionDate" 
        DisplayName="Production Date" />
</label>
```

The validation summary displays the friendly name when the field's value is invalid:

> The Production Date field must be a date.

:::moniker-end

:::moniker range=">= aspnetcore-11.0"

<!-- UPDATE 11.0 - API cross-link 

                   [Microsoft.AspNetCore.Components.Forms.DisplayName`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.displayname%601)
-->
The `DisplayName` component can be used to display property names from metadata attributes

```csharp
[Required, DisplayName("Production Date")]
public DateTime ProductionDate { get; set; }
```

The [`[Display]` attribute](xref:System.ComponentModel.DataAnnotations.DisplayAttribute) on the model class property is supported:

```csharp
[Required, Display(Name = "Production Date")]
public DateTime ProductionDate { get; set; }
```

Between the two approaches, the `[Display]` attribute is recommended, which makes additional properties available. The `[Display]` attribute also enables assigning a resource type for localization. When both attributes are present, `[Display]` takes precedence over `[DisplayName]`. If neither attribute is present, the component falls back to the property name.

Use the `DisplayName` component in labels or table headers:

```razor
<label>
    <DisplayName For="@(() => Model!.ProductionDate)" />
    <InputDate @bind-Value="Model!.ProductionDate" />
</label>
```

:::moniker-end

:::moniker range=">= aspnetcore-11.0"

## `Label` component

<!-- UPDATE 11.0 - API cross-link 

                   [Microsoft.AspNetCore.Components.Forms.Label`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.label%601)
-->

The `Label` component renders a `<label>` element that automatically extracts the display name from a model property using `[Display]` or `[DisplayName]` attributes. This simplifies form creation by eliminating the need to manually specify label text.

### Nested pattern

The nested pattern wraps the input component inside the label:

```razor
<Label For="() => Model!.ProductionDate">
    <InputDate @bind-Value="Model!.ProductionDate" />
</Label>
```

This renders:

```html
<label>Production Date<input type="date" ... /></label>
```

### Non-nested pattern

For accessibility requirements or styling flexibility, use the non-nested pattern where the label's `for` attribute references the input's `id`:

```razor
<Label For="() => Model!.ProductionDate" />
<InputDate @bind-Value="Model!.ProductionDate" />
```

This renders:

```html
<label for="Model_ProductionDate">Production Date</label>
<input id="Model_ProductionDate" type="date" ... />
```

The `id` attribute is automatically sanitized to create a valid HTML id (dots are replaced with underscores to avoid CSS selector conflicts).

Input components automatically generate an `id` attribute based on the bound expression. If an explicit `id` is provided, it takes precedence:

```razor
<Label For="() => Model!.ProductionDate" for="prod-date" />
<InputDate @bind-Value="Model!.ProductionDate" id="prod-date" />
```

:::moniker-end

## Error message template support

[Microsoft.AspNetCore.Components.Forms.InputDate`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputdate%601) and [Microsoft.AspNetCore.Components.Forms.InputNumber`1](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputnumber%601) support error message templates:

* [Microsoft.AspNetCore.Components.Forms.InputDate`1.ParsingErrorMessage *?displayProperty=nameWithType](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputdate%601.parsingerrormessage%2a?displayproperty=namewithtype)
* [Microsoft.AspNetCore.Components.Forms.InputNumber`1.ParsingErrorMessage *?displayProperty=nameWithType](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputnumber%601.parsingerrormessage%2a?displayproperty=namewithtype)

:::moniker range=">= aspnetcore-5.0"

In the `Starfleet Starship Database` form (`Starship3` component) of the [Example form](#example-form) section with a [friendly display name](#display-name-support) assigned, the `Production Date` field produces an error message using the following default error message template:

```css
The {0} field must be a date.
```

The position of the `{0}` placeholder is where the value of the [Microsoft.AspNetCore.Components.Forms.InputBase`1.DisplayName *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputbase%601.displayname%2a) property appears when the error is displayed to the user.

```razor
<label>
    Production Date:
    <InputDate @bind-Value="Model!.ProductionDate" 
        DisplayName="Production Date" />
</label>
```

> The Production Date field must be a date.

Assign a custom template to [Microsoft.AspNetCore.Components.Forms.InputDate`1.ParsingErrorMessage *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputdate%601.parsingerrormessage%2a) to provide a custom message:

```razor
<label>
    Production Date:
    <InputDate @bind-Value="Model!.ProductionDate" 
        DisplayName="Production Date" 
        ParsingErrorMessage="The {0} field has an incorrect date value." />
</label>
```

> The Production Date field has an incorrect date value.

:::moniker-end

:::moniker range="< aspnetcore-5.0"

In the `Starfleet Starship Database` form (`Starship3` component) of the [Example form](#example-form) section uses a default error message template:

```css
The {0} field must be a date.
```

The position of the `{0}` placeholder is where the value of the [Microsoft.AspNetCore.Components.Forms.InputBase`1.DisplayName *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputbase%601.displayname%2a) property appears when the error is displayed to the user.

```razor
<label>
    Production Date:
    <InputDate @bind-Value="Model!.ProductionDate" />
</label>
```

> The ProductionDate field must be a date.

Assign a custom template to [Microsoft.AspNetCore.Components.Forms.InputDate`1.ParsingErrorMessage *](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputdate%601.parsingerrormessage%2a) to provide a custom message:

```razor
<label>
    Production Date:
    <InputDate @bind-Value="Model!.ProductionDate" 
        ParsingErrorMessage="The {0} field has an incorrect date value." />
</label>
```

> The ProductionDate field has an incorrect date value.

:::moniker-end

:::moniker range=">= aspnetcore-10.0"

## `InputHidden` component to handle hidden input fields in forms

The [`InputHidden` component](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.components.forms.inputhidden) provides a hidden input field for storing string values.

In the following example, a hidden input field is created for the form's `Parameter` property. When the form is submitted, the value of the hidden field is displayed:

```razor
<EditForm Model="Parameter" OnValidSubmit="Submit" FormName="InputHidden Example">
    <InputHidden id="hidden" @bind-Value="Parameter" />
    <button type="submit">Submit</button>
</EditForm>

@if (submitted)
{
    <p>Hello @Parameter!</p>
}

@code {
    private bool submitted;

    [SupplyParameterFromForm] 
    public string Parameter { get; set; } = "stranger";

    private void Submit() => submitted = true;
}
```

:::moniker-end
