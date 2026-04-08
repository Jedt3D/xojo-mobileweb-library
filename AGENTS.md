# Repository Guidelines

## Project Structure & Module Organization

This repository contains two types of projects:

### MobileWeb Library (`XojoMobileWeb/`)

The primary active project — a library of mobile-first WebSDK controls:

- `XojoMobileWeb/MobileWeb/` — Library root containing all controls
  - `MobileTheme.xojo_code` — Module: shared CSS design tokens (single config point)
  - `Toggle.xojo_code` — Visual control: iOS/Android toggle switch
- `XojoMobileWeb/MainWebPage.xojo_code` — Demo page for testing controls
- `XojoMobileWeb/XojoMobileWeb.xojo_project` — Project file with Library registration

New controls are added inside `MobileWeb/` and registered in the `.xojo_project` with parent ID `&h000000000087A7FF` (the MobileWeb library ID).

### WebSDK Examples (`Examples/`)

Reference implementations and learning samples:

- `Examples/SDK Examples/` — Bare WebSDK templates
- `Examples/Callback Example/` — Browser-to-Xojo callbacks
- `Examples/Gravatar/` — Visual WebSDK control
- `Examples/Bootstrap Toast/` — TypeScript-backed non-visual control
- `Examples/WebListBox Cell Renderers/` — Custom listbox renderers
- `ChipsClaude/` — Chips & Chex controls (reference implementation for MobileWeb)

### Reference Documents

- `Building-WebSDK-Controls.md` — WebSDK development guide (gotchas, patterns)
- `xojo-mobile-web-controls.md` — MobileWeb project proposal and specs
- `mobile-web-01.md`, `mobile-web-02.md`, `mobile-web-03.md` — Research documents

## Build, Test, and Development Commands

- Open `XojoMobileWeb/XojoMobileWeb.xojo_project` in Xojo IDE 2025r3.1+ and run
- For examples: open individual `.xojo_project` files and run independently
- TypeScript compilation (Bootstrap Toast): `cd "Examples/Bootstrap Toast/typescript" && npm install && npx tsc`

No repository-wide build script or automated test runner. Validate by running in the Xojo IDE and testing in browser.

## Coding Style & Naming Conventions

### Xojo Code

- Preserve text-project formatting and `#tag` structure exactly
- One main class per `.xojo_code` file
- PascalCase class names: `Toggle`, `MobileTheme`, `SegmentedControl`
- Private backing fields: `mPropertyName` prefix
- Computed properties call `UpdateControl` in setters
- WebFile property order: Data → Session → Filename → MIMEType (wrong order = silent failure)

### MobileWeb Controls

- JS namespace: `MobileWeb` (e.g., `MobileWeb.Toggle`)
- CSS prefix: `mobile-` with BEM naming: `.mobile-{control}__{element}.is-{state}`
- CSS uses `var(--mobile-*)` tokens only — no hardcoded colors/sizes
- CSS wrapped in `@layer mobile-components`
- Theme tokens in `@layer mobile-tokens`
- All controls call `MobileTheme.EnsureThemeFile()` in `SessionCSSURLs`
- `super.updateControl(data)` must be LAST inside the `try` block in JS
- Root DOMElement gets `position: relative`; content goes in child elements

### JavaScript/TypeScript

- Browser-side class names must match `JavaScriptClassName()` values exactly
- IIFE wrapping for namespace isolation
- `try/catch` in `updateControl` body
- No `this.setAttributes()` calls (silently kills control)

## Testing Guidelines

No automated tests. Validate changes by:

1. Running the affected Xojo project in the IDE
2. Testing in desktop browser (Chrome DevTools → mobile simulation)
3. Testing on actual mobile browser (iOS Safari, Android Chrome)
4. Verifying: control renders, interactions work, events fire back to Xojo

### MobileWeb Control Checklist

- [ ] Control appears in IDE toolbox
- [ ] IDE preview renders via `DrawControlInLayoutEditor`
- [ ] Inspector shows expected properties
- [ ] Build succeeds without errors
- [ ] Control renders in browser
- [ ] Interactions work (tap, toggle, select)
- [ ] Events fire back to Xojo
- [ ] Enabled/Disabled state works
- [ ] Touch targets are at least 44px

## Commit & Pull Request Guidelines

Use short imperative messages scoped to the component:

- `mobileweb: add Toggle control with theme tokens`
- `mobileweb: fix super.updateControl placement in Toggle JS`
- `examples: fix hide-at command parsing in bootstrap toast`

Pull requests should include:

- A short summary of the affected component(s)
- The rationale for the change
- Manual verification steps
- Screenshots for visible UI changes
