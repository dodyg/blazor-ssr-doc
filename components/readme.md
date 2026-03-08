---
title: Components
description: Deep dive into Razor components and how they work in Blazor SSR
layout: page
section: Components
toc: true
---

# Components

Components are the building blocks of Blazor applications. Learn how to create, use, and optimize components in your SSR applications.

## Topics

### [Component Basics](/components/index)
Learn the fundamentals of Razor components: their structure, syntax, and how to create reusable UI elements.

### [Rendering](/components/rendering)
Understand how components are rendered in Blazor SSR. Learn about rendering concepts, optimization techniques, and best practices.

### [Prerendering](/components/prerender)
Improve perceived performance with prerendering. Learn how to pre-render components to static HTML before they become interactive.

### [Lifecycle](/components/lifecycle)
Master the component lifecycle methods. Learn when to use OnInitialized, OnParametersSet, OnAfterRender, and other lifecycle events.

### [Cascading Values and Parameters](/components/cascading-values-and-parameters)
Share data across the component hierarchy using cascading values and parameters.

### [Event Handling](/components/event-handling)
Handle user interactions in your components. Learn about event arguments, event callbacks, and how to handle DOM events.

### [Data Binding](/components/data-binding)
Bind data between your components and the UI. Learn about one-way and two-way binding patterns.

## Component Structure

A typical Razor component consists of:

```razor
@page "/counter"
@rendermode InteractiveServer

<h1>Counter</h1>

<p>Current count: @currentCount</p>

<button @onclick="IncrementCount">Click me</button>

@code {
    private int currentCount = 0;

    private void IncrementCount()
    {
        currentCount++;
    }
}
```

## Best Practices

- **Keep components small and focused**: Each component should have a single responsibility
- **Use parameters for input**: Pass data into components via parameters
- **Leverage cascading values**: Share common data without prop drilling
- **Optimize rendering**: Use `ShouldRender` and other optimization techniques when needed

## Next Steps

After mastering components, explore [Forms](/forms/) to learn about handling user input with validation.
