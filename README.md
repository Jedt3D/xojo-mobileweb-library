# Xojo WebSDK Repository

A collection of **Xojo WebSDK examples** and the **MobileWeb** control library — mobile-first custom controls for Xojo Web 2.0 applications.

## Repository Structure

```
WebSDK/
├── XojoMobileWeb/                  ← MobileWeb library + demo project
│   ├── XojoMobileWeb.xojo_project
│   ├── MobileWeb/                  ← Library: mobile-first controls
│   │   ├── MobileTheme.xojo_code  ← Shared CSS design tokens
│   │   └── Toggle.xojo_code       ← iOS/Android-style toggle switch
│   ├── MainWebPage.xojo_code      ← Demo page with Toggle
│   ├── App.xojo_code
│   └── Session.xojo_code
│
├── ChipsClaude/                    ← Chips & Chex controls (reference impl)
│   ├── Chips.xojo_code
│   ├── Chex.xojo_code
│   └── ...
│
├── Examples/                       ← WebSDK example projects
│   ├── SDK Examples/               ← Bare WebSDK templates
│   ├── Callback Example/           ← Browser-to-Xojo callbacks
│   ├── Gravatar/                   ← Visual WebSDK control
│   ├── Bootstrap Toast/            ← TypeScript-backed non-visual control
│   └── WebListBox Cell Renderers/  ← Custom listbox renderers
│
├── Building-WebSDK-Controls.md     ← WebSDK development guide
├── xojo-mobile-web-controls.md     ← MobileWeb project proposal & spec
├── mobile-web-01.md                ← Research: Ionic Framework assessment
├── mobile-web-02.md                ← Research: Mobile strategy decisions
└── mobile-web-03.md                ← Research: CSS implementation strategy
```

## MobileWeb Library

A library of mobile-first WebSDK controls that look and feel native on iOS and Android browsers. Ships as a Xojo Library (`.xojo_library`) with zero external dependencies.

### Current Controls (Phase 1)

| Control | Type | Description | Status |
|---|---|---|---|
| `MobileTheme` | Module | Shared CSS design tokens, single config point | Done |
| `Toggle` | Visual | iOS/Android-style on/off switch | Done |
| `Card` | Visual | Content card with image, header, body | Planned |
| `SegmentedControl` | Visual | iOS-style tab/filter switcher | Planned |

### Theme System

All controls share a centralized token system via `MobileTheme.ThemeCSS()`. To customize colors, fonts, spacing, or any visual property:

1. Open `MobileWeb/MobileTheme.xojo_code`
2. Edit token values in `ThemeCSS()` 
3. All controls update automatically via `var(--mobile-*)` CSS references

| To change... | Edit token |
|---|---|
| Brand color | `--mobile-primary` |
| Font family | `--mobile-font` |
| Corner radius | `--mobile-radius-md` / `--mobile-radius-lg` |
| Default spacing | `--mobile-space-md` |
| Shadow intensity | `--mobile-shadow-sm` / `-md` / `-lg` |
| Animation speed | `--mobile-duration-normal` |

Dark mode is automatic via `@media (prefers-color-scheme: dark)`.

### Quick Start

1. Open `XojoMobileWeb/XojoMobileWeb.xojo_project` in Xojo IDE 2025r3.1+
2. Drag `Toggle` from the MobileWeb library onto a WebPage
3. Set properties in the Inspector (`IsOn`, `Label`, `LabelPosition`)
4. Handle the `Toggled(value As Boolean)` event
5. Run and test in browser

## WebSDK Examples

The `Examples/` folder contains independent sample projects demonstrating WebSDK patterns. See each project's source for details.

### Recommended Learning Order

1. **SDK Examples** — WebSDK lifecycle surface
2. **Callback Example** — Browser-to-server event flow
3. **Gravatar** — Full visual control with property-driven updates
4. **Bootstrap Toast** — Command-queue pattern + TypeScript
5. **Color Cell** — Minimum listbox cell renderer
6. **Button Cell** — Interactive listbox cells with server callbacks

## Reference Documents

| Document | Purpose |
|---|---|
| `Building-WebSDK-Controls.md` | Battle-tested WebSDK development guide |
| `xojo-mobile-web-controls.md` | MobileWeb project proposal, specs, and roadmap |
| `mobile-web-01.md` | Ionic Framework porting feasibility research |
| `mobile-web-02.md` | Mobile strategy: 6 key architecture decisions |
| `mobile-web-03.md` | CSS strategy: tokens, layers, BEM naming |

## Requirements

- Xojo 2025r3.1 or later
- macOS, Windows, or Linux for development
- Any modern browser for testing (Safari, Chrome, Firefox)
