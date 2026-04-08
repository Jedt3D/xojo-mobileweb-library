# Xojo WebSDK Text-Format String Constant Errors

Two errors occurred when building the Chips control in `ChipsClaude/`:

## Error 1: "Missing Files — Unable to open project correctly" (Screenshot Error)

**Symptom:** Xojo IDE shows a "Missing Files" dialog saying `Chips.xojo_code` "could not be located or opened properly." The file exists but Xojo's text-project parser rejects it entirely.

**Root cause:** The `#tag Constant` string delimiters were wrong. In Xojo text-project format, string constants use **asymmetric delimiters**:

- Opening: `\"` (backslash + double-quote)
- Closing: `"` (bare double-quote, NO backslash)

```
Default = \"content here", Scope = Private   ← CORRECT
Default = \"content here\", Scope = Private  ← WRONG (what we had)
```

Verified by comparing raw bytes (xxd) against working examples: BootstrapToast closes with `0x22` (`"`), while our file closed with `0x5c 0x22` (`\"`).

**Why:** The Xojo text-project parser detects the first bare `"` (not preceded by `\`) in the constant content as the string terminator. A `\"` closing delimiter is treated as an internal escaped quote + whatever follows, causing the parser to never find the end of the string.

**How to apply:** When writing `#tag Constant` values in `.xojo_code` files, always use `\"` to open and `"` to close.

## Error 2: "Can't find a type with this name" (Compile Error)

**Symptom:** Xojo IDE shows compile errors: `WebPage1.Chips1.Name Layout (property name) Can't find a type with this name`.

**Root cause:** This was a cascading failure from Error 1. Because `Chips.xojo_code` could not be parsed at all, the `Chips` class type was never loaded. This caused `WebPage1` (which instantiates a `Chips` control as `Chips1`) to fail with "can't find a type" — the type doesn't exist because its source file couldn't be read.

**Why:** Xojo loads all referenced `.xojo_code` files when opening a project. If any file fails to parse, the types defined in that file are missing, and any other file that references those types produces compile errors.

**How to apply:** When seeing "Can't find a type" errors for a WebSDK control, first check if the control's `.xojo_code` file can be parsed. The type resolution error is often a symptom, not the root cause.

## Key Xojo Text-Format Escaping Rules (from working examples)

Learned by studying `BootstrapToast.xojo_code` and `Gravatar.xojo_code`:

| Escape | Meaning | Example |
|--------|---------|---------|
| `\n` | Newline | Line breaks in multiline constants |
| `\"` (inside content) | Literal `"` character | `\"use strict\"` → `"use strict"` |
| `\'` | Literal `'` character | `\'toast-header\'` → `'toast-header'` |
| `\x3D` | Literal `=` character | `\x3D\x3D\x3D` → `===` |
| `\"` (at start) | Opening string delimiter | `Default = \"content` |
| `"` (at end) | Closing string delimiter | `content", Scope = Private` |

**Best practice for embedding JavaScript:** Use single quotes (`\'`) for JS string literals and `\x3D` for `=` signs, matching the BootstrapToast pattern. This avoids ambiguity between `\"` as delimiter vs. escape.
