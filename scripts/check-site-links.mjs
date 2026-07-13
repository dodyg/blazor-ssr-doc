#!/usr/bin/env node

import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, extname, join, normalize, relative, resolve, sep } from "node:path";

const root = resolve(process.argv[2] ?? ".lunet/build/www");
const basePath = (process.argv[3] ?? "/blazor-ssr-doc").replace(/\/$/, "");
const htmlFiles = [];
const failures = [];
let checked = 0;
const namespaceNames = new Set([
    "Microsoft.AspNetCore.Localization",
    "Microsoft.AspNetCore.Mvc",
    "Microsoft.Extensions.FileProviders",
    "Microsoft.Extensions.Localization",
    "Microsoft.JSInterop",
    "System.ComponentModel.DataAnnotations",
    "System.Globalization",
]);

function walk(directory) {
    for (const entry of readdirSync(directory)) {
        const path = join(directory, entry);
        if (statSync(path).isDirectory()) walk(path);
        else if (extname(path) === ".html") htmlFiles.push(path);
    }
}

function targetFile(page, pathname) {
    const decoded = decodeURIComponent(pathname);
    const localPath = decoded.startsWith("/")
        ? decoded.slice(basePath.length).replace(/^\//, "")
        : relative(root, resolve(dirname(page), decoded));
    const candidate = normalize(join(root, localPath));

    if (!candidate.startsWith(root + sep) && candidate !== root) return null;
    if (existsSync(candidate) && !statSync(candidate).isDirectory()) return candidate;
    if (existsSync(join(candidate, "index.html"))) return join(candidate, "index.html");
    if (!extname(candidate) && existsSync(candidate + ".html")) return candidate + ".html";
    return null;
}

walk(root);

for (const page of htmlFiles) {
    const html = readFileSync(page, "utf8");
    const renderedHtml = html.replace(/<!--[\s\S]*?-->/g, "");
    const references = renderedHtml.matchAll(/\b(?:href|src)=["']([^"']+)["']/gi);

    if (/xref:[A-Za-z0-9_.`]+/i.test(renderedHtml)) {
        failures.push(`${relative(root, page)}: contains an unresolved xref`);
    }

    if (/\[[^\]\n]+\]\(https?:\/\//i.test(renderedHtml)) {
        failures.push(`${relative(root, page)}: contains unrendered Markdown link syntax`);
    }

    for (const match of renderedHtml.matchAll(/<a\s+[^>]*href=["'](https:\/\/learn\.microsoft\.com\/dotnet\/api\/[^"']+)["'][^>]*>([\s\S]*?)<\/a>/gi)) {
        const label = match[2].replace(/<[^>]+>/g, "").replace(/&lt;/g, "<").replace(/&gt;/g, ">");
        if (!namespaceNames.has(label) && /(?:Microsoft|System)(?:\.[A-Z][A-Za-z0-9_`]*)+/.test(label)) {
            failures.push(`${relative(root, page)}: fully qualified API label: ${label}`);
        }
    }

    for (const [, rawReference] of references) {
        if (/^(?:https?:|mailto:|tel:|data:|javascript:)/i.test(rawReference)) continue;

        checked++;
        const [pathname, fragment] = rawReference.split("#", 2);
        if (pathname.startsWith("/") && !pathname.startsWith(basePath + "/") && pathname !== basePath) {
            failures.push(`${relative(root, page)}: escapes base path: ${rawReference}`);
            continue;
        }

        const target = pathname ? targetFile(page, pathname) : page;
        if (!target) {
            failures.push(`${relative(root, page)}: missing target: ${rawReference}`);
            continue;
        }

        if (fragment) {
            const targetHtml = readFileSync(target, "utf8");
            const escaped = fragment.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
            if (!new RegExp(`\\bid=["']${escaped}["']`).test(targetHtml)) {
                failures.push(`${relative(root, page)}: missing fragment: ${rawReference}`);
            }
        }
    }
}

if (failures.length) {
    console.error(`Link check failed with ${failures.length} error(s):`);
    for (const failure of failures) console.error(`- ${failure}`);
    process.exit(1);
}

console.log(`Checked ${checked} local links and assets across ${htmlFiles.length} HTML pages.`);
