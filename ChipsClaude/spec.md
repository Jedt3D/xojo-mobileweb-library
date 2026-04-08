## Chips WebSDK Control v1

### Summary
Create a new standalone example project under `Examples/Chips/` that demonstrates a visual WebSDK `Chips` control for multi-select fruit toggles. Author the browser-side source in TypeScript under `src/`, transpile it to JavaScript in `dist/`, and load the compiled file into the Xojo control through `SessionJavaScriptURLs`.

The control will accept its item list and current state from Xojo as JSON, render one chip per fruit with a leading checkbox, and return a full JSON object map where each fruit key is explicitly `true` or `false`.

### Key Changes
- Add a new example project under `Examples/Chips/` with:
  - `Chips.xojo_project`
  - `Chips.xojo_code` as the visual WebSDK control
  - `WebPage1.xojo_code` as the demo page
  - `src/Chips.ts` for browser-side source
  - `src/XojoWebSDK.d.ts` copied from an existing TypeScript example
  - `dist/Chips.js` as the compiled output
  - `tsconfig.json` and minimal `package.json` for the TypeScript build
- Use `WebSDKUIControl` on the Xojo side and `XojoWeb.XojoVisualControl` on the browser side.
- Use a non-`Example` namespace for the browser class, for example `WebSDKSamples.Chips`, and return that exact name from `JavaScriptClassName()`.
- Deliver the compiled `dist/Chips.js` through a shared `WebFile` in `SessionJavaScriptURLs`.
- Implement `DrawControlInLayoutEditor` with a simple chip preview so the control is recognizable in the IDE.

### Public API / Data Contract
- `ItemsJSON As String`
  - JSON array of strings.
  - Example: `["Apple","Banana","Coconut","Durian","Eggplant","Fig"]`
  - Order is preserved exactly as supplied.
- `StateJSON As String`
  - Canonical current state as a JSON object map.
  - Example: `{"Apple":true,"Banana":false,"Coconut":true,"Durian":false,"Eggplant":false,"Fig":true}`
  - Updated whenever the browser reports a selection change.
- `SelectionChanged(StateJSON As String)`
  - Raised once per user toggle.
  - Carries the full current state map, not only the changed item.
- Serialization contract:
  - `Serialize(js)` sends `items`, `state`, and `enabled`.
  - Browser `updateControl(data)` parses JSON, updates local state, then calls `refresh()`.
  - Browser toggle handlers call `triggerServerEvent("SelectionChanged", params)` with the full updated state.
  - `ExecuteEvent` writes the returned JSON back into `StateJSON` and raises `SelectionChanged`.

### Behavior and TypeScript Implementation
- `src/Chips.ts` owns all browser rendering and event wiring.
- The TypeScript state model is:
  - `items: string[]`
  - `state: Record<string, boolean>`
  - `enabled: boolean`
- Rendering behavior:
  - each fruit renders as a chip with a native checkbox input and text label
  - clicking the chip or checkbox toggles the associated fruit
  - checked state is driven by `state[label]`
  - disabled state is driven by Xojo `Enabled`
- Data rules:
  - missing keys in `StateJSON` default to `false`
  - unknown keys not present in `ItemsJSON` are ignored
  - duplicate item labels are invalid for v1 because label text is also the identity key
- DOM and styling rules:
  - all DOM work stays inside the control root
  - the control applies its own local CSS classes only
  - no per-chip disabled state, readonly mode, or advanced keyboard support is added in v1
- Build flow:
  - `src/` is the editable source directory
  - `dist/Chips.js` is the generated artifact consumed by the Xojo project
  - `tsconfig.json` should target ES2015 and output directly to `dist/Chips.js`

### Demo Example
- The example page should:
  - initialize `ItemsJSON` with the six-fruit array
  - initialize `StateJSON` with a sample selection
  - display the current `StateJSON` live when `SelectionChanged` fires
  - include one simple control to flip the Chips control between enabled and disabled
- The example should make the JSON contract obvious so another developer can reuse the control quickly.

### Test Plan
- Run the TypeScript build and confirm `dist/Chips.js` is generated without errors.
- Run the example locally and verify:
  - all six chips render in order
  - each chip shows a checkbox before the label
  - initial checked states match `StateJSON`
  - toggling any chip updates only that fruit’s state
  - `SelectionChanged` fires once per toggle
  - returned JSON always includes every fruit key with explicit `true` or `false`
  - disabling the control prevents interaction and event emission
  - missing state keys default to `false`
  - unknown keys are ignored
- Verify the layout editor preview renders without IDE script errors.

### Assumptions
- TypeScript source lives in `src/` and compiled JavaScript lives in `dist/`.
- JSON is the only v1 Xojo-facing data API.
- Fruit text is both the display label and the stable identity key.
- The canonical returned value is a JSON object map, not an array of objects.
- A standalone example project is part of the deliverable.
