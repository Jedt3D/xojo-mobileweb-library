# Building Bulletproof Xojo WebSDK Controls

A battle-tested guide based on building the Chips and Chex controls from scratch — every mistake made, every silent failure diagnosed, every pattern proven.

**Updated:** April 2026 — includes convenience API patterns, multi-control namespaces, IDE inspector tricks, and CSS strategies learned from building two production controls.

---

## Architecture Overview

A WebSDK control lives in two worlds simultaneously: **Xojo** (server) manages state and events, **JavaScript** (browser) manages rendering and user interaction. They communicate through a JSON bridge.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        XOJO SERVER                                  │
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────────────────┐  │
│  │  Properties   │───▶│ UpdateControl│───▶│  Serialize(js)        │  │
│  │  ItemsJSON    │    │   (trigger)  │    │  js.Value("x") = val  │  │
│  │  StateJSON    │    └──────────────┘    └──────────┬────────────┘  │
│  │  Enabled      │                                   │              │
│  └──────────────┘                                    │              │
│                                                      │ JSON string  │
│  ┌──────────────────────┐                            │              │
│  │  ExecuteEvent(name,  │◀───── triggerServerEvent ──┼──────────┐   │
│  │    parameters)       │         (from browser)     │          │   │
│  │  RaiseEvent Changed  │                            │          │   │
│  └──────────────────────┘                            │          │   │
└──────────────────────────────────────────────────────┼──────────┼───┘
                                                       │          │
                              ─ ─ ─ ─ ─ Network ─ ─ ─ ┼ ─ ─ ─ ─ ┼ ─
                                                       │          │
┌──────────────────────────────────────────────────────┼──────────┼───┐
│                        BROWSER                       │          │   │
│                                                      ▼          │   │
│  ┌───────────────────────────────────────────────────────────┐   │   │
│  │  class MyControl extends XojoWeb.XojoVisualControl {      │   │   │
│  │                                                           │   │   │
│  │    constructor(id, events)     ◀── Framework creates      │   │   │
│  │      └─▶ Create child DOM elements                        │   │   │
│  │                                                           │   │   │
│  │    updateControl(data)         ◀── Receives JSON string   │   │   │
│  │      └─▶ Parse JSON, update state, rebuild DOM            │   │   │
│  │      └─▶ super.updateControl(data)  ⚠ MUST BE LAST       │   │   │
│  │                                                           │   │   │
│  │    render()                    ◀── Framework calls         │   │   │
│  │      └─▶ super.render()                                   │   │   │
│  │      └─▶ applyUserStyle(), applyTooltip(el)               │   │   │
│  │                                                           │   │   │
│  │    handleToggle(item)          ◀── User interaction        │   │   │
│  │      └─▶ Update local state                               │   │   │
│  │      └─▶ Rebuild DOM                                      │   │   │
│  │      └─▶ triggerServerEvent("EventName", params) ─────────┘   │
│  │  }                                                            │
│  └───────────────────────────────────────────────────────────────┘
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Two Base Classes

| Base Class | Use For | Has DOM? | IDE Preview? |
|---|---|---|---|
| `WebSDKUIControl` | Visual controls (buttons, chips, charts) | Yes | `DrawControlInLayoutEditor` |
| `WebSDKControl` | Non-visual controls (toasts, analytics) | No | Not needed |

---

## The 7 Essential Events

Every WebSDK control inherits these events. Not all are required, but understanding each is critical.

### 1. JavaScriptClassName() → String

Maps your Xojo class to its JavaScript counterpart. Must match exactly.

```xojo
Function JavaScriptClassName() As String
  Return "WebSDKSamples.Chips"    // Matches: namespace.ClassName in JS
End Function
```

**Rule:** Never use the reserved `"Xojo"` namespace.

**Multiple controls can share one namespace.** Both Chips and Chex use `WebSDKSamples`:
```xojo
// Chips.xojo_code
Return "WebSDKSamples.Chips"

// Chex.xojo_code
Return "WebSDKSamples.Chex"
```

### 2. Serialize(js As JSONItem)

Converts Xojo state into JSON for the browser. Called by the framework whenever `UpdateControl()` fires.

```xojo
Sub Serialize(js As JSONItem)
  Var items As String = mItemsJSON
  If items = "" Then items = "[]"
  js.Value("itemsJSON") = New JSONItem(items)    // ⚠ MUST wrap JSON strings
  js.Value("stateJSON") = New JSONItem(state)    // ⚠ MUST wrap JSON strings
  js.Value("enabled") = Self.Enabled             // Simple types: OK as-is
End Sub
```

**The `New JSONItem()` rule:**
- Simple types (String, Integer, Boolean) → assign directly
- JSON strings (arrays `"[...]"`, objects `"{...}"`) → MUST wrap with `New JSONItem(jsonString)`
- Without wrapping, inner quotes get double-escaped and `JSON.parse` fails silently at position 400+

### 3. ExecuteEvent(name, parameters) → Boolean

Receives events fired from JavaScript via `triggerServerEvent()`.

```xojo
Function ExecuteEvent(name As String, parameters As JSONItem) As Boolean
  Select Case name.Lowercase
  Case "selectionchanged"
    mStateJSON = parameters.Value("stateJSON")
    RaiseEvent SelectionChanged
    Return True
  End Select
End Function
```

**Always use `name.Lowercase`** for the Select Case — event names from JS may have different casing.

### 4. SessionJavascriptURLs(session) → String()

Delivers JavaScript to the browser. Called once per session.

```xojo
Function SessionJavascriptURLs(session As WebSession) As String()
  If SharedJSFile = Nil Then
    SharedJSFile = New WebFile
    SharedJSFile.Data = "..."                        // 1. Data FIRST
    SharedJSFile.Session = Nil                       // 2. Session SECOND
    SharedJSFile.Filename = "Chips.js"               // 3. Filename THIRD
    SharedJSFile.MIMEType = "application/javascript" // 4. MIMEType FOURTH
  End If
  Return Array(SharedJSFile.URL)
End Function
```

### 5. SessionCSSURLs(session) → String()

Same pattern as JS, for CSS files. Use `"text/css"` MIME type.

**Multiple CSS files:** You can return multiple URLs. Useful for shared theme + component CSS:
```xojo
Return Array(SharedThemeFile.URL, SharedCSSFile.URL)
```

### 6. SessionHead(session) → String

Injects raw HTML into `<head>`. Useful for external CDN links or viewport meta tags.

### 7. DrawControlInLayoutEditor(g As Graphics)

Draws the IDE preview. Uses Xojo Graphics API — runs as XojoScript in the IDE.

**Important:**
- `g.TextHeight` is a **property** (no parameters)
- `g.TextWidth(text)` is a **method** (takes string parameter)
- Errors show as a warning icon in the IDE, not as compile errors
- Use `g.Width` and `g.Height` for the control's dimensions

```xojo
Sub DrawControlInLayoutEditor(g As Graphics)
  // Background
  g.DrawingColor = &cF8FAFC
  g.FillRoundRectangle(0, 0, g.Width, g.Height, 8, 8)
  g.DrawingColor = &cCBD5E1
  g.DrawRoundRectangle(0, 0, g.Width, g.Height, 8, 8)

  // Draw sample content
  g.FontSize = 16
  g.DrawingColor = &c0F172A
  g.DrawText("Label", 12, g.Height / 2 + g.TextHeight / 4)
End Sub
```

---

## Property Update Flow (Xojo → Browser)

```
Xojo Property Setter
        │
        ▼
  mItemsJSON = value
  UpdateControl()          ◀── You MUST call this in every setter
        │
        ▼
  Framework calls Serialize(js)
        │
        ▼
  JSON string sent to browser
        │
        ▼
  JS updateControl(data)
        │
        ▼
  JSON.parse(data)
        │
        ▼
  Rebuild DOM
        │
        ▼
  super.updateControl(data)   ◀── MUST be last
```

### The Computed Property Pattern

Every user-facing property needs a computed wrapper that calls `UpdateControl`:

```xojo
#tag ComputedProperty, Flags = &h0
  #tag Getter
    Get
      Return mItemsJSON
    End Get
  #tag EndGetter
  #tag Setter
    Set
      mItemsJSON = value
      UpdateControl             // ◀── This triggers Serialize → Browser
    End Set
  #tag EndSetter
  ItemsJSON As String
#tag EndComputedProperty

#tag Property, Flags = &h21
  Private mItemsJSON As String  // Backing field
#tag EndProperty
```

### Framework Properties Need Explicit UpdateControl

Setting inherited properties like `Enabled` does NOT automatically trigger your Serialize event:

```xojo
Chips1.Enabled = Not Chips1.Enabled
Chips1.UpdateControl                    // ◀── REQUIRED, otherwise browser won't know
```

---

## Event Flow (Browser → Xojo)

```
User clicks chip in browser
        │
        ▼
  JS click handler fires
        │
        ▼
  handleToggle(item)
  ├─▶ Update local state
  ├─▶ Rebuild DOM (immediate visual feedback)
  │
  ├─▶ var params = new XojoWeb.JSONItem()
  │   params.set("stateJSON", JSON.stringify(this.state))
  │   this.triggerServerEvent("SelectionChanged", params, false)
        │
        ▼
  ─ ─ ─ Network ─ ─ ─
        │
        ▼
  Xojo ExecuteEvent("selectionchanged", parameters)
        │
        ▼
  mStateJSON = parameters.Value("stateJSON")
  RaiseEvent SelectionChanged
        │
        ▼
  Page code handles event
```

### Defining Custom Events (Hooks)

```xojo
#tag Hook, Flags = &h0
  Event SelectionChanged()
#tag EndHook
```

### Wiring Events on a Page

Events go in `#tag Events ControlName` blocks AFTER `#tag EndWindowCode`:

```xojo
#tag Events Chips1
  #tag Event
    Sub SelectionChanged()
      StatePreviewTextArea.Text = Chips1.StateJSON
    End Sub
  #tag EndEvent
#tag EndEvents
```

**WRONG** (does not work):
```xojo
// This format does NOT exist in Xojo
#tag EventHandler
  Sub Chips1_SelectionChanged()
  End Sub
#tag EndEventHandler
```

---

## File Delivery: The WebFile Pattern

### Critical: Property Setup Order

The WebFile properties MUST be set in this exact order. Any other order causes the file to silently fail to load:

```xojo
SharedJSFile = New WebFile
SharedJSFile.Data = "..."                        // 1. Data
SharedJSFile.Session = Nil                       // 2. Session = Nil
SharedJSFile.Filename = "Chips.js"               // 3. Filename
SharedJSFile.MIMEType = "application/javascript" // 4. MIMEType
```

| # | Property | Why This Order |
|---|---|---|
| 1 | `.Data` | Content must exist before metadata |
| 2 | `.Session = Nil` | Makes file available to ALL sessions |
| 3 | `.Filename` | Sets the URL path |
| 4 | `.MIMEType` | Browser needs correct type to execute |

### Shared vs Per-Instance

Always use `Private Shared` for WebFile properties — one file serves all instances:

```xojo
#tag Property, Flags = &h21
  Private Shared SharedJSFile As WebFile
#tag EndProperty
```

---

## The JavaScript Side

### Class Structure

```javascript
var WebSDKSamples;
(function(WebSDKSamples) {

  class Chips extends XojoWeb.XojoVisualControl {

    constructor(id, events) {
      super(id, events);
      this.items = [];
      this.state = {};
      this.chipsEnabled = true;

      var el = this.DOMElement();
      if (el) {
        el.style.position = 'relative';     // Required
        // Create CHILD elements — never style root directly
        this.listEl = document.createElement('div');
        this.listEl.className = 'xojo-chips__list';
        el.appendChild(this.listEl);
      }
    }

    updateControl(data) {
      try {
        var update = JSON.parse(data);
        // Read properties — already parsed objects/arrays thanks to
        // New JSONItem() in Serialize. No inner JSON.parse needed.
        if (Array.isArray(update.itemsJSON)) {
          this.items = update.itemsJSON.filter(function(e) {
            return typeof e === 'string';
          });
        }
        if (update.stateJSON && typeof update.stateJSON === 'object') {
          var s = {};
          for (var k in update.stateJSON) {
            if (update.stateJSON.hasOwnProperty(k))
              s[k] = update.stateJSON[k] === true;
          }
          this.state = s;
        }
        this.chipsEnabled = typeof update.enabled === 'boolean'
          ? update.enabled : true;
        this.rebuildChips();
      } catch(e) {
        console.log('UC ERROR:', e.message);
      }
      super.updateControl(data);    // ⚠ ALWAYS LAST
    }

    rebuildChips() {
      if (!this.listEl) return;
      this.listEl.replaceChildren();
      var self = this;
      for (var i = 0; i < this.items.length; i++) {
        var item = this.items[i];
        var chip = document.createElement('span');
        chip.className = 'xojo-chips__chip';
        if (this.state[item] === true) chip.classList.add('is-selected');
        if (!this.chipsEnabled) chip.classList.add('is-disabled');
        chip.textContent = item;
        // IIFE needed for var-scoped closures
        chip.addEventListener('click', (function(name) {
          return function() {
            if (!self.chipsEnabled) return;
            self.handleToggle(name);
          };
        })(item));
        this.listEl.appendChild(chip);
      }
    }

    handleToggle(item) {
      this.state[item] = !this.state[item];
      this.rebuildChips();
      var params = new XojoWeb.JSONItem();
      params.set('stateJSON', JSON.stringify(this.state));
      this.triggerServerEvent('SelectionChanged', params, false);
    }

    render() {
      super.render();
      var el = this.DOMElement();
      if (!el) return;
      this.applyUserStyle();
      this.applyTooltip(el);
      // DO NOT call this.setAttributes()
    }
  }

  WebSDKSamples.Chips = Chips;   // Export to namespace

})(WebSDKSamples || (WebSDKSamples = {}));
```

### Key Rules

| Rule | Why |
|---|---|
| `super.updateControl(data)` must be LAST | Code after super may not execute |
| Never call `this.setAttributes()` | May not exist; silently kills control |
| Set `position: relative` on root element | Framework manages absolute positioning |
| Put content in CHILD elements | Root element is framework-managed |
| Wrap updateControl body in `try/catch` | Silent parse errors become visible |
| Use IIFE for closures in `var` loops | `var` has function scope, not block scope |
| Use `replaceChildren()` to clear DOM | Clean, efficient DOM rebuild |
| Validate types before using data | `Array.isArray()`, `typeof === 'object'` |

### Key Framework Methods Available

| Method | Purpose |
|---|---|
| `this.DOMElement()` | Get the root container `<div>` |
| `this.applyUserStyle()` | Apply Xojo IDE style properties |
| `this.applyTooltip(el)` | Apply tooltip from Xojo property |
| `this.triggerServerEvent(name, params, skipQueue)` | Send event to Xojo |
| `super.updateControl(data)` | Let framework handle base properties |
| `super.render()` | Let framework handle base rendering |

### Multiple Controls in One Namespace

Both Chips and Chex share the `WebSDKSamples` namespace. Each class is registered separately:

```javascript
var WebSDKSamples;
(function(WebSDKSamples) {
  class Chips extends XojoWeb.XojoVisualControl { /* ... */ }
  WebSDKSamples.Chips = Chips;

  class Chex extends XojoWeb.XojoVisualControl { /* ... */ }
  WebSDKSamples.Chex = Chex;
})(WebSDKSamples || (WebSDKSamples = {}));
```

Each control delivers its own JS/CSS file. The namespace IIFE pattern (`|| (WebSDKSamples = {})`) safely extends the namespace regardless of load order.

---

## CSS Strategy

### BEM-like Naming Convention

All controls use scoped class names that will never collide with Bootstrap or Xojo's built-in styles:

```css
/* Block: .xojo-{control} or .mobile-{control} */
/* Element: __{element} */
/* State: .is-{state} */

.xojo-chips__list { }
.xojo-chips__chip { }
.xojo-chips__chip.is-selected { }
.xojo-chips__chip.is-disabled { }

.xojo-chex__list { }
.xojo-chex__item { }
.xojo-chex__item.is-disabled { }
.xojo-chex__label { }
```

**Rules:**
1. Never style bare HTML elements (`button`, `input`, `a`) — Xojo's Bootstrap styles those
2. Always prefix with a namespace (`xojo-`, `mobile-`)
3. State classes use `is-` prefix (not BEM `--modifier` which conflicts with CSS custom properties)
4. Keep specificity flat — one class selector, never nest beyond state

### CSS Delivery via SharedCSSFile

CSS is inline as a string, following the same Data-first WebFile pattern:

```xojo
Function SessionCSSURLs(session As WebSession) As String()
  If SharedCSSFile = Nil Then
    SharedCSSFile = New WebFile
    SharedCSSFile.Data = ".xojo-chips__list{display:flex;...}"
    SharedCSSFile.Session = Nil
    SharedCSSFile.Filename = "Chips.css"
    SharedCSSFile.MIMEType = "text/css"
  End If
  Return Array(SharedCSSFile.URL)
End Function
```

### Coexistence with Bootstrap 5.3

Xojo Web 2.0 uses Bootstrap 5.3 for built-in controls. Your WebSDK CSS is completely separate:

- Bootstrap targets: `.btn`, `.form-control`, bare `button`, bare `input`
- Your CSS targets: `.xojo-chips__chip`, `.mobile-toggle__track`
- **Zero conflict** as long as you never style bare HTML elements

---

## Convenience API Pattern

Raw JSON properties (`ItemsJSON`, `StateJSON`) are powerful but unfriendly for day-to-day use. The Chips/Chex controls wrap them with a convenience API.

### Internal JSON Helpers (Private)

Three private methods handle all JSON parsing and rebuilding:

```xojo
Private Function ParseItems() As String()
  Var result() As String
  If mItemsJSON = "" Or mItemsJSON = "[]" Then Return result
  Try
    Var j As New JSONItem(mItemsJSON)
    For i As Integer = 0 To j.Count - 1
      result.Add(j.ValueAt(i))
    Next
  Catch e As RuntimeException
  End Try
  Return result
End Function

Private Function ParseState() As Dictionary
  Var result As New Dictionary
  If mStateJSON = "" Or mStateJSON = "{}" Then Return result
  Try
    Var j As New JSONItem(mStateJSON)
    For i As Integer = 0 To j.Count - 1
      Var key As String = j.Name(i)
      Var b As Boolean = j.Value(key)
      result.Value(key) = b
    Next
  Catch e As RuntimeException
  End Try
  Return result
End Function

Private Sub RebuildJSON(items() As String, state As Dictionary)
  Var jItems As New JSONItem
  For Each item As String In items
    jItems.Add(item)
  Next
  mItemsJSON = jItems.ToString

  Var jState As New JSONItem
  For Each item As String In items
    If state.HasKey(item) Then
      Var b As Boolean = state.Value(item)
      jState.Value(item) = b
    Else
      jState.Value(item) = False
    End If
  Next
  mStateJSON = jState.ToString
  UpdateControl
End Sub
```

**Pattern:** Every public method follows: `ParseItems/ParseState → modify → RebuildJSON`

### Public Methods

```xojo
Sub AddItem(name As String, selected As Boolean = False)
  Var items() As String = ParseItems()
  Var state As Dictionary = ParseState()
  items.Add(name)
  state.Value(name) = selected
  RebuildJSON(items, state)
End Sub

Sub RemoveItem(name As String)
  Var items() As String = ParseItems()
  Var state As Dictionary = ParseState()
  For i As Integer = items.LastIndex DownTo 0
    If items(i) = name Then items.RemoveAt(i)
  Next
  If state.HasKey(name) Then state.Remove(name)
  RebuildJSON(items, state)
End Sub

Sub ClearItems()
  mItemsJSON = "[]"
  mStateJSON = "{}"
  UpdateControl
End Sub

Sub SetSelected(name As String, value As Boolean)
Sub SelectAll()
Sub DeselectAll()
Function IsSelected(name As String) As Boolean
Function AllItems() As String()
Function SelectedItems() As String()
Sub SetFromDictionary(d As Dictionary)
Function ToDictionary() As Dictionary
```

### IDE Inspector Properties (Comma-Separated)

For the IDE inspector, comma-separated strings are more user-friendly than raw JSON:

```xojo
#tag ComputedProperty, Flags = &h0
  #tag Getter
    Get
      Var items() As String = ParseItems()
      Return Join(items, ",")
    End Get
  #tag EndGetter
  #tag Setter
    Set
      Var parts() As String = value.Split(",")
      Var jItems As New JSONItem
      Var jState As New JSONItem
      For Each part As String In parts
        Var trimmed As String = part.Trim
        If trimmed <> "" Then
          jItems.Add(trimmed)
          jState.Value(trimmed) = False
        End If
      Next
      mItemsJSON = jItems.ToString
      mStateJSON = jState.ToString
      UpdateControl
    End Set
  #tag EndSetter
  ItemList As String
#tag EndComputedProperty
```

Similarly, `DefaultSelected` parses comma-separated names to set which items are selected.

`Count` is a read-only computed property (getter only, no setter):

```xojo
#tag ComputedProperty, Flags = &h0
  #tag Getter
    Get
      Var items() As String = ParseItems()
      Return items.Count
    End Get
  #tag EndGetter
  Count As Integer
#tag EndComputedProperty
```

---

## ViewBehavior: Controlling the IDE Inspector

ViewBehavior defines which properties appear in the Xojo IDE inspector panel.

### Hiding Properties from Inspector

Set `Visible=false` to hide a property from the inspector while keeping it accessible in code:

```xojo
#tag ViewProperty
  Name="ItemsJSON"
  Visible=false          // Hidden — use ItemList in inspector instead
  Group="Behavior"
  InitialValue="[]"
  Type="String"
  EditorType="MultiLineEditor"
#tag EndViewProperty
```

### Showing Properties in Inspector

```xojo
#tag ViewProperty
  Name="ItemList"
  Visible=true           // Shown — user types "Apple,Banana,Cherry"
  Group="Behavior"
  InitialValue=""
  Type="String"
  EditorType="MultiLineEditor"
#tag EndViewProperty

#tag ViewProperty
  Name="Enabled"
  Visible=true
  Group="Appearance"     // Separate group for visual properties
  InitialValue=""
  Type="Boolean"
  EditorType=""
#tag EndViewProperty
```

### ViewBehavior Groups

Organize properties into logical groups in the inspector:

| Group | Use For |
|---|---|
| `"ID"` | Name, Super, Index |
| `"Position"` | Left, Top, Width, Height, Lock* |
| `"Appearance"` | Enabled, Visible, colors, fonts |
| `"Behavior"` | Data properties, ItemList, DefaultSelected |
| `"Visual Controls"` | TabIndex, Indicator |

### Standard ViewBehavior Properties

Every WebSDKUIControl needs these standard ViewBehavior entries:

```xojo
#tag ViewBehavior
  // Standard properties that every control needs:
  Name="Index"       Visible=true   Group="ID"       Type="Integer"  InitialValue="-2147483648"
  Name="Name"        Visible=true   Group="ID"       Type="String"
  Name="Super"       Visible=true   Group="ID"       Type="String"
  Name="Left"        Visible=true   Group="Position"  Type="Integer"  InitialValue="0"
  Name="Top"         Visible=true   Group="Position"  Type="Integer"  InitialValue="0"
  Name="Width"       Visible=true   Group="Position"  Type="Integer"  InitialValue="320"
  Name="Height"      Visible=true   Group="Position"  Type="Integer"  InitialValue="120"
  Name="LockLeft"    Visible=true   Group="Position"  Type="Boolean"  InitialValue="True"
  Name="LockTop"     Visible=true   Group="Position"  Type="Boolean"  InitialValue="True"
  Name="LockRight"   Visible=true   Group="Position"  Type="Boolean"  InitialValue="False"
  Name="LockBottom"  Visible=true   Group="Position"  Type="Boolean"  InitialValue="False"
  Name="Visible"     Visible=true   Group="Visual Controls" Type="Boolean" InitialValue="True"
  Name="TabIndex"    Visible=true   Group="Visual Controls" Type="Integer"
  Name="Enabled"     Visible=true   Group="Appearance"      Type="Boolean"

  // Hidden framework properties (must be present but not shown):
  Name="PanelIndex"    Visible=false
  Name="_mPanelIndex"  Visible=false  InitialValue="-1"
  Name="_mName"        Visible=false
  Name="ControlID"     Visible=false
  Name="Indicator"     Visible=false
#tag EndViewBehavior
```

---

## Dictionary and JSON Iteration Patterns

### Iterating JSON Arrays

```xojo
Var j As New JSONItem(mItemsJSON)
For i As Integer = 0 To j.Count - 1
  Var item As String = j.ValueAt(i)   // 0-based index access
Next
```

### Iterating JSON Objects

```xojo
Var j As New JSONItem(mStateJSON)
For i As Integer = 0 To j.Count - 1
  Var key As String = j.Name(i)       // Get key by index
  Var b As Boolean = j.Value(key)     // Get value by key
Next
```

### Dictionary Keys Iteration

Dictionary.Keys returns `Variant`, not `String`. Always assign to `Variant` array first:

```xojo
Var keys() As Variant = d.Keys
For Each key As Variant In keys
  Var name As String = key.StringValue
Next
```

### Optional Parameters

Xojo supports default parameter values — useful for convenience methods:

```xojo
Sub AddItem(name As String, selected As Boolean = False)
  // Can be called as:
  // Chips1.AddItem("Apple")          ← selected defaults to False
  // Chips1.AddItem("Apple", True)    ← explicitly set selected
End Sub
```

---

## What Works vs What Doesn't

### WORKS

| Pattern | Example |
|---|---|
| `New JSONItem(jsonString)` in Serialize | `js.Value("items") = New JSONItem(items)` |
| WebFile order: Data → Session → Filename → MIMEType | See above |
| `super.updateControl(data)` called LAST | Custom logic first, super last |
| `position: relative` on root element | In constructor |
| Content in child elements | `el.appendChild(childDiv)` |
| CSS via SharedCSSFile (same WebFile pattern) | Data-first order |
| `try/catch` around updateControl body | Catches silent failures |
| IIFE for closures in `var` loops | `(function(name){return function(){...}})(item)` |
| `#tag Events ControlName` for page events | After `#tag EndWindowCode` |
| Explicit `UpdateControl` after framework property changes | `Chips1.UpdateControl` |
| `replaceChildren()` for efficient DOM clear | `this.listEl.replaceChildren()` |
| Multiple controls sharing one namespace | `WebSDKSamples.Chips` and `WebSDKSamples.Chex` |
| `Visible=false` in ViewBehavior | Hides JSON properties from inspector |
| Comma-separated inspector properties | `ItemList` wraps `ItemsJSON` |
| Read-only computed properties | `Count` with getter only |
| `j.Name(i)` + `j.Value(key)` for object iteration | State JSON parsing |
| `ParseItems/ParseState/RebuildJSON` pattern | Parse → modify → rebuild → UpdateControl |
| Native `<input type="checkbox">` in WebSDK | Chex uses real checkboxes with `accent-color` |
| `<label>` wrapping checkbox + text | Chex items: click label toggles checkbox |

### DOES NOT WORK

| Pattern | What Happens | Fix |
|---|---|---|
| `js.Value("key") = jsonString` (raw JSON string) | Unescaped quotes break `JSON.parse` | Use `New JSONItem(jsonString)` |
| `this.setAttributes()` in render | Silent control death | Remove the call entirely |
| `super.updateControl(data)` called FIRST | Code after super may not execute | Call super LAST |
| WebFile: Filename before Data | JS/CSS file silently fails to load | Data must be first property set |
| Inline styles on root element | Conflicts with framework positioning | Use child elements |
| `#tag EventHandler` with `Sub Control_Event()` | Events never fire | Use `#tag Events ControlName` blocks |
| `g.TextHeight(text)` in layout editor | Compile error, shows warning icon | Use `g.TextHeight` (property, no params) |
| Setting `Enabled` without `UpdateControl` | Browser doesn't reflect change | Call `control.UpdateControl` after |
| Styling bare HTML elements in CSS | Conflicts with Bootstrap 5.3 | Always use scoped class selectors |
| `As New Dictionary` in `#tag Property` | Doesn't initialize properly | Initialize in Constructor or method |

### SILENT FAILURES (The Dangerous Ones)

These produce no error messages — the control simply doesn't render:

1. **Wrong WebFile property order** — JS/CSS never loads, no console error
2. **`this.setAttributes()` in render()** — control dies silently
3. **Raw JSON strings in Serialize** — `JSON.parse` fails at position 499+, hard to diagnose without try/catch
4. **Code after `super.updateControl()`** — silently skipped
5. **Missing `UpdateControl` after property change** — browser shows stale state, no error

---

## Step-by-Step: Building a Control from Scratch

### Phase 1: Hello World (Prove the mechanism)

1. Create class inheriting `WebSDKUIControl`
2. Set `JavaScriptClassName` → `"MyNamespace.MyControl"`
3. Minimal JS: constructor creates a child div with text "Hello World"
4. `SessionJavascriptURLs`: WebFile with Data-first order
5. `DrawControlInLayoutEditor`: simple rectangle with label
6. **Test:** See "Hello World" in browser? Mechanism works.

### Phase 2: Data Flow (Xojo → Browser)

1. Add computed properties with `UpdateControl` in setters
2. `Serialize` event: send properties as JSON (use `New JSONItem()` for nested JSON)
3. JS `updateControl`: parse JSON, read properties, rebuild DOM
4. **Test:** Do property values appear in browser? Data flow works.

### Phase 3: Styling

1. Add `SessionCSSURLs` with SharedCSSFile (Data-first order)
2. Switch JS from inline styles to CSS classes
3. Use BEM-like naming: `.my-control__element.is-state`
4. **Test:** Do styles apply? CSS delivery works.

### Phase 4: Interaction (Browser → Xojo)

1. Add click handlers in JS (use IIFE for closures in `var` loops)
2. `handleToggle`: update state, rebuild DOM, `triggerServerEvent()`
3. `ExecuteEvent`: receive event, update backing field, `RaiseEvent`
4. Add `#tag Hook` for custom event definition
5. **Test:** Does clicking update server state? Event flow works.

### Phase 5: Convenience API

1. Add `ParseItems`, `ParseState`, `RebuildJSON` private helpers
2. Add public methods: `AddItem`, `RemoveItem`, `ClearItems`, etc.
3. Add inspector-friendly properties: `ItemList` (CSV), `Count` (read-only)
4. Configure ViewBehavior: hide JSON properties, show convenience properties
5. **Test:** Do inspector properties work? Does the convenience API round-trip?

### Phase 6: Page Integration

1. Wire events using `#tag Events ControlName` blocks
2. Add button handlers, state displays
3. Remember: `UpdateControl` after changing framework properties
4. **Test:** Full round-trip works.

---

## Debugging Checklist

When your control doesn't render:

1. **Check browser console** — any JS errors?
2. **Add `try/catch`** in `updateControl` — silent parse errors?
3. **Log `data.length`** — is updateControl being called at all?
4. **Log `Object.keys(update)`** — are your custom properties present?
5. **Check WebFile order** — Data first?
6. **Check `super.updateControl(data)`** — is it last?
7. **Check for `this.setAttributes()`** — remove it
8. **Inspect DOM** — is the root `<div>` there? Does it have children?
9. **Check Serialize** — using `New JSONItem()` for JSON values?
10. **Check console for** `UC ERROR:` — the try/catch diagnostic message

---

## Complete File Structure

```
MyProject/
├── MyControl.xojo_code            # The control class
│   ├── DrawControlInLayoutEditor   # IDE preview
│   ├── JavaScriptClassName         # "Namespace.ClassName"
│   ├── Serialize                   # State → JSON
│   ├── ExecuteEvent                # Browser events → Xojo
│   ├── HandleRequest               # Custom HTTP (optional)
│   ├── SessionJavascriptURLs       # JS file delivery
│   ├── SessionCSSURLs              # CSS file delivery
│   ├── SessionHead                 # Raw HTML injection (optional)
│   ├── #tag Hook                   # Custom event definitions
│   ├── Computed Properties         # With UpdateControl in setters
│   │   ├── ItemsJSON / StateJSON   # Raw JSON (Visible=false in inspector)
│   │   ├── ItemList                # CSV wrapper (Visible=true)
│   │   ├── DefaultSelected         # CSV wrapper (Visible=true)
│   │   └── Count                   # Read-only (getter only)
│   ├── Private backing fields      # mPropertyName pattern
│   ├── Private helpers             # ParseItems, ParseState, RebuildJSON
│   ├── Public methods              # AddItem, RemoveItem, etc.
│   ├── Private Shared WebFiles     # SharedJSFile, SharedCSSFile
│   └── ViewBehavior                # IDE property inspector config
│
├── HelperModule.xojo_code          # Shared data (e.g., FruitData)
├── WebPage1.xojo_code              # Example page
│   ├── Begin/End block             # Control instances + layout
│   ├── #tag WindowCode             # Page-level events (Shown, etc.)
│   ├── #tag Events ControlName     # Control event handlers
│   └── #tag ViewBehavior           # Page properties
│
├── App.xojo_code                   # Application class
├── Session.xojo_code               # Session class
└── MyProject.xojo_project          # Project manifest
```

---

## Quick Reference Card

```
SERIALIZE (Xojo → Browser):
  js.Value("simpleValue") = myString           // Simple types: OK
  js.Value("jsonValue") = New JSONItem(json)    // JSON strings: MUST wrap
  js.Value("enabled") = Self.Enabled            // Booleans: OK

WEBFILE ORDER:
  .Data = "..."          // 1st
  .Session = Nil         // 2nd
  .Filename = "name"     // 3rd
  .MIMEType = "type"     // 4th

JS updateControl:
  try { ... } catch(e) { console.log(e) }     // ALWAYS wrap
  super.updateControl(data)                     // ALWAYS last

JS render:
  super.render()                                // First
  this.applyUserStyle()                         // Yes
  this.applyTooltip(el)                         // Yes
  this.setAttributes()                          // ⚠ NEVER

EVENTS (page text format):
  #tag Events ControlName                       // ✓ Correct
    #tag Event
      Sub EventName()
      End Sub
    #tag EndEvent
  #tag EndEvents

  #tag EventHandler                             // ✗ Wrong
    Sub Control_Event()                          // ✗ Wrong
  #tag EndEventHandler                          // ✗ Wrong

TRIGGER UPDATE FROM PAGE CODE:
  Chips1.Enabled = False
  Chips1.UpdateControl                          // ◀── Don't forget!

CONVENIENCE API PATTERN:
  ParseItems() → String()                      // JSON array → Xojo array
  ParseState() → Dictionary                    // JSON object → Dictionary
  RebuildJSON(items, state)                     // Arrays/Dict → JSON → UpdateControl

VIEWBEHAVIOR:
  Visible=true  → appears in IDE inspector
  Visible=false → hidden from inspector, accessible in code
  Group="Behavior" / "Appearance" / "Position" / "ID"

CSS NAMING:
  .{prefix}-{control}__{element}                // .xojo-chips__chip
  .{prefix}-{control}__{element}.is-{state}     // .xojo-chips__chip.is-selected
  Never style bare HTML elements                // Bootstrap owns those
```

---

*This guide was built through iterative debugging of the Chips and Chex controls in April 2026. Every "DON'T" in this document was discovered by doing exactly that and watching it fail silently.*
