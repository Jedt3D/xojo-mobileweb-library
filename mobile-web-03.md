# Mobile Web Research 03: CSS Implementation Strategy

**Date:** 2025-04-08  
**Context:** Following the strategy report (mobile-web-02.md), this report dives deep into the CSS implementation — designing in Figma, building an independent theme system, evaluating CSS frameworks, and defining the production pipeline.

---

## 1. The Constraint: Coexisting with Xojo's Bootstrap 5.3

Xojo Web 2.0 injects Bootstrap 5.3 into every page for its built-in controls (WebButton, WebTextField, etc.). This CSS is:

- **Un-layered** — injected directly, no `@layer` wrapper
- **Uses `--bs-*` CSS custom properties** at `:root` level
- **Uses Bootstrap class names** (`.btn`, `.form-control`, etc.)
- **Not under your control** — you cannot modify how Xojo loads it

Your WebSDK controls use **separate CSS** delivered via `SharedCSSFile`. Looking at the existing Chips control:

```css
/* Current pattern: BEM-like class names, zero Bootstrap dependency */
.xojo-chips__chip {
  display: inline-flex;
  align-items: center;
  padding: 6px 14px;
  border: 1px solid #cbd5e1;
  border-radius: 999px;
  font-size: 16px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  /* ... */
}
```

**Key insight:** WebSDK CSS is already isolated by class naming convention. No Bootstrap conflict exists today, and none needs to exist in the future — as long as you keep using scoped class names (never style bare elements like `button`, `input`, `a`).

---

## 2. CSS Framework Evaluation

### Option A: Tailwind CSS v4

| Aspect | Detail |
|---|---|
| **What it is** | Utility-first CSS framework, v4 released Jan 2025 |
| **CDN (dev)** | `<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>` |
| **CLI (prod)** | `npx @tailwindcss/cli -i input.css -o output.css` |
| **Config** | CSS-first via `@theme` directive (no more `tailwind.config.js`) |
| **Figma integration** | Community plugins only, no official |
| **Theming** | Excellent — `@theme` generates CSS custom properties automatically |
| **Bootstrap conflict** | Preflight resets will break Bootstrap. Must disable or prefix |

**v4 CSS-first configuration:**
```css
@import "tailwindcss";
@theme {
  --color-primary: #1d4ed8;
  --color-surface: #f8fafc;
  --radius-full: 9999px;
  --spacing-sm: 0.5rem;
}
```

**Pros:** Rapid prototyping, huge community, design-to-code speed  
**Cons:** Requires build step for production, Preflight conflicts, utility classes in JS strings are harder to maintain than semantic classes

**Bootstrap coexistence:** Viable with these precautions:
1. Disable Preflight (don't import `tailwindcss/preflight`)
2. Use prefix option (e.g., `tw-`) to namespace all classes
3. Wrap in `@layer` for cascade control
4. For production, extract to plain CSS in SharedCSSFile (remove Tailwind dependency)

**Verdict:** Good for rapid development/prototyping. The build step and Preflight management add friction. Best used as a development tool, not a production dependency.

---

### Option B: Open Props (Recommended for Tokens)

| Aspect | Detail |
|---|---|
| **What it is** | CSS custom properties library by Adam Argyle (Google Chrome team) |
| **CDN** | `<link rel="stylesheet" href="https://unpkg.com/open-props">` |
| **npm** | `npm install open-props` |
| **Build step** | None required (optional PostCSS tree-shaking) |
| **Figma integration** | Figma token kit available from project website |
| **Theming** | Pure CSS custom properties — override at any scope |
| **Bootstrap conflict** | **Zero** — only declares `--` variables, no classes, no element styles |

**What Open Props provides:**
```css
/* Pre-defined design tokens as CSS custom properties */
--blue-0: #d0ebff;
--blue-6: #228be6;
--blue-9: #1864ab;
--gray-0: #f8f9fa;
--gray-5: #adb5bd;
--size-1: 0.25rem;
--size-3: 1rem;
--size-5: 1.5rem;
--shadow-2: 0 1px 2px 0 rgba(0,0,0,0.05);
--radius-2: 0.5rem;
--radius-round: 1e5px;
--font-sans: system-ui, -apple-system, sans-serif;
--ease-3: cubic-bezier(0.25, 0, 0.3, 1);
--animation-fade-in: fade-in 0.5s var(--ease-3);
```

**How you'd use it in WebSDK:**
```css
.mobile-toggle__track {
  background: var(--gray-2);
  border-radius: var(--radius-round);
  padding: var(--size-1);
  transition: background var(--ease-3) 0.2s;
}
.mobile-toggle__track.is-on {
  background: var(--blue-6);
}
```

**Pros:** Zero conflict with Bootstrap, zero build step, systematic scale system, tiny footprint, battle-tested tokens from a browser engineer  
**Cons:** No utility classes (you write your own CSS), no Figma plugin (but has a Figma kit), smaller community than Tailwind

**Verdict:** Best foundation for design tokens. Use these as the base values in your theme, override for custom branding. Zero risk of Bootstrap conflicts.

---

### Option C: Bootstrap 5.3 Custom Build (Scoped)

| Aspect | Detail |
|---|---|
| **What it is** | Your own Bootstrap build with different variable prefix |
| **Build step** | SASS compilation required |
| **Key feature** | `$prefix: "my-"` changes all `--bs-*` to `--my-*` |
| **Scoping** | Wrap in `.my-scope { @import "bootstrap"; }` |
| **Figma integration** | Many Bootstrap Figma kits available |
| **Bootstrap conflict** | Managed via prefix and scoping, but still risky |

**How prefix scoping works:**
```scss
// Your custom Bootstrap build
$prefix: "mobile-";        // Changes --bs-primary to --mobile-primary
$primary: #1d4ed8;
$border-radius: 0.75rem;

.mobile-scope {
  @import "bootstrap/scss/bootstrap";
}
```

**Pros:** Familiar system, rich component library, lots of Figma kits  
**Cons:** SASS build required, large output even with tree-shaking, risk of specificity battles with Xojo's Bootstrap, maintaining two Bootstrap versions is fragile

**Verdict:** Too risky. Running two Bootstrap instances on one page — even with different prefixes — creates maintenance headaches and subtle specificity conflicts. Not recommended.

---

### Option D: Pico CSS

| Aspect | Detail |
|---|---|
| **What it is** | Minimal, classless-first CSS framework |
| **CDN** | `<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">` |
| **Build step** | None |
| **Bootstrap conflict** | **High** — styles bare HTML elements directly |

**Verdict:** Not suitable. Classless approach fundamentally conflicts with Bootstrap's element-level styling. Even the scoped (`conditional`) build would fight Bootstrap on shared elements.

---

### Option E: Vanilla Extract (Build-time CSS-in-TypeScript)

| Aspect | Detail |
|---|---|
| **What it is** | Zero-runtime CSS-in-TypeScript, extracts to static CSS |
| **Build step** | Mandatory (Vite/Webpack/esbuild) |
| **Output** | Hashed, scoped class names — zero conflicts |
| **Bootstrap conflict** | **Zero** — all class names are locally scoped |

**Verdict:** Excellent isolation but requires a TypeScript/build toolchain that doesn't fit Xojo WebSDK's delivery model (CSS is a string in SharedCSSFile). Not practical for this context.

---

### Option F: Vanilla CSS Custom Properties + @layer (Recommended)

| Aspect | Detail |
|---|---|
| **What it is** | Hand-authored CSS using your own design tokens |
| **Build step** | Optional (CLI for minification only) |
| **Figma integration** | Design tokens exported as CSS custom properties |
| **Bootstrap conflict** | **Zero** — fully scoped by class names + @layer |

This is the approach the Chips/Chex controls already use, but elevated to a systematic theme:

```css
/* 1. Layer declaration for cascade control */
@layer mobile-tokens, mobile-components;

/* 2. Design tokens layer */
@layer mobile-tokens {
  :root {
    /* Colors */
    --mobile-primary: #1d4ed8;
    --mobile-primary-hover: #1e40af;
    --mobile-on-primary: #ffffff;
    --mobile-surface: #f8fafc;
    --mobile-surface-hover: #f1f5f9;
    --mobile-border: #cbd5e1;
    --mobile-text: #0f172a;
    --mobile-text-secondary: #64748b;
    --mobile-disabled-opacity: 0.5;

    /* Spacing */
    --mobile-space-xs: 0.25rem;
    --mobile-space-sm: 0.5rem;
    --mobile-space-md: 1rem;
    --mobile-space-lg: 1.5rem;
    --mobile-space-xl: 2rem;

    /* Typography */
    --mobile-font: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    --mobile-text-sm: 0.875rem;
    --mobile-text-base: 1rem;
    --mobile-text-lg: 1.125rem;

    /* Shape */
    --mobile-radius-sm: 0.25rem;
    --mobile-radius-md: 0.5rem;
    --mobile-radius-lg: 0.75rem;
    --mobile-radius-full: 9999px;

    /* Shadows */
    --mobile-shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
    --mobile-shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1);

    /* Motion */
    --mobile-ease: cubic-bezier(0.25, 0, 0.3, 1);
    --mobile-duration-fast: 0.15s;
    --mobile-duration-normal: 0.2s;

    /* Touch */
    --mobile-tap-size: 44px;  /* Apple HIG minimum */
    --mobile-tap-highlight: rgba(0,0,0,0.05);
  }
}

/* 3. Component layer */
@layer mobile-components {
  .mobile-toggle__track {
    display: flex;
    align-items: center;
    width: 52px;
    height: 32px;
    background: var(--mobile-border);
    border-radius: var(--mobile-radius-full);
    padding: 2px;
    cursor: pointer;
    transition: background var(--mobile-duration-normal) var(--mobile-ease);
  }
  .mobile-toggle__track.is-on {
    background: var(--mobile-primary);
  }
  /* ... */
}
```

**Why @layer matters here:**

```
Cascade Priority (lowest → highest):
┌─────────────────────────────────┐
│ @layer mobile-tokens            │  ← Your design tokens
│ @layer mobile-components        │  ← Your component styles
│ (un-layered: Xojo Bootstrap)    │  ← Bootstrap always wins on bare elements
└─────────────────────────────────┘
```

Since your WebSDK controls use scoped class names (`.mobile-toggle__track`), Bootstrap never targets them. The layers give you internal cascade control between your own tokens and components, while Bootstrap remains untouched in the un-layered space.

**Pros:** Zero dependencies, zero build step, zero conflicts, full control, matches existing Chips/Chex pattern, works with SharedCSSFile delivery  
**Cons:** More manual CSS authoring (no utility classes), requires discipline in naming

**Verdict:** The natural evolution of what you're already doing. Add systematic tokens and @layer for organization.

---

## 3. Comparison Matrix

| Criteria | Tailwind v4 | Open Props | Bootstrap Custom | Pico | Vanilla Extract | Vanilla CSS + @layer |
|---|---|---|---|---|---|---|
| **Zero Bootstrap conflict** | Needs config | **Yes** | Risky | No | Yes | **Yes** |
| **No build step** | Dev only | **Yes** | No | Yes | No | **Yes** |
| **Figma workflow** | Community | Token kit | Many kits | None | Via pipeline | Manual/pipeline |
| **Theming** | Excellent | **Excellent** | Excellent | Good | Excellent | **Excellent** |
| **SharedCSSFile compatible** | Extracted only | **Yes** | Extracted only | Yes | No | **Yes** |
| **Learning curve** | Medium | **Low** | Low | Low | High | **Low** |
| **Community/ecosystem** | **Huge** | Growing | **Huge** | Small | Medium | Universal |
| **Runtime dependency** | CDN or build | CDN or copy | SASS build | CDN | Build | **None** |

---

## 4. Recommended Approach: Layered Architecture

```
┌──────────────────────────────────────────────────────┐
│                 Design (Figma)                        │
│  Design tokens → Colors, spacing, typography, shape   │
│  Component designs → Visual specs for each control    │
└────────────────────────┬─────────────────────────────┘
                         │ Export
                         ▼
┌──────────────────────────────────────────────────────┐
│              Token Pipeline (optional CLI)            │
│  Option A: Tokens Studio → Style Dictionary → CSS     │
│  Option B: Figma Variables API → Node script → CSS    │
│  Option C: Manual → CSS custom properties file        │
└────────────────────────┬─────────────────────────────┘
                         │ CSS file
                         ▼
┌──────────────────────────────────────────────────────┐
│              Theme File (mobile-theme.css)            │
│  @layer mobile-tokens {                               │
│    :root { --mobile-primary: ...; }                   │
│  }                                                    │
│  Can be swapped for different brands/themes           │
└────────────────────────┬─────────────────────────────┘
                         │ Imported by
                         ▼
┌──────────────────────────────────────────────────────┐
│           Component CSS (per control)                 │
│  @layer mobile-components {                           │
│    .mobile-toggle__track { ... }                      │
│    .mobile-card__header { ... }                       │
│  }                                                    │
│  Uses var(--mobile-*) tokens everywhere               │
└────────────────────────┬─────────────────────────────┘
                         │ Delivered via
                         ▼
┌──────────────────────────────────────────────────────┐
│           Xojo WebSDK (SharedCSSFile)                 │
│  SharedCSSFile.Data = themeCSS + componentCSS         │
│  SharedCSSFile.Session = Nil                          │
│  SharedCSSFile.Filename = "mobile-controls.css"       │
│  SharedCSSFile.MIMEType = "text/css"                  │
└──────────────────────────────────────────────────────┘
```

### Two Tiers of Adoption

**Tier 1 — Start Simple (no CLI, no build tools)**
- Define design tokens manually as CSS custom properties
- Use Open Props as a reference for naming and scale systems
- Author component CSS by hand using tokens
- Inline everything in SharedCSSFile.Data
- Figma Inspect panel for visual reference values

**Tier 2 — Scale Up (optional CLI workflow)**
- Use Tokens Studio in Figma for token management
- Export tokens to Git as JSON
- Style Dictionary transforms JSON → CSS custom properties file
- Lightning CSS minifies the final output
- A simple shell script or `Makefile` chains the steps:

```bash
#!/bin/bash
# build-css.sh — runs outside Xojo, output is a CSS string for SharedCSSFile

# 1. Transform tokens to CSS (if using Style Dictionary)
npx style-dictionary build

# 2. Concatenate theme + components
cat src/tokens.css src/components/*.css > dist/mobile-controls.css

# 3. Minify
npx lightningcss --minify dist/mobile-controls.css -o dist/mobile-controls.min.css

# 4. Output for copy-paste into Xojo SharedCSSFile.Data
echo "Done. Copy contents of dist/mobile-controls.min.css into SharedCSSFile.Data"
```

---

## 5. Figma → CSS Workflow

### What Figma Gives You Natively

The Inspect panel / Dev Mode exports CSS per element:
- Box model (width, height, padding) in `px`
- Colors as hex/rgba (resolved values, not token references)
- Typography properties
- Auto Layout → Flexbox (`display: flex`, `gap`, `align-items`)
- Shadows, borders, border-radius

**What it does NOT give you:**
- CSS custom property references (always literal values)
- Pseudo-class states (`:hover`, `:active`, `:focus`, `:disabled`)
- Responsive breakpoints or media queries
- Animations or transitions
- Semantic class names
- Relative units (`rem`, `em`, `%`)

### Recommended Pipeline

**For this project, use a hybrid approach:**

```
Step 1: Design in Figma
├── Define color palette, spacing scale, type scale as Figma Variables
├── Design each component state (default, hover, active, disabled, selected)
└── Use Auto Layout for all components (maps to flexbox)

Step 2: Extract Design Tokens
├── Option A (simple): Read values from Figma Inspect, write CSS vars manually
├── Option B (scalable): Use Tokens Studio plugin → export JSON → Style Dictionary → CSS
└── Option C (API): Figma Variables REST API → Node script → CSS

Step 3: Author Component CSS
├── Reference Figma specs for exact values
├── Use var(--mobile-*) tokens instead of literal values
├── Add states (:hover, :active, .is-selected, .is-disabled)
├── Add transitions (var(--mobile-duration-*), var(--mobile-ease))
└── Convert px to rem where appropriate (font sizes, spacing)

Step 4: Deliver via SharedCSSFile
├── Concatenate theme tokens + component CSS
├── Optionally minify with Lightning CSS
└── Inline as SharedCSSFile.Data string in Xojo
```

### Tokens Studio → Style Dictionary Pipeline (Detail)

For teams ready for an automated pipeline:

```
Figma
  └── Tokens Studio plugin
      ├── Manage tokens (colors, spacing, typography, radii, shadows)
      ├── Support multiple themes (light/dark, brand variants)
      └── Sync to Git repository (tokens/*.json)

Git Repository
  └── tokens/
      ├── global.json          ← primitive values
      ├── semantic-light.json  ← light theme mappings
      └── semantic-dark.json   ← dark theme mappings

Style Dictionary (config.json)
  └── Transforms JSON → CSS custom properties
      └── Output: src/generated/tokens.css

Build Script
  └── cat tokens.css + components/*.css → mobile-controls.css
  └── lightningcss --minify → mobile-controls.min.css

Xojo
  └── SharedCSSFile.Data = ReadFile("mobile-controls.min.css")
```

**Tokens Studio export format (JSON):**
```json
{
  "color": {
    "primary": {
      "$value": "#1d4ed8",
      "$type": "color"
    },
    "surface": {
      "$value": "#f8fafc",
      "$type": "color"
    }
  },
  "spacing": {
    "sm": {
      "$value": "0.5rem",
      "$type": "dimension"
    }
  }
}
```

**Style Dictionary output (CSS):**
```css
:root {
  --mobile-color-primary: #1d4ed8;
  --mobile-color-surface: #f8fafc;
  --mobile-spacing-sm: 0.5rem;
}
```

---

## 6. Theme System Design

### Token Categories

A complete mobile theme needs these token categories:

| Category | Tokens | Example |
|---|---|---|
| **Color — Primitive** | Named color scale | `--mobile-blue-500: #3b82f6` |
| **Color — Semantic** | Purpose-based aliases | `--mobile-primary: var(--mobile-blue-500)` |
| **Color — Component** | Control-specific | `--mobile-toggle-bg: var(--mobile-surface)` |
| **Spacing** | Consistent scale | `--mobile-space-1` through `--mobile-space-9` |
| **Typography** | Font families, sizes, weights | `--mobile-text-sm`, `--mobile-font-bold` |
| **Shape** | Border radii | `--mobile-radius-sm` through `--mobile-radius-full` |
| **Elevation** | Shadows | `--mobile-shadow-1` through `--mobile-shadow-5` |
| **Motion** | Duration, easing | `--mobile-ease`, `--mobile-duration-fast` |
| **Touch** | Minimum targets, feedback | `--mobile-tap-size: 44px` |

### Three-Layer Token Architecture

```
┌──────────────────────────────────────┐
│  Primitive Tokens                    │  Raw values, named by appearance
│  --mobile-blue-500: #3b82f6          │  --mobile-gray-100: #f1f5f9
│  --mobile-size-4: 1rem               │  --mobile-size-6: 1.5rem
└──────────────┬───────────────────────┘
               │ referenced by
               ▼
┌──────────────────────────────────────┐
│  Semantic Tokens                     │  Named by purpose, theme-switchable
│  --mobile-primary: var(--blue-500)   │  --mobile-surface: var(--gray-50)
│  --mobile-text: var(--gray-900)      │  --mobile-border: var(--gray-300)
└──────────────┬───────────────────────┘
               │ referenced by
               ▼
┌──────────────────────────────────────┐
│  Component Tokens                    │  Named by control + property
│  --mobile-toggle-bg: var(--surface)  │  --mobile-card-radius: var(--radius-lg)
│  --mobile-list-divider: var(--border)│ --mobile-fab-shadow: var(--shadow-md)
└──────────────────────────────────────┘
```

**Why three layers?**
- Change a primitive → all semantics using it update
- Swap a semantic theme (dark mode) → all components adapt
- Override a component token → one control customized without affecting others

### Dark Mode Support

```css
/* Light theme (default) */
:root {
  --mobile-primary: #1d4ed8;
  --mobile-surface: #f8fafc;
  --mobile-text: #0f172a;
  --mobile-border: #cbd5e1;
}

/* Dark theme */
@media (prefers-color-scheme: dark) {
  :root {
    --mobile-primary: #60a5fa;
    --mobile-surface: #1e293b;
    --mobile-text: #f1f5f9;
    --mobile-border: #475569;
  }
}

/* Or class-based override */
.mobile-theme-dark {
  --mobile-primary: #60a5fa;
  --mobile-surface: #1e293b;
  --mobile-text: #f1f5f9;
  --mobile-border: #475569;
}
```

Component CSS doesn't change — it always uses `var(--mobile-*)`. Only the token values switch.

### Brand Customization

```css
/* Default brand */
:root {
  --mobile-primary: #1d4ed8;
  --mobile-primary-hover: #1e40af;
}

/* Custom brand override (user provides in SessionHead) */
.brand-acme {
  --mobile-primary: #dc2626;
  --mobile-primary-hover: #b91c1c;
}
```

---

## 7. CSS Naming Convention (BEM for WebSDK)

All mobile controls use BEM-like naming with the `mobile-` prefix:

```
.mobile-{control}__{element}
.mobile-{control}__{element}.is-{state}
.mobile-{control}.has-{feature}
```

**Examples:**
```css
/* Toggle */
.mobile-toggle                          /* block */
.mobile-toggle__track                   /* element */
.mobile-toggle__thumb                   /* element */
.mobile-toggle__track.is-on             /* state */
.mobile-toggle__track.is-disabled       /* state */

/* Card */
.mobile-card                            /* block */
.mobile-card__header                    /* element */
.mobile-card__body                      /* element */
.mobile-card__image                     /* element */
.mobile-card.has-shadow                 /* modifier */

/* List */
.mobile-list                            /* block */
.mobile-list__item                      /* element */
.mobile-list__item-icon                 /* element */
.mobile-list__item-label                /* element */
.mobile-list__item.is-active            /* state */
.mobile-list__divider                   /* element */
```

**Rules:**
1. Always prefix with `mobile-` (no collision with `xojo-chips__*` or Bootstrap classes)
2. Double underscore `__` separates block from element
3. State classes use `is-` or `has-` prefix
4. Never style bare HTML elements — always use class selectors
5. Keep specificity flat (one class selector, no nesting beyond state)

---

## 8. Touch-First CSS Patterns

Every mobile component needs these CSS foundations:

### Minimum Tap Target (44px, Apple HIG)
```css
.mobile-list__item {
  min-height: var(--mobile-tap-size);   /* 44px */
  padding: var(--mobile-space-sm) var(--mobile-space-md);
}
```

### Touch Feedback
```css
.mobile-list__item {
  -webkit-tap-highlight-color: transparent;
  transition: background var(--mobile-duration-fast) var(--mobile-ease);
}
.mobile-list__item:active {
  background: var(--mobile-tap-highlight);
}
```

### No Text Selection on Interactive Elements
```css
.mobile-toggle,
.mobile-segment__button,
.mobile-chip {
  user-select: none;
  -webkit-user-select: none;
}
```

### Safe Area (Notch) Support
```css
.mobile-tab-bar {
  padding-bottom: env(safe-area-inset-bottom);
}
.mobile-toolbar {
  padding-top: env(safe-area-inset-top);
}
```

### Smooth Scrolling (Lists)
```css
.mobile-list {
  -webkit-overflow-scrolling: touch;
  overscroll-behavior: contain;
}
```

### Prevent Pull-to-Refresh Interference
```css
.mobile-bottom-sheet {
  overscroll-behavior: none;
  touch-action: pan-y;
}
```

---

## 9. CSS Delivery in WebSDK

### Current Pattern (Chips/Chex)
Each control has its own `SharedCSSFile` with CSS inlined as a string:
```xojo
SharedCSSFile.Data = ".xojo-chips__list{display:flex;...}"
```

### Proposed Pattern for Mobile Controls

**Option A: Shared theme + per-control CSS (recommended)**

One shared theme file loaded once, plus per-control component CSS:

```xojo
' In a shared module (e.g., MobileTheme module)
Public Property SharedThemeFile As WebFile

Function ThemeCSS() As String
  ' Returns the token CSS string
  Return ":root{--mobile-primary:#1d4ed8;--mobile-surface:#f8fafc;...}"
End Function

' Each control loads theme + own CSS
Function SessionCSSURLs(session As WebSession) As String()
  ' Theme file (loaded once, shared across all controls)
  If MobileTheme.SharedThemeFile = Nil Then
    MobileTheme.SharedThemeFile = New WebFile
    MobileTheme.SharedThemeFile.Data = MobileTheme.ThemeCSS
    MobileTheme.SharedThemeFile.Session = Nil
    MobileTheme.SharedThemeFile.Filename = "mobile-theme.css"
    MobileTheme.SharedThemeFile.MIMEType = "text/css"
  End If

  ' Control-specific CSS
  If SharedCSSFile = Nil Then
    SharedCSSFile = New WebFile
    SharedCSSFile.Data = ".mobile-toggle__track{...}"
    SharedCSSFile.Session = Nil
    SharedCSSFile.Filename = "MobileToggle.css"
    SharedCSSFile.MIMEType = "text/css"
  End If

  Return Array(MobileTheme.SharedThemeFile.URL, SharedCSSFile.URL)
End Function
```

**Why this is better:**
- Theme tokens defined once, used by all controls
- Changing the theme updates all controls automatically
- Each control's CSS stays small and focused
- Browser caches both files independently

**Option B: Single combined file**

All CSS in one file for simpler delivery:
```xojo
SharedCSSFile.Data = themeTokens + toggleCSS + cardCSS + listCSS + ...
```

Simpler but harder to maintain as the library grows.

---

## 10. Decision Summary

| Decision | Choice | Why |
|---|---|---|
| **CSS framework** | Vanilla CSS + @layer | Zero dependencies, fits SharedCSSFile, no conflicts |
| **Design tokens source** | Open Props-inspired naming + own values | Systematic scale, proven naming conventions |
| **Token management** | Figma Variables or Tokens Studio | Designer-friendly, exportable |
| **Token pipeline** | Start manual, add Style Dictionary later | Keep it simple initially, scale when needed |
| **Build tool (optional)** | Lightning CSS for minification | Fastest, smallest output, handles modern CSS |
| **Naming convention** | BEM with `mobile-` prefix | Scoped, flat specificity, readable |
| **Theme architecture** | 3-layer tokens (primitive → semantic → component) | Supports dark mode, brand customization |
| **Delivery** | Shared theme WebFile + per-control WebFile | DRY tokens, independent component CSS |
| **Bootstrap coexistence** | Class scoping (no bare elements) + @layer | Zero conflict, proven with Chips/Chex |
| **Figma workflow** | Inspect for values, Tokens Studio for pipeline | Hybrid: manual start, automated scale-up |

### What We're NOT Using and Why

| Rejected | Reason |
|---|---|
| Tailwind in production | Build dependency, Preflight conflicts, utility classes in JS strings |
| Second Bootstrap instance | Specificity battles, double maintenance, fragile |
| Pico CSS | Element-level styling conflicts with Bootstrap |
| Vanilla Extract | Requires TypeScript build toolchain, incompatible with SharedCSSFile |
| Shadow DOM | Xojo WebSDK doesn't use Shadow DOM; no benefit, added complexity |
| CSS-in-JS | No JavaScript module system in WebSDK; CSS is delivered as static strings |

### CLI Workflow (Outside Xojo, Acceptable)

```
Project Structure:
mobile-controls/
├── tokens/
│   ├── primitives.json        ← From Figma (Tokens Studio export)
│   └── semantic.json          ← From Figma (theme mappings)
├── src/
│   ├── tokens.css             ← Generated or hand-written
│   ├── toggle.css             ← Component CSS
│   ├── card.css
│   ├── list.css
│   └── ...
├── dist/
│   └── mobile-controls.min.css  ← Final output
├── build-css.sh               ← Build script
└── style-dictionary.config.json ← Optional, for token pipeline
```

```bash
# build-css.sh
cat src/tokens.css src/*.css > dist/mobile-controls.css
npx lightningcss --minify dist/mobile-controls.css -o dist/mobile-controls.min.css
echo "Copy dist/mobile-controls.min.css contents into SharedCSSFile.Data"
```

This workflow lives outside Xojo. The output is a CSS string that gets pasted into the Xojo source code. Clean separation of concerns.
