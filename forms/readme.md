---
title: Forms
description: Handle user input with forms and validation in Blazor Static SSR

section: Forms
toc: true
---

# Forms

Learn how to build forms in Blazor Static SSR applications with built-in validation and user input handling.

## Topics

### [Input Components](/forms/input-components)
Explore the built-in input components provided by Blazor: InputText, InputNumber, InputSelect, and more.

### [Validation](/forms/validation)
Add validation to your forms using data annotations and custom validation logic.

### [Data Binding](/forms/binding)
Understand how to bind form inputs to your data models in Static SSR.

## Overview

Blazor provides a powerful forms system that integrates with:

- **Data Annotations**: Use attributes like `[Required]`, `[StringLength]`, etc.
- **Input Components**: Built-in components for various input types
- **Server-side Validation**: Validation occurs on form submission
- **EditContext**: Fine-grained control over form behavior

## Basic Form Example

In Static SSR, forms use traditional POST requests:

```razor
@page "/contact"
@inject EmailService EmailService

<h1>Contact Us</h1>

<EditForm Model="@contactForm" OnValidSubmit="@HandleSubmit" FormName="ContactForm">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    
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
    
    <div>
        <label for="message">Message:</label>
        <InputTextArea id="message" @bind-Value="contactForm.Message" />
        <ValidationMessage For="@(() => contactForm.Message)" />
    </div>
    
    <button type="submit">Submit</button>
</EditForm>

@if (submitted)
{
    <p>Thank you! Your message has been sent.</p>
}

@code {
    private ContactForm contactForm = new();
    private bool submitted;

    private async Task HandleSubmit()
    {
        await EmailService.SendAsync(contactForm);
        submitted = true;
    }

    public class ContactForm
    {
        [Required(ErrorMessage = "Name is required")]
        [StringLength(100, ErrorMessage = "Name must be less than 100 characters")]
        public string Name { get; set; } = "";

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        public string Email { get; set; } = "";

        [Required(ErrorMessage = "Message is required")]
        [StringLength(1000, ErrorMessage = "Message must be less than 1000 characters")]
        public string Message { get; set; } = "";
    }
}
```

## Built-in Input Components

- `InputText` - Text input (`<input type="text">`)
- `InputNumber<T>` - Numeric input (`<input type="number">`)
- `InputDate<T>` - Date input (`<input type="date">`)
- `InputTextArea` - Multi-line text (`<textarea>`)
- `InputSelect<T>` - Dropdown/select (`<select>`)
- `InputCheckbox` - Boolean checkbox (`<input type="checkbox">`)
- `InputFile` - File upload (`<input type="file">`)

## Form Submission in Static SSR

In Static SSR, form submission triggers a full HTTP POST request:

1. User fills out the form
2. Form is submitted via POST
3. Server validates and processes the data
4. Server renders a new page response

### Antiforgery Protection

Always include antiforgery tokens in forms:

```razor
<EditForm Model="@model" OnValidSubmit="@HandleSubmit" FormName="MyForm">
    <AntiforgeryToken />
    <!-- form fields -->
</EditForm>
```

### Supplying Form Data

For forms that need to receive data from POST requests:

```razor
@page "/edit/{id:int}"
@inject ProductRepository Repository

<h1>Edit Product</h1>

<EditForm Model="@product" OnValidSubmit="@HandleSubmit" FormName="EditProduct">
    <AntiforgeryToken />
    <DataAnnotationsValidator />
    
    <input type="hidden" @bind-value="product.Id" />
    
    <div>
        <label>Name:</label>
        <InputText @bind-Value="product.Name" />
    </div>
    
    <div>
        <label>Price:</label>
        <InputNumber @bind-Value="product.Price" />
    </div>
    
    <button type="submit">Save</button>
</EditForm>

@code {
    [Parameter]
    public int Id { get; set; }

    private Product product = new();

    [SupplyParameterFromForm]
    private Product? FormData { get; set; }

    protected override async Task OnInitializedAsync()
    {
        if (FormData != null)
        {
            product = FormData;
        }
        else
        {
            product = await Repository.GetByIdAsync(Id) ?? new();
        }
    }

    private async Task HandleSubmit()
    {
        await Repository.UpdateAsync(product);
    }
}
```

## Validation

### Data Annotations

Decorate your model with validation attributes:

```csharp
public class UserRegistration
{
    [Required]
    [MinLength(3)]
    [MaxLength(50)]
    public string Username { get; set; } = "";

    [Required]
    [EmailAddress]
    public string Email { get; set; } = "";

    [Required]
    [MinLength(8)]
    [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$", 
        ErrorMessage = "Password must contain uppercase, lowercase, and numbers")]
    public string Password { get; set; } = "";

    [Required]
    [Compare("Password", ErrorMessage = "Passwords do not match")]
    public string ConfirmPassword { get; set; } = "";
}
```

### Displaying Validation Errors

```razor
<EditForm Model="@model" OnValidSubmit="@HandleSubmit" FormName="Registration">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    
    <ValidationSummary />
    
    <div>
        <label>Username:</label>
        <InputText @bind-Value="model.Username" />
        <ValidationMessage For="@(() => model.Username)" />
    </div>
    
    <!-- more fields -->
</EditForm>
```

## CRUD Example

A complete create/edit/delete example:

```razor
@page "/products"
@page "/products/edit/{id:int}"
@inject ProductRepository Repository
@inject NavigationManager Navigation

<h1>@(IsEdit ? "Edit Product" : "New Product")</h1>

<EditForm Model="@product" OnValidSubmit="@HandleSubmit" FormName="ProductForm">
    <DataAnnotationsValidator />
    <AntiforgeryToken />
    
    <div>
        <label>Name:</label>
        <InputText @bind-Value="product.Name" />
        <ValidationMessage For="@(() => product.Name)" />
    </div>
    
    <div>
        <label>Description:</label>
        <InputTextArea @bind-Value="product.Description" />
    </div>
    
    <div>
        <label>Price:</label>
        <InputNumber @bind-Value="product.Price" />
        <ValidationMessage For="@(() => product.Price)" />
    </div>
    
    <div>
        <label>Category:</label>
        <InputSelect @bind-Value="product.CategoryId">
            <option value="">Select category</option>
            @foreach (var cat in categories)
            {
                <option value="@cat.Id">@cat.Name</option>
            }
        </InputSelect>
    </div>
    
    <button type="submit">Save</button>
    <a href="/products">Cancel</a>
</EditForm>

@code {
    [Parameter]
    public int? Id { get; set; }

    private bool IsEdit => Id.HasValue;
    private Product product = new();
    private List<Category> categories = new();

    [SupplyParameterFromForm]
    private Product? FormData { get; set; }

    protected override async Task OnInitializedAsync()
    {
        categories = await Repository.GetCategoriesAsync();
        
        if (FormData != null)
        {
            product = FormData;
        }
        else if (IsEdit && Id.HasValue)
        {
            product = await Repository.GetByIdAsync(Id.Value) ?? new();
        }
    }

    private async Task HandleSubmit()
    {
        if (IsEdit)
        {
            await Repository.UpdateAsync(product);
        }
        else
        {
            await Repository.CreateAsync(product);
        }
        
        Navigation.NavigateTo("/products");
    }
}
```

## Next Steps

After mastering forms, explore [Security](/security/) to learn about authentication and authorization.
