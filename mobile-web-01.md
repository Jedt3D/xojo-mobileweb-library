# Mobile Web Research 01: Ionic Framework Porting Feasibility

**Date:** 2025-04-08  
**Question:** How hard is it to port Ionic Framework to become Xojo web UI controls (maybe plus framework)?  
**Context:** Xojo web controls are limited to desktop mostly and not touch-friendly. Some like ListBox (table) are not relevant to mobile. Modern mobile controls are lacking.

---

## Ionic Framework — What It Is

Ionic is an open-source UI toolkit (currently v8.8.3) built on Web Components (Custom Elements + Shadow DOM), compiled by Stencil.js. It provides 80+ mobile-first UI components with platform-adaptive styling (iOS and Material Design modes).

| Aspect | Detail |
|---|---|
| Core tech | Web Components (Custom Elements + Shadow DOM) |
| Compiler | Stencil.js (generates standard Web Components) |
| Dependencies | `@stencil/core`, `ionicons`, `tslib` |
| Framework requirement | **None** — works standalone from CDN |
| CDN setup | 2 JS files + 1 CSS file in `<head>` |
| Component creation | `<ion-button>` tags or `document.createElement('ion-button')` |
| Events | Standard DOM events with `ion*` prefix (`ionInput`, `ionChange`, `ionBlur`) |
| Theming | CSS custom properties (`--background`, `--color`, etc.) |
| Styling encapsulation | Shadow DOM on most components |

Standalone CDN usage:
```html
<script type="module" src="https://cdn.jsdelivr.net/npm/@ionic/core/dist/ionic/ionic.esm.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@ionic/core/css/ionic.bundle.css" />
<ion-button color="primary">Click Me</ion-button>
```

---

## Component Inventory

### High value (Xojo has nothing equivalent)

| Component | What it does |
|---|---|
| `ion-item-sliding` | Swipe-to-reveal actions (like iOS mail) |
| `ion-refresher` | Pull-to-refresh gesture |
| `ion-infinite-scroll` | Load more on scroll |
| `ion-fab` | Floating action button |
| `ion-action-sheet` | Bottom sheet with options |
| `ion-toast` | Non-intrusive notifications |
| `ion-segment` | iOS-style tab switcher |
| `ion-datetime` | Mobile-optimized date/time picker |
| `ion-range` | Touch-friendly slider |
| `ion-reorder` | Drag-to-reorder items |
| `ion-toggle` | iOS/Android-style switch |
| `ion-searchbar` | Search with clear/cancel |
| `ion-card` | Content card with image/header/body |
| `ion-modal` | Sheet-style modal with drag handles |
| `ion-skeleton-text` | Loading placeholder |

### Medium value (Xojo has something but not touch-friendly)

- `ion-list` + `ion-item` (touch-friendly list with icons, avatars, sliding)
- `ion-input` (with floating labels, validation styles)
- `ion-select` (mobile-friendly picker)
- `ion-checkbox` / `ion-radio` (larger touch targets)

### Full Ionic component list (80+)

**Navigation:** ion-nav, ion-nav-link, ion-router, ion-router-link, ion-router-outlet, ion-route, ion-route-redirect, ion-tabs, ion-tab, ion-tab-bar, ion-tab-button, ion-menu, ion-menu-button, ion-menu-toggle, ion-split-pane

**Forms & Input:** ion-input, ion-input-password-toggle, ion-input-otp, ion-textarea, ion-checkbox, ion-radio, ion-radio-group, ion-select, ion-select-option, ion-toggle, ion-range, ion-searchbar, ion-segment, ion-segment-button, ion-segment-content, ion-segment-view, ion-datetime, ion-datetime-button, ion-picker, ion-picker-column, ion-picker-column-option

**Layout & Structure:** ion-grid, ion-row, ion-col, ion-app, ion-content, ion-toolbar, ion-header, ion-footer, ion-title, ion-buttons, ion-back-button

**Data Display:** ion-card, ion-card-header, ion-card-content, ion-card-title, ion-card-subtitle, ion-list, ion-list-header, ion-item, ion-item-group, ion-item-divider, ion-item-sliding, ion-item-options, ion-item-option, ion-label, ion-note, ion-badge, ion-chip, ion-avatar, ion-img, ion-thumbnail, ion-icon, ion-breadcrumb, ion-breadcrumbs, ion-accordion, ion-accordion-group, ion-reorder, ion-reorder-group

**Feedback & Overlay:** ion-modal, ion-backdrop, ion-popover, ion-alert, ion-action-sheet, ion-toast, ion-loading, ion-progress-bar, ion-spinner, ion-skeleton-text

**Actions & Interaction:** ion-button, ion-ripple-effect, ion-fab, ion-fab-button, ion-fab-list, ion-infinite-scroll, ion-infinite-scroll-content, ion-refresher, ion-refresher-content

---

## Architecture Clash: Ionic vs Xojo WebSDK

### 1. Component Nesting (Big Problem)

Ionic components are designed to nest inside each other:
```html
<ion-list>
  <ion-item>
    <ion-label>Name</ion-label>
    <ion-input></ion-input>
  </ion-item>
</ion-list>
```

Xojo treats all controls as flat siblings on a page. No parent-child relationship in the visual designer.

**Workaround:** Each WebSDK control builds its own internal component tree programmatically from data (like Chips/Chex builds items from JSON).

### 2. Positioning Model (Medium Problem)

Xojo WebSDK uses absolute positioning. Ionic uses flow layout (flexbox, CSS grid). Wrapping flow-based components in absolutely-positioned divs can cause layout issues.

### 3. Navigation (Not Portable)

Ionic's ion-nav, ion-tabs, ion-router are fundamentally incompatible with Xojo's WebPage navigation model. Skip Ionic navigation, only use UI components.

### 4. Shadow DOM Styling (Annoying but Solvable)

Most Ionic components use Shadow DOM. Styling only via CSS custom properties or ::part() selectors.

### 5. State Synchronization (Tricky)

Ionic components manage their own internal state. Need to listen for events, forward to Xojo via triggerServerEvent, handle Xojo setting values back via updateControl, and avoid infinite update loops.

---

## Three Integration Approaches

### Approach A: Full Port (All 80+ Components) — Feasibility: 2/10
Impractical. Too many components, architecture mismatches, months of work plus ongoing maintenance.

### Approach B: "IonicView" Container — Feasibility: 4/10
One WebSDK control rendering JSON UI description. Loses visual designer, debugging painful, complex schema.

### Approach C: Cherry-Pick 10-15 Components — Feasibility: 7/10
Wrap individual high-value components as standalone WebSDK controls using proven Chips/Chex patterns. Best balance of effort vs value.

---

## Effort Estimate (Approach C)

| Component type | Example | Effort per control |
|---|---|---|
| Simple display | ion-card, ion-badge, ion-chip | 1-2 days |
| Interactive simple | ion-toggle, ion-range, ion-segment | 2-3 days |
| Interactive complex | ion-input, ion-select, ion-datetime | 3-5 days |
| Compound (list + items) | ion-list with ion-item-sliding | 5-7 days |
| Overlay | ion-modal, ion-action-sheet, ion-toast | 3-5 days |

For a starter library of 12-15 controls: roughly 6-10 weeks of focused work.

---

## Honest Assessment

- **"Make Xojo web apps touch-friendly":** Build custom mobile-friendly WebSDK controls from scratch using modern CSS and vanilla JS. No 500KB dependency, no Shadow DOM surprises, full styling control.
- **"Get iOS/Android-native feel":** Cherry-pick Ionic components (Approach C). Start with 3-4 simple ones to prove the pattern.
- **"Build a full mobile app framework in Xojo":** Don't port Ionic — architecture gap is too wide. Design something for Xojo's server-rendered model from the ground up.
