# Chips WebSDK Control — Design Spec

## Summary

Fresh rebuild of the Chips WebSDK control in the `ChipsClaude/` directory. A visual `WebSDKUIControl` that renders a horizontal list of toggleable chips with checkboxes, backed by TypeScript. Each chip represents a fruit from a JSON array, and the control returns the full selection state as a JSON object map.

## Build Approach

**TypeScript-First:** Write `src/Chips.ts`, compile to `dist/Chips.js`, then build the Xojo class with the compiled JS and CSS embedded as string constants.

## File Structure

```
ChipsClaude/
├── src/
│   ├── Chips.ts            # Browser-side TypeScript source
│   └── XojoWebSDK.d.ts     # Type definitions for WebSDK API
├── dist/
│   └── Chips.js            # Compiled JS output (generated)
├── package.json            # Minimal, typescript dependency only
├── tsconfig.json           # ES2015 target, strict mode
├── App.xojo_code           # Minimal Xojo app shell
├── Build Automation.xojo_code
├── Chips.xojo_code         # The WebSDK control class
├── Chips.xojo_project      # Project file
├── Session.xojo_code       # Session with JS/CSS file delivery
└── WebPage1.xojo_code      # Demo page
```

## Data Contract

### Xojo Properties

- **`ItemsJSON As String`** — JSON array of strings. Example: `["Apple","Banana","Coconut","Durian","Eggplant","Fig"]`. Order preserved as supplied.
- **`StateJSON As String`** — JSON object map. Example: `{"Apple":true,"Banana":false,"Coconut":true,"Durian":false,"Eggplant":false,"Fig":true}`. Updated on every selection change.

Both are computed properties with setters that call `UpdateBrowser`.

### Xojo Event

- **`SelectionChanged(StateJSON As String)`** — Raised once per user toggle. Carries the full current state map, not only the changed item.

### Serialization Flow

```
Xojo Serialize → JSON {itemsJSON, stateJSON, enabled} → Browser updateControl
Browser triggerServerEvent("SelectionChanged", {stateJSON}) → Xojo ExecuteEvent → raises SelectionChanged
```

### Data Rules

- Missing keys in `StateJSON` default to `false`
- Unknown keys not present in `ItemsJSON` are silently ignored
- Duplicate item labels are deduplicated (first occurrence wins)
- Fruit label text is both the display label and the stable identity key

## TypeScript Implementation

### Class Structure

```
namespace WebSDKSamples {
  export class Chips extends XojoWeb.XojoVisualControl {
    private items: string[] = []
    private state: Record<string, boolean> = {}
    private chipsEnabled: boolean = true

    updateControl(data: string): void    — parse JSON, normalize state, refresh
    render(): void                        — build DOM: chips list with checkboxes
    handleToggle(item, selected): void    — update state, fire server event
    normalizeState(items, state)          — ensure all items have explicit boolean
    parseItemsJSON(json): string[]        — safe parse, dedupe, type check
    parseStateJSON(json): Record          — safe parse, coerce values to boolean
  }
}
```

### Rendering

- Each fruit renders as a `<label class="xojo-chips__chip">` containing a native `<input type="checkbox">` and a `<span class="xojo-chips__label">`
- Chips are arranged in a flex-wrap container `<div class="xojo-chips__list">`
- Clicking the chip or checkbox toggles the associated fruit
- Checked state driven by `state[label]`
- Disabled state driven by Xojo `Enabled` property

### DOM Structure

```html
<div class="xojo-chips" role="group" aria-label="Selectable chips">
  <div class="xojo-chips__list">
    <label class="xojo-chips__chip is-selected">
      <input type="checkbox" checked>
      <span class="xojo-chips__label">Apple</span>
    </label>
    <label class="xojo-chips__chip">
      <input type="checkbox">
      <span class="xojo-chips__label">Banana</span>
    </label>
    <!-- ... -->
  </div>
</div>
```

### Event Handling

- `handleToggle` updates local state, normalizes it, fires `triggerServerEvent("SelectionChanged", params, false)` with the full state JSON, then calls `refresh()`
- The third argument `false` means no delay — event fires immediately

## CSS Design

### Classes

| Class | Purpose |
|-------|---------|
| `.xojo-chips` | Root container, `display: block` |
| `.xojo-chips__list` | Flex-wrap container with `gap: .75rem` |
| `.xojo-chips__chip` | Individual chip: inline-flex, pill-shaped (`border-radius: 999px`) |
| `.xojo-chips__chip:hover` | Hover: light indigo background, indigo border |
| `.xojo-chips__chip.is-selected` | Selected: blue background (`#1d4ed8`), white text |
| `.xojo-chips__chip.is-disabled` | Disabled: `opacity: .65`, `cursor: not-allowed` |
| `.xojo-chips__label` | Text span, `white-space: nowrap` |

### Color Palette

- Unselected background: `#f8fafc`
- Unselected border: `#cbd5e1`
- Unselected text: `#0f172a`
- Hover background: `#eef2ff`
- Hover border: `#818cf8`
- Selected background/border: `#1d4ed8`
- Selected text: `#fff`

CSS is embedded as a `kCSS` string constant in the Xojo class, delivered via `SessionCSSURLs` and a shared `WebFile`.

## Xojo Class Details

### `Chips` (inherits `WebSDKUIControl`)

**Private properties:**
- `mItemsJSON As String`
- `mStateJSON As String`
- `Shared SharedJSFile As WebFile`
- `Shared SharedCSSFile As WebFile`

**Computed properties (public):**
- `ItemsJSON` — getter returns `mItemsJSON`, setter sets and calls `UpdateBrowser`
- `StateJSON` — getter returns `mStateJSON`, setter sets and calls `UpdateBrowser`

**Events implemented:**
- `JavaScriptClassName()` → `"WebSDKSamples.Chips"`
- `Serialize(js)` → sets `itemsJSON`, `stateJSON`, `enabled` on the JSON item
- `ExecuteEvent(name, parameters)` → on `"selectionchanged"`, reads `stateJSON` from params, stores in `mStateJSON`, returns `True`
- `SessionJavascriptURLs(session)` → creates shared `WebFile` from `kJSCode` constant
- `SessionCSSURLs(session)` → creates shared `WebFile` from `kCSS` constant
- `DrawControlInLayoutEditor(g)` → renders 3 sample chips with rounded rectangles, checkbox circles, and labels

**Constants:**
- `kJSCode As String` — the compiled `dist/Chips.js` content
- `kCSS As String` — the chip CSS styles

## Demo Page

**`WebPage1`** includes:
- `DescriptionLabel` — explains what the control does
- `Chips1` — initialized with `["Apple","Banana","Coconut","Durian","Eggplant","Fig"]`, initial state has Apple/Coconut/Fig selected
- `ToggleEnabledButton` — flips `Chips1.Enabled`, caption toggles between "Disable Chips" / "Enable Chips"
- `StatePreviewTextArea` — read-only, shows live `StateJSON` updated on every `SelectionChanged`

## Build Flow

1. Set up `package.json` and `tsconfig.json`
2. Copy `XojoWebSDK.d.ts` from Bootstrap Toast example
3. Write `src/Chips.ts`
4. Compile: `npx tsc -p tsconfig.json` → produces `dist/Chips.js`
5. Write CSS string
6. Build `Chips.xojo_code` with embedded `kJSCode` and `kCSS` constants
7. Build `WebPage1.xojo_code`, `App.xojo_code`, `Session.xojo_code`, `Build Automation.xojo_code`
8. Write `Chips.xojo_project`

## Test Plan

1. **TypeScript build** — `npx tsc` succeeds, `dist/Chips.js` generated without errors
2. **Chip rendering** — all 6 chips render in order in the browser
3. **Initial state** — Apple, Coconut, Fig checked; Banana, Durian, Eggplant unchecked
4. **Toggle behavior** — clicking any chip toggles only that fruit's state
5. **Event firing** — `SelectionChanged` fires once per toggle with full state map
6. **State completeness** — returned JSON always includes every fruit key with explicit `true`/`false`
7. **Disable** — setting `Enabled = false` prevents interaction and event emission, opacity drops
8. **Re-enable** — setting `Enabled = true` restores interaction
9. **Missing state keys** — default to `false`
10. **Unknown keys** — silently ignored
11. **IDE preview** — `DrawControlInLayoutEditor` renders without script errors

## Assumptions

- TypeScript source in `src/`, compiled output in `dist/`
- JSON is the only Xojo-facing data API
- Fruit text is both display label and identity key
- Canonical return value is a JSON object map, not an array of objects
- No per-chip disabled state, readonly mode, or keyboard navigation in this version
