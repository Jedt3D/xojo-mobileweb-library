# Xojo Mobile Web Controls — Project Proposal

**Project:** Xojo Mobile Web Controls  
**Format:** Xojo Library (`.xojo_library`, Xojo 2025r3.1+)  
**Library Name:** `MobileWeb`  
**Namespace:** All controls accessed as `MobileWeb.Toggle`, `MobileWeb.Card`, etc.  
**JS Namespace:** `MobileWeb` (e.g., `MobileWeb.Toggle`, `MobileWeb.Card`)  
**CSS Prefix:** `mobile-` (e.g., `.mobile-toggle__track`, `.mobile-card__header`)

**Roles:**
- **AI Agent (Claude Code):** Plans, implements, reviews. Main agent coordinates; subagents execute tasks.
- **Human:** Tests in Xojo IDE, gives feedback, makes design decisions.

---

## 1. What We're Building

A library of mobile-first WebSDK controls for Xojo Web 2.0 applications. These controls:

- Look and feel native on iOS and Android mobile browsers
- Coexist peacefully with Xojo's built-in Bootstrap 5.3 controls
- Follow the proven Chips/Chex WebSDK pattern (Serialize → updateControl → triggerServerEvent → ExecuteEvent)
- Ship as a single `.xojo_library` with zero external runtime dependencies
- Use Vanilla CSS + CSS custom properties for theming (no Tailwind, no extra Bootstrap)
- Are designed in Figma, with design tokens extracted as CSS custom properties

### What We're NOT Building

- A replacement for Xojo's built-in controls
- A full mobile app framework with routing/navigation
- Shadow DOM components
- Anything requiring a JavaScript module bundler
- Server-side modifications to Xojo's framework

---

## 2. Prior Research

This proposal synthesizes three research documents:

| Document | Key Decision |
|---|---|
| `mobile-web-01.md` | Ionic Framework assessment: cherry-pick component designs, but build from scratch (not wrap Ionic) |
| `mobile-web-02.md` | Architecture: keep Xojo framework, WebSDK data flow unchanged, navigation via WebSDK controls on top of WebPage.Show() |
| `mobile-web-03.md` | CSS strategy: Vanilla CSS + @layer + BEM naming, 3-layer design tokens, no Tailwind in production, Figma → CSS pipeline |

---

## 3. Xojo Library Structure

```
MobileWeb/                              ← Library root (Library= in .xojo_project)
├── Theme/
│   └── MobileTheme.xojo_code           ← Module: shared CSS tokens, SharedThemeFile
│
├── Controls/
│   ├── Toggle.xojo_code                ← MobileWeb.Toggle
│   ├── Card.xojo_code                  ← MobileWeb.Card
│   ├── SegmentedControl.xojo_code      ← MobileWeb.SegmentedControl
│   ├── SearchBar.xojo_code             ← MobileWeb.SearchBar
│   ├── Toast.xojo_code                 ← MobileWeb.Toast (non-visual)
│   ├── ListItem.xojo_code              ← MobileWeb.ListItem (helper class)
│   ├── MobileList.xojo_code            ← MobileWeb.MobileList
│   ├── ActionSheet.xojo_code           ← MobileWeb.ActionSheet
│   ├── FAB.xojo_code                   ← MobileWeb.FAB
│   ├── Range.xojo_code                 ← MobileWeb.Range
│   ├── BottomSheet.xojo_code           ← MobileWeb.BottomSheet
│   ├── TabBar.xojo_code                ← MobileWeb.TabBar
│   ├── Badge.xojo_code                 ← MobileWeb.Badge
│   ├── Accordion.xojo_code             ← MobileWeb.Accordion
│   └── Skeleton.xojo_code              ← MobileWeb.Skeleton
│
└── Demo/                               ← NOT in library — separate demo project
    ├── DemoApp.xojo_project
    ├── ToggleDemoPage.xojo_code
    ├── CardDemoPage.xojo_code
    └── ...
```

### Project File Entry

```
Library=MobileWeb;MobileWeb;&hLIB_ID;&h0000000000000000;false
Module=MobileTheme;MobileWeb/Theme/MobileTheme.xojo_code;&hTHEME_ID;&hLIB_ID;false
Class=Toggle;MobileWeb/Controls/Toggle.xojo_code;&hTOGGLE_ID;&hLIB_ID;false
Class=Card;MobileWeb/Controls/Card.xojo_code;&hCARD_ID;&hLIB_ID;false
...
```

---

## 4. Component Roadmap

### Phase 1 — Foundation (build the pattern + 3 controls)

| # | Control | Type | Inspired By | Description |
|---|---|---|---|---|
| 0 | `MobileTheme` | Module | — | Shared CSS design tokens, theme WebFile |
| 1 | `Toggle` | Visual | ion-toggle | iOS/Android-style on/off switch |
| 2 | `Card` | Visual | ion-card | Content card with image, header, body |
| 3 | `SegmentedControl` | Visual | ion-segment | iOS-style tab/filter switcher |

**Why these three first:** Toggle is the simplest interactive control (proves the full round-trip). Card is a display-only control (proves content rendering). SegmentedControl is multi-item interactive (proves the item management pattern from Chips/Chex scales).

### Phase 2 — Core Set (6 more controls)

| # | Control | Type | Inspired By | Description |
|---|---|---|---|---|
| 4 | `SearchBar` | Visual | ion-searchbar | Search input with clear/cancel buttons |
| 5 | `Toast` | Non-visual | ion-toast | Non-intrusive notifications |
| 6 | `MobileList` | Visual | ion-list + ion-item | Touch-friendly list with icons, avatars |
| 7 | `ActionSheet` | Visual | ion-action-sheet | Bottom sheet with option list |
| 8 | `FAB` | Visual | ion-fab | Floating action button |
| 9 | `Range` | Visual | ion-range | Touch-friendly slider with labels |

### Phase 3 — Enhanced (5 more controls)

| # | Control | Type | Inspired By | Description |
|---|---|---|---|---|
| 10 | `BottomSheet` | Visual | ion-modal (sheet) | Draggable bottom panel |
| 11 | `TabBar` | Visual | ion-tab-bar | Bottom navigation tabs |
| 12 | `Badge` | Visual | ion-badge | Count indicator |
| 13 | `Accordion` | Visual | ion-accordion | Collapsible content sections |
| 14 | `Skeleton` | Visual | ion-skeleton-text | Loading placeholder |

---

## 5. Per-Control Architecture

Every control follows the identical pattern proven by Chips/Chex:

### Xojo Side

```
Class Toggle (inherits WebSDKUIControl)
├── JavaScriptClassName()     → "MobileWeb.Toggle"
├── Serialize(js)             → Push IsOn, Enabled, Label to browser
├── ExecuteEvent(name, params)→ Receive "Toggled" event
├── SessionJavascriptURLs()   → SharedJSFile (Data-first order)
├── SessionCSSURLs()          → MobileTheme.SharedThemeFile + SharedCSSFile
├── DrawControlInLayoutEditor → IDE preview
├── SessionHead()             → Empty (no CDN needed)
├── HandleRequest()           → Empty (no custom HTTP)
│
├── Properties:
│   ├── IsOn As Boolean       → Computed, calls UpdateControl
│   ├── Label As String       → Computed, calls UpdateControl
│   └── mIsOn, mLabel        → Private backing fields
│
├── Events (Hooks):
│   └── Event Toggled(value As Boolean)
│
├── Shared:
│   ├── Private Shared SharedJSFile As WebFile
│   └── Private Shared SharedCSSFile As WebFile
│
└── ViewBehavior:
    ├── IsOn    Visible=true  Group="Behavior"
    ├── Label   Visible=true  Group="Behavior"
    └── Enabled Visible=true  Group="Appearance"
```

### JavaScript Side

```javascript
var MobileWeb;
(function(MobileWeb) {
  class Toggle extends XojoWeb.XojoVisualControl {
    constructor(id, events) {
      super(id, events);
      this.isOn = false;
      this.label = '';
      this.toggleEnabled = true;
      var el = this.DOMElement();
      if (el) {
        el.style.position = 'relative';
        // Build child DOM...
      }
    }
    updateControl(data) {
      try {
        var update = JSON.parse(data);
        this.isOn = update.isOn === true;
        this.label = update.label || '';
        this.toggleEnabled = update.enabled !== false;
        this.rebuild();
      } catch(e) { console.log('UC ERROR:', e.message); }
      super.updateControl(data);  // LAST
    }
    handleTap() {
      if (!this.toggleEnabled) return;
      this.isOn = !this.isOn;
      this.rebuild();
      var params = new XojoWeb.JSONItem();
      params.set('value', this.isOn);
      this.triggerServerEvent('Toggled', params, false);
    }
    render() {
      super.render();
      var el = this.DOMElement();
      if (!el) return;
      this.applyUserStyle();
      this.applyTooltip(el);
    }
  }
  MobileWeb.Toggle = Toggle;
})(MobileWeb || (MobileWeb = {}));
```

### CSS Side

```css
@layer mobile-components {
  .mobile-toggle {
    display: inline-flex;
    align-items: center;
    gap: var(--mobile-space-sm);
    cursor: pointer;
    user-select: none;
    -webkit-user-select: none;
    min-height: var(--mobile-tap-size);
  }
  .mobile-toggle__track {
    width: 52px;
    height: 32px;
    background: var(--mobile-border);
    border-radius: var(--mobile-radius-full);
    padding: 2px;
    transition: background var(--mobile-duration-normal) var(--mobile-ease);
  }
  .mobile-toggle__track.is-on {
    background: var(--mobile-primary);
  }
  .mobile-toggle__thumb {
    width: 28px;
    height: 28px;
    background: white;
    border-radius: 50%;
    transition: transform var(--mobile-duration-normal) var(--mobile-ease);
    box-shadow: var(--mobile-shadow-sm);
  }
  .mobile-toggle__track.is-on .mobile-toggle__thumb {
    transform: translateX(20px);
  }
  .mobile-toggle.is-disabled {
    opacity: var(--mobile-disabled-opacity);
    cursor: default;
    pointer-events: none;
  }
}
```

---

## 6. Theme System (MobileTheme Module)

### Design Principle: Single Configuration Point

The `MobileTheme` module is the **one and only place** where design tokens are defined. No control ever hardcodes a color, font, spacing, or radius value. Every visual property flows from these tokens via `var(--mobile-*)` references.

**To customize the theme**, a developer changes values in `MobileTheme.ThemeCSS()` and all controls update automatically. No need to touch individual control CSS.

### Token Architecture (3 Layers)

```
Layer 1: Primitive Tokens     →  Raw values (colors, sizes)
Layer 2: Semantic Tokens      →  Purpose-mapped (--mobile-primary, --mobile-text)
Layer 3: Component Tokens     →  Per-control overrides (optional, in component CSS)
```

Layer 1 and 2 live in `MobileTheme.ThemeCSS()`. Layer 3 is optional — components can define control-specific overrides like `--mobile-toggle-track-width: 52px` in their own CSS, referencing Layer 2 tokens as defaults.

### Token CSS (delivered via SharedThemeFile)

```css
@layer mobile-tokens {
  :root {
    /* ═══════════════════════════════════════════════════
       CONFIGURATION SECTION — Edit these values to
       customize the entire MobileWeb theme.
       All controls reference these tokens via var().
       ═══════════════════════════════════════════════════ */

    /* ─── Colors: Primitive ─── */
    --mobile-blue-500: #3b82f6;
    --mobile-blue-600: #2563eb;
    --mobile-blue-700: #1d4ed8;
    --mobile-gray-50: #f8fafc;
    --mobile-gray-100: #f1f5f9;
    --mobile-gray-200: #e2e8f0;
    --mobile-gray-300: #cbd5e1;
    --mobile-gray-400: #94a3b8;
    --mobile-gray-500: #64748b;
    --mobile-gray-800: #1e293b;
    --mobile-gray-900: #0f172a;
    --mobile-red-500: #ef4444;
    --mobile-green-500: #22c55e;
    --mobile-amber-500: #f59e0b;

    /* ─── Colors: Semantic (change these to re-theme everything) ─── */
    --mobile-primary: var(--mobile-blue-700);
    --mobile-primary-hover: var(--mobile-blue-600);
    --mobile-on-primary: #ffffff;
    --mobile-surface: var(--mobile-gray-50);
    --mobile-surface-hover: var(--mobile-gray-100);
    --mobile-border: var(--mobile-gray-300);
    --mobile-text: var(--mobile-gray-900);
    --mobile-text-secondary: var(--mobile-gray-500);
    --mobile-danger: var(--mobile-red-500);
    --mobile-success: var(--mobile-green-500);
    --mobile-warning: var(--mobile-amber-500);
    --mobile-disabled-opacity: 0.5;

    /* ─── Spacing ─── */
    --mobile-space-xs: 0.25rem;
    --mobile-space-sm: 0.5rem;
    --mobile-space-md: 1rem;
    --mobile-space-lg: 1.5rem;
    --mobile-space-xl: 2rem;

    /* ─── Typography ─── */
    --mobile-font: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    --mobile-text-xs: 0.75rem;
    --mobile-text-sm: 0.875rem;
    --mobile-text-base: 1rem;
    --mobile-text-lg: 1.125rem;
    --mobile-text-xl: 1.25rem;
    --mobile-font-normal: 400;
    --mobile-font-medium: 500;
    --mobile-font-semibold: 600;
    --mobile-font-bold: 700;

    /* ─── Shape ─── */
    --mobile-radius-sm: 0.25rem;
    --mobile-radius-md: 0.5rem;
    --mobile-radius-lg: 0.75rem;
    --mobile-radius-xl: 1rem;
    --mobile-radius-full: 9999px;

    /* ─── Elevation ─── */
    --mobile-shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
    --mobile-shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1);
    --mobile-shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.1);

    /* ─── Motion ─── */
    --mobile-ease: cubic-bezier(0.25, 0, 0.3, 1);
    --mobile-duration-fast: 0.15s;
    --mobile-duration-normal: 0.2s;
    --mobile-duration-slow: 0.3s;

    /* ─── Touch ─── */
    --mobile-tap-size: 44px;
    --mobile-tap-highlight: rgba(0,0,0,0.05);
  }

  /* ─── Dark Mode (auto-detected) ─── */
  @media (prefers-color-scheme: dark) {
    :root {
      --mobile-primary: var(--mobile-blue-500);
      --mobile-primary-hover: var(--mobile-blue-600);
      --mobile-surface: var(--mobile-gray-800);
      --mobile-surface-hover: var(--mobile-gray-900);
      --mobile-text: var(--mobile-gray-100);
      --mobile-text-secondary: var(--mobile-gray-400);
      --mobile-border: var(--mobile-gray-500);
      --mobile-shadow-sm: 0 1px 2px rgba(0,0,0,0.2);
      --mobile-shadow-md: 0 4px 6px -1px rgba(0,0,0,0.3);
      --mobile-shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.3);
    }
  }
}
```

### Theme Delivery (Xojo)

The `MobileTheme` module has **two Xojo methods** that control the theme:

```xojo
Module MobileTheme
  ' ─── The single shared WebFile (loaded once, all controls reference it) ───
  Public Shared Property SharedThemeFile As WebFile

  ' ─── ThemeCSS: THE configuration point ───
  ' Edit the CSS string returned here to change colors, fonts, spacing etc.
  ' Every MobileWeb control references these tokens via var(--mobile-*).
  Public Function ThemeCSS() As String
    Return "@layer mobile-tokens{:root{" _
      + "--mobile-blue-500:#3b82f6;--mobile-blue-600:#2563eb;--mobile-blue-700:#1d4ed8;" _
      + "--mobile-gray-50:#f8fafc;--mobile-gray-100:#f1f5f9;--mobile-gray-200:#e2e8f0;" _
      + "... (full token set)" _
      + "}}"
  End Function

  ' ─── EnsureThemeFile: Called by every control's SessionCSSURLs ───
  ' Creates SharedThemeFile once; subsequent calls are no-ops.
  Public Sub EnsureThemeFile()
    If SharedThemeFile <> Nil Then Return

    SharedThemeFile = New WebFile
    SharedThemeFile.Data = ThemeCSS()
    SharedThemeFile.Session = Nil
    SharedThemeFile.Filename = "mobile-theme.css"
    SharedThemeFile.MIMEType = "text/css"
  End Sub
End Module
```

Each control loads the shared theme + its own CSS via a simple 2-line pattern:
```xojo
Function SessionCSSURLs(session As WebSession) As String()
  ' Shared theme (loaded once by first control that needs it)
  MobileTheme.EnsureThemeFile()

  ' Component-specific CSS
  If SharedCSSFile = Nil Then
    SharedCSSFile = New WebFile
    SharedCSSFile.Data = ToggleCSS()    ' Component CSS method
    SharedCSSFile.Session = Nil
    SharedCSSFile.Filename = "MobileToggle.css"
    SharedCSSFile.MIMEType = "text/css"
  End If

  Return Array(MobileTheme.SharedThemeFile.URL, SharedCSSFile.URL)
End Function
```

### Quick Customization Guide

| To change... | Edit in `MobileTheme.ThemeCSS()` |
|---|---|
| Brand color | `--mobile-primary` and `--mobile-primary-hover` |
| Font family | `--mobile-font` |
| Default text size | `--mobile-text-base` |
| Card/button corner radius | `--mobile-radius-md` / `--mobile-radius-lg` |
| Default padding | `--mobile-space-md` |
| Shadow intensity | `--mobile-shadow-sm` / `-md` / `-lg` |
| Animation speed | `--mobile-duration-normal` |
| Minimum tap target | `--mobile-tap-size` (keep ≥ 44px for accessibility) |

---

## 7. Development Workflow

### For Each Control

```
┌─────────────────────────────────────────────┐
│ 1. AI Agent: Write CSS (component styles)    │
│ 2. AI Agent: Write JS (DOM + interactions)   │
│ 3. AI Agent: Write Xojo class                │
│    ├── 7 events (lifecycle)                  │
│    ├── Properties + computed wrappers        │
│    ├── Convenience API methods               │
│    ├── ViewBehavior (inspector config)       │
│    └── DrawControlInLayoutEditor (preview)   │
│ 4. AI Agent: Write demo page                 │
│ 5. AI Agent: Self-review against spec        │
├─────────────────────────────────────────────┤
│ 6. Human: Open in Xojo IDE, build, test      │
│ 7. Human: Report issues or approve           │
├─────────────────────────────────────────────┤
│ 8. AI Agent: Fix issues if any               │
│ 9. Repeat 6-8 until approved                 │
└─────────────────────────────────────────────┘
```

### CLI Workflow (CSS Build, Outside Xojo)

```bash
mobile-controls/
├── src/
│   ├── tokens.css             # Design tokens
│   ├── toggle.css             # Component CSS
│   ├── card.css
│   └── ...
├── dist/
│   └── mobile-controls.min.css
└── build-css.sh

# build-css.sh
cat src/tokens.css src/*.css > dist/mobile-controls.css
npx lightningcss --minify dist/mobile-controls.css -o dist/mobile-controls.min.css
```

Output gets pasted into Xojo SharedCSSFile.Data strings. This step is optional — CSS can also be authored directly as inline strings.

---

## 8. AI Agent Strategy

### Architecture: Main Agent + Subagents

```
┌───────────────────────────────────────────────────────┐
│                  MAIN AGENT (Planner)                 │
│  • Reads this proposal                                │
│  • Creates detailed plan per phase                    │
│  • Dispatches subagents per control                   │
│  • Reviews subagent output                            │
│  • Communicates with human for testing                │
│  • Tracks progress via TaskCreate/TaskUpdate          │
└───────────┬───────────────────────────────────────────┘
            │ dispatches
            ▼
┌───────────────────────────────────────────────────────┐
│              IMPLEMENTER SUBAGENT (per control)       │
│  • Receives: full task spec, file paths, code to write│
│  • Writes: .xojo_code, .js (inline), .css (inline)    │
│  • Self-reviews against spec                          │
│  • Reports: DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT │
└───────────────────────────────────────────────────────┘
            │ then
            ▼
┌───────────────────────────────────────────────────────┐
│           SPEC REVIEWER SUBAGENT                      │
│  • Checks: Does implementation match the spec?        │
│  • Checks: All properties, events, CSS classes present│
│  • Checks: WebFile order correct                      │
│  • Checks: super.updateControl(data) is LAST          │
│  • Reports: ✅ pass / ❌ issues list                  │
└───────────────────────────────────────────────────────┘
            │ then
            ▼
┌───────────────────────────────────────────────────────┐
│           CODE QUALITY REVIEWER SUBAGENT              │
│  • Checks: Naming conventions (BEM CSS, Xojo naming)  │
│  • Checks: No bare element styling in CSS             │
│  • Checks: try/catch in updateControl                 │
│  • Checks: IIFE for var closures                      │
│  • Checks: ViewBehavior completeness                  │
│  • Reports: ✅ pass / ❌ issues list                  │
└───────────────────────────────────────────────────────┘
            │ then
            ▼
┌───────────────────────────────────────────────────────┐
│              HUMAN TEST GATE                          │
│  • Opens project in Xojo IDE                          │
│  • Builds and runs                                    │
│  • Tests in browser (desktop + mobile simulator)      │
│  • Reports: approved / issues                         │
└───────────────────────────────────────────────────────┘
```

### Subagent Strategy: Subagent-Driven Development

Use the **superpowers:subagent-driven-development** skill:

1. **Main agent** reads this proposal, creates a detailed plan per phase
2. **Per control:** dispatch an implementer subagent with:
   - Full task description (don't make subagent read files)
   - The `Building-WebSDK-Controls.md` guide as reference
   - Exact file paths to create
   - The MobileTheme token CSS (so component CSS uses tokens)
   - The target control spec (properties, events, CSS classes)
3. **Spec reviewer subagent** checks against the control spec
4. **Code quality reviewer subagent** checks against the WebSDK guide
5. **Human gate:** user tests in Xojo IDE, reports results
6. **Fix loop:** if issues found, dispatch fix subagent with specific instructions

### Why Subagents Work Here

| Benefit | Why |
|---|---|
| **Fresh context per control** | Each control is independent — no context pollution |
| **Parallel-safe** | Controls don't share mutable state during development |
| **Consistent quality** | Every control goes through the same review gates |
| **Preserves main context** | Main agent stays focused on coordination, not drowning in JS/CSS strings |
| **Fail-safe** | A subagent failure doesn't corrupt the main agent's progress |

### Context Each Subagent Needs

Every implementer subagent receives:

1. **This proposal** (section 5: Per-Control Architecture)
2. **Building-WebSDK-Controls.md** (the complete WebSDK guide)
3. **MobileTheme CSS tokens** (the full token string)
4. **Control-specific spec:**
   - Properties with types and defaults
   - Events with parameter types
   - CSS class names and states
   - DOM structure
   - Interaction behavior
5. **File paths to create/modify**
6. **Working directory**

### Task Tracking

Main agent uses `TaskCreate`/`TaskUpdate` to track:

```
Phase 1:
  [ ] MobileTheme module
  [ ] Toggle control
  [ ] Card control
  [ ] SegmentedControl
  [ ] Phase 1 human test
  [ ] Phase 1 fixes

Phase 2:
  [ ] SearchBar control
  [ ] Toast control
  [ ] MobileList control
  ...
```

---

## 9. Control Specifications (Phase 1)

### Control 0: MobileTheme Module

**Type:** Module (not a control)  
**Purpose:** Shared CSS design tokens + theme WebFile

**Contains:**
- `SharedThemeFile As WebFile` (Public Shared)
- `ThemeCSS() As String` — returns the full token CSS string
- Dark mode token overrides

**No events, no DOM, no JavaScript.** This is purely a CSS delivery mechanism.

---

### Control 1: Toggle

**Inspired by:** ion-toggle  
**Class:** `Toggle` (accessed as `MobileWeb.Toggle`)  
**JS Class:** `MobileWeb.Toggle`

**Properties:**

| Property | Type | Default | Inspector | Description |
|---|---|---|---|---|
| IsOn | Boolean | False | Visible | Current toggle state |
| Label | String | "" | Visible | Text label next to toggle |
| LabelPosition | Integer | 0 | Visible | 0=Right, 1=Left |

**Events:**

| Event | Parameters | Description |
|---|---|---|
| Toggled | value As Boolean | Fired when user taps the toggle |

**CSS Classes:**

| Class | Description |
|---|---|
| `.mobile-toggle` | Root container (inline-flex) |
| `.mobile-toggle__track` | The oval track |
| `.mobile-toggle__thumb` | The circle thumb |
| `.mobile-toggle__label` | Text label |
| `.mobile-toggle__track.is-on` | On state |
| `.mobile-toggle.is-disabled` | Disabled state |

**DOM Structure:**
```html
<div class="mobile-toggle">
  <div class="mobile-toggle__track">
    <div class="mobile-toggle__thumb"></div>
  </div>
  <span class="mobile-toggle__label">Label text</span>
</div>
```

**IDE Preview:** Oval track (32x52px) with circle thumb, label text to the right.

---

### Control 2: Card

**Inspired by:** ion-card  
**Class:** `Card` (accessed as `MobileWeb.Card`)  
**JS Class:** `MobileWeb.Card`

**Properties:**

| Property | Type | Default | Inspector | Description |
|---|---|---|---|---|
| Title | String | "" | Visible | Card header title |
| Subtitle | String | "" | Visible | Card header subtitle |
| Body | String | "" | Visible | Card body text |
| ImageURL | String | "" | Visible | URL for header image |
| Elevated | Boolean | True | Visible | Show shadow elevation |

**Events:**

| Event | Parameters | Description |
|---|---|---|
| Pressed | — | Fired when user taps the card |

**CSS Classes:**

| Class | Description |
|---|---|
| `.mobile-card` | Root container |
| `.mobile-card__image` | Header image |
| `.mobile-card__header` | Title + subtitle area |
| `.mobile-card__title` | Title text |
| `.mobile-card__subtitle` | Subtitle text |
| `.mobile-card__body` | Body content area |
| `.mobile-card.has-shadow` | Elevated state |

**DOM Structure:**
```html
<div class="mobile-card has-shadow">
  <img class="mobile-card__image" src="..." />
  <div class="mobile-card__header">
    <div class="mobile-card__title">Title</div>
    <div class="mobile-card__subtitle">Subtitle</div>
  </div>
  <div class="mobile-card__body">Body text...</div>
</div>
```

---

### Control 3: SegmentedControl

**Inspired by:** ion-segment  
**Class:** `SegmentedControl` (accessed as `MobileWeb.SegmentedControl`)  
**JS Class:** `MobileWeb.SegmentedControl`

**Properties:**

| Property | Type | Default | Inspector | Description |
|---|---|---|---|---|
| ItemList | String | "" | Visible | Comma-separated segment labels |
| SelectedIndex | Integer | 0 | Visible | Currently selected segment |
| SelectedItem | String | "" | Hidden | Name of selected segment (read-only) |

**Methods:**
- `AddItem(name As String)`
- `RemoveItem(name As String)`
- `ClearItems()`
- `AllItems() As String()`
- `Count As Integer` (read-only computed)

**Events:**

| Event | Parameters | Description |
|---|---|---|
| SelectionChanged | index As Integer, name As String | Fired when user taps a segment |

**CSS Classes:**

| Class | Description |
|---|---|
| `.mobile-segment` | Root container (pill shape) |
| `.mobile-segment__button` | Individual segment |
| `.mobile-segment__button.is-selected` | Active segment |
| `.mobile-segment.is-disabled` | Disabled state |

**DOM Structure:**
```html
<div class="mobile-segment">
  <button class="mobile-segment__button is-selected">All</button>
  <button class="mobile-segment__button">Active</button>
  <button class="mobile-segment__button">Done</button>
</div>
```

---

## 10. Reference Documents

| Document | Purpose | Location |
|---|---|---|
| `Building-WebSDK-Controls.md` | WebSDK development guide (gotchas, patterns) | Project root |
| `mobile-web-01.md` | Ionic Framework research | Project root |
| `mobile-web-02.md` | Mobile strategy (6 key decisions) | Project root |
| `mobile-web-03.md` | CSS implementation strategy | Project root |
| `Chips.xojo_code` | Reference implementation (visual control) | Project root |
| `Chex.xojo_code` | Reference implementation (checkbox variant) | Project root |
| `xojo-project-format.md` | Xojo Library project format spec | Skill knowledge |
| `xojo-websdk` skill | WebSDK development rules | Claude skill |
| `xojo-web` skill | Xojo Web development rules | Claude skill |

---

## 11. Quality Gates

Every control must pass these checks before the human test gate:

### Spec Compliance
- [ ] All properties from spec are implemented with computed wrappers
- [ ] All events from spec are implemented with `#tag Hook`
- [ ] All CSS classes from spec exist
- [ ] DOM structure matches spec
- [ ] IDE preview (DrawControlInLayoutEditor) is functional
- [ ] ViewBehavior is complete (all standard + custom properties)

### WebSDK Compliance (from Building-WebSDK-Controls.md)
- [ ] WebFile property order: Data → Session → Filename → MIMEType
- [ ] `super.updateControl(data)` is LAST in updateControl
- [ ] `try/catch` wraps updateControl body
- [ ] No `this.setAttributes()` anywhere
- [ ] `position: relative` on root DOMElement
- [ ] Content in child elements only
- [ ] `New JSONItem()` wraps JSON strings in Serialize
- [ ] IIFE used for closures in `var` loops (if applicable)
- [ ] `name.Lowercase` used in ExecuteEvent Select Case

### CSS Compliance (from mobile-web-03.md)
- [ ] All classes use `mobile-` prefix
- [ ] BEM naming: `.mobile-{control}__{element}.is-{state}`
- [ ] No bare element styling
- [ ] Uses `var(--mobile-*)` tokens, not hardcoded values
- [ ] Wrapped in `@layer mobile-components`
- [ ] Minimum tap target: 44px on interactive elements
- [ ] `user-select: none` on interactive elements
- [ ] Transitions use `var(--mobile-duration-*)` and `var(--mobile-ease)`

### Human Test Checklist
- [ ] Control appears in Xojo IDE toolbox
- [ ] Drag onto page — IDE preview renders
- [ ] Inspector shows expected properties
- [ ] Build succeeds without errors
- [ ] Control renders in browser
- [ ] Interactions work (click, toggle, select)
- [ ] Events fire back to Xojo
- [ ] Enabled/Disabled state works
- [ ] Mobile browser test (touch, tap targets, scrolling)

---

## 12. Getting Started

**To begin Phase 1, the main agent should:**

1. Read this proposal fully
2. Read `Building-WebSDK-Controls.md` for the WebSDK guide
3. Create a detailed implementation plan using `superpowers:writing-plans`
4. Set up tasks via `TaskCreate` for each control
5. Begin with MobileTheme module (foundation for all controls)
6. Then Toggle (simplest interactive control)
7. After each control: spec review → code review → human test gate
8. Iterate until human approves, then move to next control

**The human will:**
1. Wait for the agent to deliver a control
2. Open the project in Xojo IDE 2025r3.1
3. Build and run
4. Test in browser (desktop + mobile)
5. Report results: approved or issues to fix
