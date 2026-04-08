# Chips WebSDK Control Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a self-contained Xojo WebSDK visual control that renders toggleable chips with checkboxes, backed by TypeScript, returning selection state as JSON.

**Architecture:** TypeScript-first build. Write `src/Chips.ts` using the `XojoWeb.XojoVisualControl` base class, compile to `dist/Chips.js`, then embed the compiled JS and CSS as string constants inside the Xojo `Chips` class. The Xojo class serializes item/state data as JSON, the browser renders chips and fires `SelectionChanged` events back.

**Tech Stack:** TypeScript (ES2015 target), Xojo WebSDK (`WebSDKUIControl` / `XojoWeb.XojoVisualControl`), vanilla DOM APIs, CSS (BEM naming).

---

## File Structure

```
ChipsClaude/
├── src/
│   ├── Chips.ts              # CREATE — browser-side control logic
│   └── XojoWebSDK.d.ts       # CREATE — WebSDK type definitions (copied from Bootstrap Toast example)
├── dist/
│   └── Chips.js              # GENERATED — compiled TypeScript output
├── package.json              # CREATE — minimal, typescript devDependency
├── tsconfig.json             # CREATE — ES2015, strict, module: none
├── App.xojo_code             # CREATE — minimal Xojo app shell
├── Build Automation.xojo_code # CREATE — standard build steps
├── Chips.xojo_code           # CREATE — WebSDK control with embedded kJSCode + kCSS
├── Chips.xojo_project        # CREATE — project manifest
├── Session.xojo_code         # CREATE — session boilerplate
└── WebPage1.xojo_code        # CREATE — demo page with Chips1, toggle button, state preview
```

---

### Task 1: Set Up TypeScript Toolchain

**Files:**
- Create: `package.json`
- Create: `tsconfig.json`
- Create: `src/XojoWebSDK.d.ts`

- [ ] **Step 1: Create `package.json`**

```json
{
  "name": "chips-websdk-example",
  "private": true,
  "scripts": {
    "build": "tsc -p tsconfig.json"
  },
  "devDependencies": {
    "typescript": "^5.8.3"
  }
}
```

- [ ] **Step 2: Create `tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2015",
    "module": "none",
    "rootDir": "src",
    "outDir": "dist",
    "removeComments": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": [
    "src/Chips.ts",
    "src/XojoWebSDK.d.ts"
  ]
}
```

Key settings: `module: "none"` so the output is a plain IIFE namespace (no require/import), `rootDir: "src"` so output mirrors source structure, `removeComments: true` for smaller embedded output.

- [ ] **Step 3: Create `src/XojoWebSDK.d.ts`**

Copy the file from `Examples/Bootstrap Toast/typescript/XojoWebSDK.d.ts`. This provides type definitions for `XojoWeb.XojoVisualControl`, `XojoWeb.JSONItem`, and other WebSDK classes.

```bash
mkdir -p src
cp "../Examples/Bootstrap Toast/typescript/XojoWebSDK.d.ts" src/XojoWebSDK.d.ts
```

- [ ] **Step 4: Install dependencies**

```bash
npm install
```

Expected: `node_modules/` created with TypeScript compiler.

- [ ] **Step 5: Verify toolchain works**

Create a minimal placeholder `src/Chips.ts`:

```typescript
namespace WebSDKSamples {
    export class Chips extends XojoWeb.XojoVisualControl {
        constructor(id: string, events: string[]) {
            super(id, events);
        }
    }
}
```

Run:

```bash
npx tsc -p tsconfig.json
```

Expected: `dist/Chips.js` created without errors.

- [ ] **Step 6: Commit**

```bash
git add package.json tsconfig.json src/XojoWebSDK.d.ts src/Chips.ts dist/Chips.js
git commit -m "chips: set up TypeScript toolchain with WebSDK type definitions"
```

---

### Task 2: Implement TypeScript Control — State Management

**Files:**
- Modify: `src/Chips.ts`

This task adds the internal state model and JSON parsing methods. No rendering yet.

- [ ] **Step 1: Define types and state fields**

Replace `src/Chips.ts` with:

```typescript
namespace WebSDKSamples {
    type ChipsUpdate = {
        itemsJSON?: string;
        stateJSON?: string;
        enabled?: boolean;
    };

    type ChipsState = Record<string, boolean>;

    export class Chips extends XojoWeb.XojoVisualControl {
        private items: string[] = [];
        private state: ChipsState = {};
        private chipsEnabled = true;

        constructor(id: string, events: string[]) {
            super(id, events);
        }

        private normalizeState(items: string[], state: ChipsState): ChipsState {
            const normalized: ChipsState = {};

            for (const item of items) {
                normalized[item] = state[item] === true;
            }

            return normalized;
        }

        private parseItemsJSON(itemsJSON?: string): string[] {
            if (!itemsJSON) {
                return [];
            }

            try {
                const parsed = JSON.parse(itemsJSON) as unknown;
                if (!Array.isArray(parsed)) {
                    return [];
                }

                const seen = new Set<string>();
                const items: string[] = [];

                for (const entry of parsed) {
                    if (typeof entry !== "string") {
                        continue;
                    }

                    if (seen.has(entry)) {
                        continue;
                    }

                    seen.add(entry);
                    items.push(entry);
                }

                return items;
            } catch {
                return [];
            }
        }

        private parseStateJSON(stateJSON?: string): ChipsState {
            if (!stateJSON) {
                return {};
            }

            try {
                const parsed = JSON.parse(stateJSON) as unknown;
                if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
                    return {};
                }

                const state: ChipsState = {};
                const parsedState = parsed as Record<string, unknown>;
                for (const key in parsedState) {
                    if (!Object.prototype.hasOwnProperty.call(parsedState, key)) {
                        continue;
                    }

                    state[key] = parsedState[key] === true;
                }

                return state;
            } catch {
                return {};
            }
        }
    }
}
```

- [ ] **Step 2: Compile and verify**

```bash
npx tsc -p tsconfig.json
```

Expected: `dist/Chips.js` generated without errors.

- [ ] **Step 3: Commit**

```bash
git add src/Chips.ts dist/Chips.js
git commit -m "chips: add state model with JSON parsing and normalization"
```

---

### Task 3: Implement TypeScript Control — updateControl and Event Handling

**Files:**
- Modify: `src/Chips.ts`

This task wires up the `updateControl` method (receives data from Xojo) and `handleToggle` (sends events back to Xojo). Still no rendering.

- [ ] **Step 1: Add `updateControl` method**

Add this method to the `Chips` class, after the constructor:

```typescript
        updateControl(data: string): void {
            super.updateControl(data);

            const update = JSON.parse(data) as ChipsUpdate;
            const items = this.parseItemsJSON(update.itemsJSON);
            const state = this.parseStateJSON(update.stateJSON);

            this.items = items;
            this.state = this.normalizeState(items, state);
            this.chipsEnabled = typeof update.enabled === "boolean" ? update.enabled : this.enabled;
            this.refresh();
        }
```

- [ ] **Step 2: Add `handleToggle` method**

Add this private method after the `updateControl` method:

```typescript
        private handleToggle(item: string, selected: boolean): void {
            this.state = this.normalizeState(this.items, {
                ...this.state,
                [item]: selected
            });

            const params = new XojoWeb.JSONItem();
            params.set("stateJSON", JSON.stringify(this.state));
            this.triggerServerEvent("SelectionChanged", params, false);
            this.refresh();
        }
```

- [ ] **Step 3: Compile and verify**

```bash
npx tsc -p tsconfig.json
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add src/Chips.ts dist/Chips.js
git commit -m "chips: add updateControl and handleToggle event wiring"
```

---

### Task 4: Implement TypeScript Control — Rendering

**Files:**
- Modify: `src/Chips.ts`

This task adds the `render()` method that builds the chip DOM.

- [ ] **Step 1: Add `render` method**

Add this method after `updateControl`:

```typescript
        render(): void {
            super.render();

            const root = this.DOMElement("");
            if (!root) {
                return;
            }

            root.replaceChildren();
            root.classList.add("xojo-chips");
            root.setAttribute("role", "group");
            root.setAttribute("aria-label", "Selectable chips");

            const list = document.createElement("div");
            list.className = "xojo-chips__list";

            for (const item of this.items) {
                const chip = document.createElement("label");
                chip.className = "xojo-chips__chip";

                const selected = this.state[item] === true;
                chip.classList.toggle("is-selected", selected);
                chip.classList.toggle("is-disabled", !this.chipsEnabled);

                const checkbox = document.createElement("input");
                checkbox.type = "checkbox";
                checkbox.checked = selected;
                checkbox.disabled = !this.chipsEnabled;
                checkbox.addEventListener("change", () => {
                    this.handleToggle(item, checkbox.checked);
                });

                const label = document.createElement("span");
                label.className = "xojo-chips__label";
                label.textContent = item;

                chip.append(checkbox, label);
                list.appendChild(chip);
            }

            root.appendChild(list);
            this.applyTooltip(root);
            this.applyUserStyle(root);
        }
```

- [ ] **Step 2: Compile and verify**

```bash
npx tsc -p tsconfig.json
```

Expected: No errors. `dist/Chips.js` now contains the full browser-side control.

- [ ] **Step 3: Verify the compiled output**

Read `dist/Chips.js` and confirm:
- It wraps in a `var WebSDKSamples;` IIFE
- The class extends `XojoWeb.XojoVisualControl`
- No `require()` or `import` statements (since `module: "none"`)
- Comments are stripped

- [ ] **Step 4: Commit**

```bash
git add src/Chips.ts dist/Chips.js
git commit -m "chips: add render method with chip DOM construction"
```

---

### Task 5: Build the Xojo Control Class

**Files:**
- Create: `Chips.xojo_code`

This is the core Xojo file. It embeds the compiled JS and CSS as string constants and implements the WebSDK control interface.

- [ ] **Step 1: Read the compiled `dist/Chips.js`**

You will need the full content of `dist/Chips.js` to embed as the `kJSCode` constant. Read it now.

- [ ] **Step 2: Create `Chips.xojo_code`**

The file must include:
- Class declaration: `Protected Class Chips` inheriting `WebSDKUIControl`
- Event `DrawControlInLayoutEditor(g As Graphics)` — draws 3 sample chips as rounded rectangles with checkbox circles and text labels. Uses colors: background `&cF8FAFC`, border `&cE2E8F0`, selected circle `&c1D4ED8`, text `&c0F172A`, label "Selectable Chips" at bottom in `&c475569`. When disabled, set `g.Transparency = 50`.
- Event `ExecuteEvent(name As String, parameters As JSONItem) As Boolean` — case-insensitive match on `"selectionchanged"`, reads `parameters.Lookup("stateJSON", "{}")` into `mStateJSON`, returns `True`.
- Event `HandleRequest(request As WebRequest, response As WebResponse) As Boolean` — empty body, implemented so end-users don't see it.
- Event `JavaScriptClassName() As String` — returns `"WebSDKSamples.Chips"`.
- Event `Serialize(js As JSONItem)` — sets `js.Value("itemsJSON")`, `js.Value("stateJSON")`, `js.Value("enabled")`. Defaults empty strings to `"[]"` and `"{}"`.
- Event `SessionCSSURLs(session As WebSession) As String()` — creates shared `WebFile` from `kCSS` constant with filename `"chips.css"` and MIME `"text/css"`.
- Event `SessionJavascriptURLs(session As WebSession) As String()` — creates shared `WebFile` from `kJSCode` constant with filename `"Chips.js"` and MIME `"text/javascript"`.
- Event `SessionHead(session As WebSession) As String` — empty body.
- Private properties: `mItemsJSON As String`, `mStateJSON As String`, `Shared SharedJSFile As WebFile`, `Shared SharedCSSFile As WebFile`.
- Computed property `ItemsJSON As String` — getter returns `mItemsJSON`, setter sets `mItemsJSON = value` then calls `UpdateBrowser`.
- Computed property `StateJSON As String` — getter returns `mStateJSON`, setter sets `mStateJSON = value` then calls `UpdateBrowser`.
- Constant `kCSS As String` with value:

```
.xojo-chips{display:block;width:100%;}.xojo-chips__list{display:flex;flex-wrap:wrap;gap:.75rem;align-items:center;}.xojo-chips__chip{display:inline-flex;align-items:center;gap:.5rem;padding:.5rem .875rem;border:1px solid #cbd5e1;border-radius:999px;background:#f8fafc;color:#0f172a;cursor:pointer;font-size:.95rem;line-height:1.2;user-select:none;}.xojo-chips__chip:hover{background:#eef2ff;border-color:#818cf8;}.xojo-chips__chip.is-selected{background:#1d4ed8;border-color:#1d4ed8;color:#fff;}.xojo-chips__chip.is-disabled{opacity:.65;cursor:not-allowed;}.xojo-chips__chip input{width:1rem;height:1rem;margin:0;accent-color:currentColor;}.xojo-chips__chip.is-selected input{accent-color:#fff;}.xojo-chips__label{white-space:nowrap;}
```

- Constant `kJSCode As String` — paste the full content of `dist/Chips.js` here.
- ViewBehavior section with properties: `PanelIndex`, `_mPanelIndex` (initial `-1`), `Height` (initial `120`), `Width` (initial `320`), `LockBottom` (False), `LockHorizontal` (False), `LockLeft` (True), `LockRight` (False), `LockTop` (True), `LockVertical` (False), `TabIndex`, `Visible` (True), `Indicator` (enum 0-9), `Index`, `Name`, `Super`, `Left`, `Top`, `_mName`, `ControlID`, `Enabled` (True), `ItemsJSON` (initial `[]`, MultiLineEditor), `StateJSON` (initial `{}`, MultiLineEditor).

Use the existing `Chips/Chips.xojo_code` as a structural reference for exact Xojo text-project formatting (the `#tag` structure, property declarations, view behaviors).

- [ ] **Step 3: Verify formatting**

Confirm:
- All `#tag` blocks are properly opened and closed
- `kJSCode` constant contains the full compiled JS with escaped newlines (`\n`)
- `kCSS` constant is a single-line minified CSS string
- ViewBehavior properties match the spec (Height=120, Width=320)

- [ ] **Step 4: Commit**

```bash
git add Chips.xojo_code
git commit -m "chips: create Xojo WebSDK control with embedded JS and CSS"
```

---

### Task 6: Build Supporting Xojo Files

**Files:**
- Create: `App.xojo_code`
- Create: `Session.xojo_code`
- Create: `Build Automation.xojo_code`

- [ ] **Step 1: Create `App.xojo_code`**

```
#tag Class
Protected Class App
Inherits WebApplication
	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
```

- [ ] **Step 2: Create `Session.xojo_code`**

Use the exact content from `Chips/Session.xojo_code` — this is standard boilerplate. It's a `Protected Class Session Inherits WebSession` with the standard session settings block and ViewBehavior properties.

Copy from the existing file:

```bash
cp "../Chips/Session.xojo_code" Session.xojo_code
```

- [ ] **Step 3: Create `Build Automation.xojo_code`**

```
#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin SignProjectStep Sign
				  DeveloperID=
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Xojo Cloud
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
```

- [ ] **Step 4: Commit**

```bash
git add App.xojo_code Session.xojo_code "Build Automation.xojo_code"
git commit -m "chips: add App, Session, and Build Automation boilerplate"
```

---

### Task 7: Build the Demo Page

**Files:**
- Create: `WebPage1.xojo_code`

- [ ] **Step 1: Create `WebPage1.xojo_code`**

The demo page contains these controls (use the existing `Chips/WebPage1.xojo_code` as a structural reference for exact Xojo formatting):

**Page settings:**
- Title: `"Chips Control Example"`
- Width: 720, Height: 560, MinimumWidth: 720, MinimumHeight: 560
- ImplicitInstance: True

**Controls:**

1. **`DescriptionLabel`** (WebLabel)
   - Left: 20, Top: 20, Width: 680, Height: 66
   - Multiline: True
   - Text: `"This example shows a visual WebSDK control that renders a selectable list of chips. Each chip includes a checkbox, and the current selection state is returned as a JSON object map."`
   - TabIndex: 0

2. **`Chips1`** (Chips)
   - Left: 20, Top: 104, Width: 680, Height: 120
   - Enabled: True
   - ItemsJSON: `["Apple","Banana","Coconut","Durian","Eggplant","Fig"]` (escaped as `[""Apple"",""Banana"",""Coconut"",""Durian"",""Eggplant"",""Fig""]` in Xojo text format)
   - StateJSON: `{"Apple":true,"Banana":false,"Coconut":true,"Durian":false,"Eggplant":false,"Fig":true}` (escaped with `""` for each `"`)
   - TabIndex: 1

3. **`ToggleEnabledButton`** (WebButton)
   - Left: 20, Top: 244, Width: 140, Height: 38
   - Caption: `"Disable Chips"`
   - TabIndex: 2

4. **`StateLabel`** (WebLabel)
   - Left: 20, Top: 304, Width: 220, Height: 24
   - Bold: True
   - Text: `"Current State JSON"`
   - TabIndex: 3

5. **`StatePreviewTextArea`** (WebTextArea)
   - Left: 20, Top: 336, Width: 680, Height: 180
   - ReadOnly: True
   - Text: initial StateJSON value (same as Chips1's StateJSON)
   - TabIndex: 4

**No event handlers in WebPage1's WindowCode section** — Xojo event handlers are defined via the IDE and stored differently than what we can represent in the text project format. The page will display correctly but event wiring (ToggleEnabledButton.Pressed, Chips1.SelectionChanged) needs to be connected in the Xojo IDE.

**Important:** Copy the exact structure from `Chips/WebPage1.xojo_code` to ensure proper Xojo text-project formatting, including all ViewBehavior blocks.

- [ ] **Step 2: Verify control layout**

Confirm:
- All 5 controls are present with correct positions
- ItemsJSON and StateJSON use `""` escaping for quotes
- TabIndex values are sequential (0-4)
- Page dimensions are 720x560

- [ ] **Step 3: Commit**

```bash
git add WebPage1.xojo_code
git commit -m "chips: add demo page with Chips control, toggle button, and state preview"
```

---

### Task 8: Create Project File

**Files:**
- Create: `Chips.xojo_project`

- [ ] **Step 1: Create `Chips.xojo_project`**

```
Type=Web2
RBProjectVersion=2025.031
MinIDEVersion=20200200
OrigIDEVersion=20250301
Class=App;App.xojo_code;&h000000003B52BFFF;&h0000000000000000;false
WebSession=Session;Session.xojo_code;&h000000004EF57FFF;&h0000000000000000;false
Class=Chips;Chips.xojo_code;&h0000000063A66FFF;&h0000000000000000;false
WebView=WebPage1;WebPage1.xojo_code;&h000000004B3DC7FF;&h0000000000000000;false
BuildSteps=Build Automation;Build Automation.xojo_code;&h0000000029C44FFF;&h0000000000000000;false
DefaultWindow=WebPage1
MajorVersion=1
MinorVersion=0
SubVersion=0
NonRelease=0
Release=0
InfoVersion=
LongVersion=
ShortVersion=
WinCompanyName=worajedt
WinInternalName=
WinProductName=
WinFileDescription=
AutoIncrementVersionInformation=False
BuildFlags=&h8100
BuildLanguage=&h0
DebugLanguage=&h0
Region=
WindowsName=Chips.exe
MacCarbonMachName=Chips
LinuxX86Name=Chips
MacCreator=
MDI=0
MDICaption=
DefaultEncoding=&h0
AppIcon=Chips.xojo_resources;&h0
OSXBundleID=com.worajedt.chips
DebuggerCommandLine=
UseGDIPlus=False
UseBuildsFolder=True
HiDPI=True
DarkMode=True
CopyRedistNextToWindowsEXE=False
IncludePDB=False
WinUIFramework=False
NativeWinUISizes=False
IsWebProject=True
WebDebugPort=8080
WebLaunchBrowser=True
WebLivePort=-1
WebSecurePort=-1
WebProtocol=1
WebHTMLHeader=
WebHostingIdentifier=
WebHostingAppName=Chips
WebHostingDomain=
LinuxBuildArchitecture=1
MacBuildArchitecture=4
WindowsBuildArchitecture=1
OptimizationLevel=0
WindowsVersions=
WindowsRunAs=0
MacOSMinimumVersion=
```

The hex IDs (`&h...`) must match the existing Chips project to ensure Xojo can open the project consistently. These are copied from `Chips/Chips.xojo_project`.

- [ ] **Step 2: Commit**

```bash
git add Chips.xojo_project
git commit -m "chips: add Xojo project file"
```

---

### Task 9: Final Build Verification

**Files:**
- No new files

- [ ] **Step 1: Clean rebuild TypeScript**

```bash
rm -rf dist
npx tsc -p tsconfig.json
```

Expected: `dist/Chips.js` regenerated without errors.

- [ ] **Step 2: Verify all project files exist**

```bash
ls -la App.xojo_code "Build Automation.xojo_code" Chips.xojo_code Chips.xojo_project Session.xojo_code WebPage1.xojo_code src/Chips.ts src/XojoWebSDK.d.ts dist/Chips.js package.json tsconfig.json
```

Expected: All 11 files present.

- [ ] **Step 3: Verify `kJSCode` constant in `Chips.xojo_code` matches `dist/Chips.js`**

Read both and confirm the content matches (accounting for Xojo string escaping — `\n` for newlines, doubled quotes if any).

- [ ] **Step 4: Verify `kCSS` constant in `Chips.xojo_code`**

Confirm it contains the minified CSS string with all 9 CSS rules:
1. `.xojo-chips` — display block
2. `.xojo-chips__list` — flex-wrap
3. `.xojo-chips__chip` — inline-flex, pill shape
4. `.xojo-chips__chip:hover` — indigo highlight
5. `.xojo-chips__chip.is-selected` — blue background
6. `.xojo-chips__chip.is-disabled` — opacity, cursor
7. `.xojo-chips__chip input` — checkbox sizing
8. `.xojo-chips__chip.is-selected input` — white accent
9. `.xojo-chips__label` — nowrap

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "chips: final build verification — all files in place"
```
