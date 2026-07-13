---
title: JavaScript with Blazor Static SSR
description: Load page-specific JavaScript safely when enhanced navigation updates statically rendered pages.
section: Advanced
toc: true
---

# JavaScript with Blazor Static SSR

Static SSR can use browser JavaScript, but Razor event handlers and .NET-to-JavaScript interop aren't active after the response is sent. Scripts must also account for [enhanced navigation](/fundamentals/routing#enhanced-navigation), which patches new HTML into the existing document instead of reloading the page.

## Why page scripts need lifecycle handling

A `<script>` element placed in a page component may execute on the first full load but not execute again when enhanced navigation returns to that page. It also provides no reliable cleanup point when the page is replaced.

For application-wide scripts, place an external script in the root document. For page-specific behavior, use a JavaScript initializer and respond to Blazor's enhanced navigation events.

## Enhanced navigation events

An `afterWebStarted` initializer receives the Blazor object and can register callbacks:

```javascript
export function afterWebStarted(blazor) {
  blazor.addEventListener('enhancednavigationstart', () => {
    // A same-document navigation is starting.
  });

  blazor.addEventListener('enhancednavigationend', () => {
    // Navigation and DOM patching have completed.
  });

  blazor.addEventListener('enhancedload', () => {
    // The page changed, including a streaming rendering update.
    initializePageFeatures();
  });
}
```

Name an app initializer `{AssemblyName}.lib.module.js` and place it in `wwwroot`. For an RCL, use the RCL assembly name. Blazor discovers the initializer automatically; don't add a separate `<script>` tag for it.

## A page module convention

Collocate a module with the page and export lifecycle functions:

`Components/Pages/Map.razor.js`:

```javascript
let map;

export function onLoad() {
  map = createMap(document.querySelector('#map'));
}

export function onUpdate() {
  map?.resize();
}

export function onDispose() {
  map?.destroy();
  map = undefined;
}
```

A small custom element or shared `PageScript` Razor component can import the module identified by its `src`, call `onLoad` when the page arrives, call `onUpdate` after `enhancedload`, and call `onDispose` when the element disappears. This pattern avoids leaking event listeners and correctly handles back/forward enhanced navigation.

## Preserve client-managed DOM

Enhanced navigation may replace DOM changes that weren't in the server response. Mark an element whose contents are exclusively managed by JavaScript with `data-permanent`:

```html
<div id="map" data-permanent></div>
```

Use this narrowly. Permanent elements aren't updated from later server responses, so stale attributes or content can remain. A `MutationObserver` is useful when a script must react to a particular element being inserted or removed.

## Disable enhancement when necessary

If a third-party script requires a complete document load, disable enhanced navigation for the affected link:

```html
<a href="reports" data-enhance-nav="false">Reports</a>
```

This trades the faster same-document navigation for predictable browser initialization.

## Additional resources

- [JavaScript with Static SSR](https://learn.microsoft.com/aspnet/core/blazor/javascript-interoperability/static-server-rendering?view=aspnetcore-10.0)
- [JavaScript initializers](https://learn.microsoft.com/aspnet/core/blazor/fundamentals/startup?view=aspnetcore-10.0#javascript-initializers)

