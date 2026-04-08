# Mobile Web Research 02: Building Mobile-Friendly WebSDK Controls

**Date:** 2025-04-08  
**Context:** Following the Ionic Framework research (mobile-web-01.md), this report addresses the practical strategy for building custom mobile-friendly WebSDK controls within the Xojo web framework.

---

## 1. Keep the Xojo Web Framework

**Decision: Yes — Xojo's framework stays as-is.**

The Xojo IDE provides things that would take years to build from scratch:

| What you keep | Why it matters |
|---|---|
| Visual designer | Drag-and-drop layout, WYSIWYG preview |
| Inspector properties | ViewBehavior + computed properties = IDE-native settings |
| DrawControlInLayoutEditor | Live preview of custom controls in the designer |
| Debugger | Step through Xojo code, breakpoints, variable inspection |
| Project management | Multi-file text format, classes, modules |
| Build system | One-click compile + run with debug server |

WebSDK is a **plugin architecture** — your custom controls live INSIDE the framework, not beside it. As proven with Chips/Chex:
- `DrawControlInLayoutEditor` gives IDE preview
- `ViewBehavior` properties appear in the Inspector
- Computed property setters trigger `UpdateControl` → browser update
- `ExecuteEvent` receives browser events back into Xojo code
- The debug server serves everything automatically

**No framework modifications needed.** You build within the existing architecture.

---

## 2. Create Own Components via WebSDK

**Decision: Build from scratch using the Chips/Chex pattern, inspired by Ionic's design.**

### Why build from scratch instead of wrapping Ionic:

| Factor | Wrap Ionic | Build from scratch |
|---|---|---|
| Dependency | ~500KB+ CDN load | Zero external dependencies |
| Shadow DOM | Complex, limits styling | Full CSS control |
| Component nesting | Conflicts with Xojo flat model | Designed for Xojo from day one |
| Debugging | Two layers to debug | Single JS layer |
| Updates/maintenance | Ionic updates may break wrappers | You control everything |
| Bundle size | Fixed large payload | Only what you use |

### Proposed component library (adapted from Ionic's best features):

**Phase 1 — Core (build these first):**

| Component | Inspired by | Xojo class name | Description |
|---|---|---|---|
| Toggle switch | ion-toggle | `MobileToggle` | iOS/Android-style on/off switch |
| Card | ion-card | `MobileCard` | Content card with image, header, body, actions |
| List | ion-list + ion-item | `MobileList` | Touch-friendly list with icons, avatars, swipe actions |
| Segment | ion-segment | `MobileSegment` | iOS-style tab/filter switcher |
| Searchbar | ion-searchbar | `MobileSearchbar` | Search input with clear/cancel buttons |
| Toast | ion-toast | `MobileToast` | Non-intrusive notification (non-visual WebSDKControl) |

**Phase 2 — Interactive:**

| Component | Inspired by | Xojo class name | Description |
|---|---|---|---|
| Action sheet | ion-action-sheet | `MobileActionSheet` | Bottom sheet with option list |
| FAB | ion-fab | `MobileFAB` | Floating action button |
| Range/Slider | ion-range | `MobileRange` | Touch-friendly slider with labels |
| Date picker | ion-datetime | `MobileDatePicker` | Mobile-optimized date/time selection |
| Bottom sheet | ion-modal (sheet) | `MobileBottomSheet` | Draggable bottom panel |
| Pull to refresh | ion-refresher | `MobileRefresher` | Pull-down refresh gesture |

**Phase 3 — Enhanced:**

| Component | Inspired by | Xojo class name | Description |
|---|---|---|---|
| Accordion | ion-accordion | `MobileAccordion` | Collapsible content sections |
| Skeleton | ion-skeleton-text | `MobileSkeleton` | Loading placeholder |
| Infinite scroll | ion-infinite-scroll | `MobileInfiniteScroll` | Load-more on scroll |
| Reorder list | ion-reorder | `MobileReorderList` | Drag-to-reorder items |
| Badge | ion-badge | `MobileBadge` | Count indicator |
| Chip (done!) | ion-chip | `Chips` | Already built! |
| Checkbox list (done!) | — | `Chex` | Already built! |

### Architecture per component:

Every component follows the proven pattern:

```
Xojo Class (WebSDKUIControl)
├── DrawControlInLayoutEditor  → IDE preview
├── Serialize(js)              → Push state to browser
├── ExecuteEvent               → Receive events from browser
├── SessionJavascriptURLs      → Deliver JS via SharedJSFile
├── SessionCSSURLs             → Deliver CSS via SharedCSSFile
├── Computed properties        → IDE inspector + UpdateControl trigger
└── Convenience methods        → AddItem, RemoveItem, etc.

JavaScript Class (XojoWeb.XojoVisualControl)
├── constructor                → Create child DOM elements
├── updateControl(data)        → Apply state to DOM (super LAST)
├── render()                   → applyUserStyle + applyTooltip
└── event handlers             → triggerServerEvent back to Xojo
```

---

## 3. CSS Strategy: Bootstrap, Tailwind, and Figma

This is the most nuanced question. Here's the full picture:

### What Xojo uses today

Xojo Web 2.0 ships with **Bootstrap 5.3** built into the framework:
- Built-in controls (WebButton, WebTextField, etc.) use Bootstrap classes
- `CSSClasses` property lets you add Bootstrap utility classes to any control
- Bootstrap responsive utilities (`d-none d-md-block`, `gap-3`, etc.) work on all controls
- `WebPicture.BootstrapIcon()` provides Bootstrap icons
- Layout types support Flex via `LayoutTypes.Flex` with Bootstrap gap/wrap classes

### Where WebSDK controls live

WebSDK controls use **their own CSS**, delivered via `SharedCSSFile`. This CSS is:
- **Global** (not Shadow DOM) — scoped only by class naming convention (BEM-like)
- **Independent of Bootstrap** — your `.xojo-chips__chip` classes don't conflict with Bootstrap
- **Loaded once** per session (SharedCSSFile with `Session = Nil`)

This means: **WebSDK controls can use any CSS approach without affecting Bootstrap**.

### Tailwind CSS v4 — Can it work?

**Yes, with caveats.**

| Approach | How | Pros | Cons |
|---|---|---|---|
| **A. Tailwind CDN (dev)** | Load `@tailwindcss/browser@4` via SessionHead | Zero build step, all Tailwind classes available | Runtime overhead, Preflight conflicts with Bootstrap, not for production |
| **B. Tailwind CLI (prod)** | Build CSS with Tailwind CLI, deliver via SharedCSSFile | Production-ready, tree-shaken, minimal size | Requires build step outside Xojo |
| **C. Tailwind-inspired CSS** | Write custom CSS using Tailwind design tokens | Zero dependencies, full control | Manual work, no Figma automation |
| **D. Hybrid (recommended)** | Tailwind CDN for dev/design, extract CSS for prod | Best of both worlds | Two-step workflow |

### Tailwind + Bootstrap conflict resolution

Tailwind's **Preflight** resets margins, borders, headings — this WILL break Bootstrap's styles. Solutions:

1. **Disable Preflight entirely** (skip `tailwindcss/preflight.css` import)
2. **Scope Tailwind to WebSDK controls only** — since WebSDK CSS is in its own file, keep Tailwind utilities there
3. **Use Tailwind CDN with a `<style type="text/tailwindcss">` block** that only targets your control classes

For the CDN approach, add to SessionHead:
```html
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<style type="text/tailwindcss">
  @layer base {
    /* Disable Preflight resets for non-WebSDK elements */
  }
</style>
```

### Recommended approach: Hybrid (D)

**During development/design:**
1. Design components in Figma
2. Use Figma's "Inspect" panel or Tailwind plugins to get utility classes
3. Load Tailwind CDN in SessionHead for rapid iteration
4. Build WebSDK control JS using Tailwind classes: `div.className = 'flex items-center gap-2 px-4 py-2 rounded-full'`

**For production:**
1. Extract the CSS your controls actually use
2. Convert Tailwind utilities to plain CSS in your SharedCSSFile:
   ```css
   /* Tailwind: flex items-center gap-2 px-4 py-2 rounded-full */
   .mobile-toggle__track {
     display: flex;
     align-items: center;
     gap: 0.5rem;
     padding: 0.5rem 1rem;
     border-radius: 9999px;
   }
   ```
3. Remove Tailwind CDN dependency
4. Ship zero-dependency CSS via SharedCSSFile

### Figma → Xojo workflow

```
Figma Design
    │
    ├─── Figma Inspect / Dev Mode ──→ CSS properties (colors, spacing, fonts)
    │
    ├─── Figma Tailwind Plugin ────→ Tailwind utility classes
    │
    └─── Export assets (icons, images)
         │
         ▼
    Convert to WebSDK CSS
    │
    ├─── SharedCSSFile.Data = "..." (inline in Xojo)
    │    OR
    └─── External .css file loaded via SessionCSSURLs
         │
         ▼
    WebSDK JS uses CSS classes
    div.className = 'mobile-toggle__track'
```

**Figma design tokens** (colors, spacing, radii, shadows) can be extracted once and used as CSS custom properties across all controls:

```css
/* Design tokens from Figma — shared across all Mobile* controls */
:root {
  --mobile-primary: #1d4ed8;
  --mobile-radius-sm: 4px;
  --mobile-radius-full: 9999px;
  --mobile-shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --mobile-font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --mobile-spacing-xs: 0.25rem;
  --mobile-spacing-sm: 0.5rem;
  --mobile-spacing-md: 1rem;
}
```

This gives you Figma-driven theming without any Tailwind dependency.

---

## 4. Data Flow — Unchanged

**Confirmed: The WebSDK data flow stays exactly as-is.**

```
Xojo Property Setter
    → UpdateControl()
    → Serialize(js As JSONItem)
    → JSON string sent to browser
    → JS updateControl(data)
    → JSON.parse → update DOM

User interaction in browser
    → event handler in JS
    → triggerServerEvent(name, params, false)
    → Xojo ExecuteEvent(name, parameters)
    → RaiseEvent → Page handler
```

New mobile controls follow the identical pattern. The only difference is the DOM elements being created (e.g., `<div class="mobile-toggle">` instead of `<span class="xojo-chips__chip">`).

The key rules remain:
- `super.updateControl(data)` must be LAST
- Use `New JSONItem(jsonString)` in Serialize for nested JSON
- Wrap updateControl body in try/catch
- Content in CHILD elements, root gets `position: relative`

---

## 5. WebPage and Navigation

**Decision: WebPage model stays. Add a mobile navigation WebSDK control ON TOP of it.**

### The current model

Xojo uses `WebPage.Show()` for navigation. Each page is a full server-rendered view. This is fundamentally different from SPA (single-page app) routing used by Ionic/React/Vue.

### What mobile apps need

| Navigation pattern | Description | Xojo approach |
|---|---|---|
| Tab bar | Bottom tabs, iOS/Android style | `MobileTabBar` WebSDK control at page bottom |
| Side menu / drawer | Hamburger menu that slides in | `MobileDrawer` WebSDK control |
| Stack navigation | Push/pop with back button | Use `WebPage.Show()` + browser back |
| Bottom sheet | Draggable panel from bottom | `MobileBottomSheet` WebSDK control (overlay) |

### MobileTabBar concept

A `MobileTabBar` WebSDK control could:
- Render at the bottom of the page (fixed position)
- Show 3-5 tab icons with labels
- On tap → call `triggerServerEvent("TabChanged", params)` → Xojo shows the appropriate `WebPage`
- Highlight the active tab

```xojo
' In Xojo (page event handler)
Sub TabChanged()
  Select Case MobileTabBar1.SelectedTab
  Case "home"
    HomePage.Show
  Case "search"
    SearchPage.Show
  Case "profile"
    ProfilePage.Show
  End Select
End Sub
```

### No framework modification needed

The `WebPage.Show()` mechanism works fine for mobile navigation. What's missing is the **visual treatment** — the tab bar, the slide animation, the gesture handling. These are all UI layer concerns that WebSDK controls can provide.

### What MIGHT need attention

- **Page transition animations:** Xojo's default page transition is a full reload. For a mobile feel, you might want slide animations. This could be done via CSS transitions in SessionHead.
- **Viewport meta tag:** Mobile apps need `<meta name="viewport" content="width=device-width, initial-scale=1">`. Set this in WebHTMLHeader project property.
- **Safe areas (notch):** iOS notch/safe area handling via `env(safe-area-inset-top)` CSS. Add to your control CSS.
- **Touch feedback:** Add `:active` styles and `touch-action` CSS properties to controls for responsive touch feel.

---

## 6. App, Session, Cookie — Fully Compatible

**No changes needed. Everything stays the same.**

| Feature | Compatibility | Notes |
|---|---|---|
| App (WebApplication) | ✅ Unchanged | Application lifecycle, HandleURL, etc. |
| Session (WebSession) | ✅ Unchanged | Per-user state, Session.Identifier, timeout |
| Cookie management | ✅ Unchanged | Session cookies work as before |
| Authentication | ✅ Unchanged | Login patterns, session-scoped DB connections |
| WebThread | ✅ Unchanged | Background processing, async operations |
| WebTimer | ✅ Unchanged | Polling, periodic updates |
| HandleURL | ✅ Unchanged | REST API endpoints alongside mobile UI |
| WebSessionContext | ✅ Unchanged | Cross-session communication |
| Database connections | ✅ Unchanged | Session-scoped connections |

The mobile controls are purely a **UI layer** addition. They produce HTML/CSS/JS in the browser via WebSDK, but all server-side Xojo code (App, Session, database, auth, etc.) is completely unaffected.

### Session-level mobile settings

You might want to add session-level properties for mobile detection:

```xojo
' Session.Opening
Var userAgent As String = Request.Header("User-Agent")
Session.IsMobile = userAgent.IndexOf("Mobile") >= 0 Or userAgent.IndexOf("Android") >= 0

' Then in pages, conditionally show mobile vs desktop controls
If Session.IsMobile Then
  MobileList1.Visible = True
  WebListBox1.Visible = False
Else
  MobileList1.Visible = False
  WebListBox1.Visible = True
End If
```

---

## Summary: The Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Xojo IDE                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ Visual   │  │Inspector │  │ Debugger         │  │
│  │ Designer │  │Properties│  │ Breakpoints      │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
├─────────────────────────────────────────────────────┤
│              Xojo Web Framework                     │
│  ┌────────┐  ┌─────────┐  ┌──────────┐             │
│  │  App   │  │ Session │  │ WebPage  │             │
│  └────────┘  └─────────┘  └──────────┘             │
│  Bootstrap 5.3 │ Built-in controls │ HandleURL     │
├─────────────────────────────────────────────────────┤
│              WebSDK Layer (your controls)           │
│  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │MobileToggle│  │MobileList  │  │MobileTabBar  │  │
│  │MobileCard  │  │MobileSearch│  │MobileToast   │  │
│  │MobileSegment│ │MobileFAB   │  │MobileDrawer  │  │
│  └────────────┘  └────────────┘  └──────────────┘  │
│  Custom CSS (Figma-driven) │ No Bootstrap needed    │
├─────────────────────────────────────────────────────┤
│                    Browser                          │
│  Bootstrap (Xojo controls) + Custom CSS (Mobile*)   │
│  Coexist without conflict via class naming          │
└─────────────────────────────────────────────────────┘
```

### Key takeaways

1. **Xojo framework = unchanged.** Build within it, not around it.
2. **Build from scratch** using WebSDK patterns proven with Chips/Chex. Adapt Ionic's component designs and properties but implement in vanilla JS + CSS.
3. **CSS strategy:** Use Figma for design → extract design tokens as CSS custom properties → write component CSS in SharedCSSFile. Optionally use Tailwind CDN during development. No Tailwind dependency in production.
4. **Data flow = unchanged.** Serialize → updateControl → triggerServerEvent → ExecuteEvent.
5. **Navigation = WebPage.Show() + mobile UI layer.** Add MobileTabBar, MobileDrawer as WebSDK controls that trigger page navigation.
6. **Server-side = unchanged.** App, Session, cookies, database, auth — all work as before.
