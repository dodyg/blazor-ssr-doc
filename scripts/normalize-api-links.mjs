#!/usr/bin/env node

import { readFileSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";

const files = execFileSync("rg", ["--files", "-g", "*.md"], { encoding: "utf8" })
    .trim()
    .split("\n")
    .filter(Boolean)
    .filter((file) => !["PLAN.md", "PROJECT-SUMMARY.md", "QUICKSTART.md"].includes(file));

const apiLink = /\[([^\]\n]+)\]\((https:\/\/learn\.microsoft\.com\/dotnet\/api\/[^)]+)\)/g;
const qualifiedName = /(?:Microsoft|System)(?:\.[A-Za-z_][A-Za-z0-9_`?]*)+/;
const namespaceNames = new Map([
    ["microsoft.aspnetcore.localization", "Microsoft.AspNetCore.Localization"],
    ["microsoft.aspnetcore.mvc", "Microsoft.AspNetCore.Mvc"],
    ["microsoft.extensions.fileproviders", "Microsoft.Extensions.FileProviders"],
    ["microsoft.extensions.localization", "Microsoft.Extensions.Localization"],
    ["microsoft.jsinterop", "Microsoft.JSInterop"],
    ["system.componentmodel.dataannotations", "System.ComponentModel.DataAnnotations"],
    ["system.globalization", "System.Globalization"],
]);
let changedFiles = 0;
let shortenedLinks = 0;
let convertedXrefs = 0;

function shortApiName(label, url) {
    const cleanLabel = label
        .replace(/\s*\*(?:\?displayProperty=[A-Za-z]+)?/gi, "")
        .replace(/\?displayProperty(?:=[A-Za-z]+)?/gi, "");
    const uid = new URL(url).pathname.split("/").pop().toLowerCase();
    if (namespaceNames.has(uid)) return namespaceNames.get(uid);

    const match = cleanLabel.match(qualifiedName);
    if (!match) return replaceGenericArity(cleanLabel);

    const qualified = match[0]
        .replace(/[,*]$/, "");
    const parts = qualified.split(".");
    const isMember = /%2a/i.test(url) || /\s\*/.test(label) || /displayProperty=nameWithType/i.test(label);
    const selected = parts.slice(isMember ? -2 : -1).join(".");
    const display = replaceGenericArity(selected);

    shortenedLinks++;
    return display;
}

function replaceGenericArity(value) {
    return value.replace(/`(\d+)/g, (_, arity) => {
        const count = Number(arity);
        const parameters = count === 1
            ? "TValue"
            : Array.from({ length: count }, (__, index) => `T${index + 1}`).join(", ");
        return `&lt;${parameters}&gt;`;
    });
}

for (const file of files) {
    const original = readFileSync(file, "utf8");
    let updated = original.replace(apiLink, (_, label, url) => `[${shortApiName(label, url)}](${url})`);

    updated = updated.replace(/\]\(xref:([A-Za-z0-9_.`]+)\)/g, (_, uid) => {
        convertedXrefs++;
        return `](https://learn.microsoft.com/dotnet/api/${uid.toLowerCase().replace(/`/g, "%60")})`;
    });

    if (updated !== original) {
        writeFileSync(file, updated);
        changedFiles++;
    }
}

console.log(`Normalized ${shortenedLinks} API labels and ${convertedXrefs} xrefs in ${changedFiles} files.`);
