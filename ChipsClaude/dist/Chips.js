"use strict";
var WebSDKSamples;
(function (WebSDKSamples) {
    class Chips extends XojoWeb.XojoVisualControl {
        constructor(id, events) {
            super(id, events);
            this.items = [];
            this.state = {};
            this.chipsEnabled = true;
            const el = this.DOMElement();
            if (el) {
                el.classList.add("xojo-chips");
                el.setAttribute("role", "group");
                el.setAttribute("aria-label", "Selectable chips");
                this.listEl = document.createElement("div");
                this.listEl.className = "xojo-chips__list";
                el.appendChild(this.listEl);
            }
        }
        updateControl(data) {
            super.updateControl(data);
            const update = JSON.parse(data);
            this.items = this.parseItemsJSON(update.itemsJSON);
            this.state = this.normalizeState(this.items, this.parseStateJSON(update.stateJSON));
            this.chipsEnabled = typeof update.enabled === "boolean" ? update.enabled : true;
            this.rebuildChips();
            this.refresh();
        }
        render() {
            super.render();
            const el = this.DOMElement();
            if (!el)
                return;
            this.setAttributes();
            this.applyUserStyle();
            this.applyTooltip(el);
        }
        rebuildChips() {
            if (!this.listEl)
                return;
            this.listEl.replaceChildren();
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
                this.listEl.appendChild(chip);
            }
        }
        handleToggle(item, selected) {
            this.state = this.normalizeState(this.items, Object.assign(Object.assign({}, this.state), { [item]: selected }));
            const params = new XojoWeb.JSONItem();
            params.set("stateJSON", JSON.stringify(this.state));
            this.triggerServerEvent("SelectionChanged", params, false);
            this.rebuildChips();
        }
        normalizeState(items, state) {
            const normalized = {};
            for (const item of items) {
                normalized[item] = state[item] === true;
            }
            return normalized;
        }
        parseItemsJSON(itemsJSON) {
            if (!itemsJSON)
                return [];
            try {
                const parsed = JSON.parse(itemsJSON);
                if (!Array.isArray(parsed))
                    return [];
                const seen = new Set();
                const items = [];
                for (const entry of parsed) {
                    if (typeof entry !== "string")
                        continue;
                    if (seen.has(entry))
                        continue;
                    seen.add(entry);
                    items.push(entry);
                }
                return items;
            }
            catch (_a) {
                return [];
            }
        }
        parseStateJSON(stateJSON) {
            if (!stateJSON)
                return {};
            try {
                const parsed = JSON.parse(stateJSON);
                if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed))
                    return {};
                const state = {};
                for (const key in parsed) {
                    if (!Object.prototype.hasOwnProperty.call(parsed, key))
                        continue;
                    state[key] = parsed[key] === true;
                }
                return state;
            }
            catch (_a) {
                return {};
            }
        }
    }
    WebSDKSamples.Chips = Chips;
})(WebSDKSamples || (WebSDKSamples = {}));
