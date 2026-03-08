---
title: Forms
description: Handle user input with forms and validation in Blazor SSR
layout: page
section: Forms
toc: true
---

# Forms

Learn how to build forms in Blazor SSR applications with built-in validation and user input handling.

## Topics

### [Input Components](/forms/input-components)
Explore the built-in input components provided by Blazor: InputText, InputNumber, InputSelect, and more.

### [Validation](/forms/validation)
Add validation to your forms using data annotations and custom validation logic.

### [Data Binding](/forms/binding)
Understand how to bind form inputs to your data models using two-way binding.

## Overview

Blazor provides a powerful forms system that integrates with:

- **Data Annotations**: Use attributes like `[Required]`, `[StringLength]`, etc.
- **Input Components**: Built-in components for various input types
- **Validation**: Automatic client-side and server-side validation
- **EditContext**: Fine-grained control over form behavior

## Basic Form Example

```razor
@page "/contact"
@rendermode InteractiveServer

<EditForm Model="@contactForm" OnValidSubmit="@HandleSubmit">
    <DataAnnotationsValidator />
    
    <div>
        <label for="name">Name:</label>
        <InputText id="name" @bind-Value="contactForm.Name" />
        <ValidationMessage For="@(() => contactForm.Name)" />
    </div>
    
    <div>
        <label for="email">Email:</label>
        <InputText id="email" @bind-Value="contactForm.Email" />
        <ValidationMessage For="@(() => contactForm.Email)" />
    </div>
    
    <button type="submit">Submit</button>
</EditForm>

@code {
    private ContactForm contactForm = new();

    private void HandleSubmit()
    {
        // Process the form
    }

    public class ContactForm
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; }

        [Required]
        [EmailAddress]
        public string Email { get; set; }
    }
}
```

## Built-in Input Components

- `InputText` - Text input
- `InputNumber<T>` - Numeric input
- `InputDate<T>` - Date input
- `InputTextArea` - Multi-line text
- `InputSelect<T>` - Dropdown/select
- `InputCheckbox` - Boolean checkbox
- `InputFile` - File upload

## Next Steps

After mastering forms, explore [Security](/security/) to learn about authentication and authorization.
