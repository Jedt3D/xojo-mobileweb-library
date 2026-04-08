declare const XojoWeb: any;

namespace WebSDKSamples {
    export class Chips extends XojoWeb.XojoVisualControl {
        private items: string[] = [];
        private state: Record<string, boolean> = {};
        private chipsEnabled: boolean = true;
        private listEl: HTMLDivElement | null = null;

        constructor(id: string, events: any) {
            super(id, events);

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

        updateControl(data: string): void {
            super.updateControl(data);

            const update = JSON.parse(data);
            this.items = this.parseItemsJSON(update.itemsJSON);
            this.state = this.normalizeState(this.items, this.parseStateJSON(update.stateJSON));
            this.chipsEnabled = typeof update.enabled === "boolean" ? update.enabled : true;

            this.rebuildChips();
            this.refresh();
        }

        render(): void {
            super.render();
            const el = this.DOMElement();
            if (!el) return;

            this.setAttributes();
            this.applyUserStyle();
            this.applyTooltip(el);
        }

        private rebuildChips(): void {
            if (!this.listEl) return;
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
                this.listEl!.appendChild(chip);
            }
        }

        private handleToggle(item: string, selected: boolean): void {
            this.state = this.normalizeState(
                this.items,
                { ...this.state, [item]: selected }
            );

            const params = new XojoWeb.JSONItem();
            params.set("stateJSON", JSON.stringify(this.state));
            this.triggerServerEvent("SelectionChanged", params, false);

            this.rebuildChips();
        }

        private normalizeState(items: string[], state: Record<string, boolean>): Record<string, boolean> {
            const normalized: Record<string, boolean> = {};
            for (const item of items) {
                normalized[item] = state[item] === true;
            }
            return normalized;
        }

        private parseItemsJSON(itemsJSON: string): string[] {
            if (!itemsJSON) return [];
            try {
                const parsed = JSON.parse(itemsJSON);
                if (!Array.isArray(parsed)) return [];
                const seen = new Set<string>();
                const items: string[] = [];
                for (const entry of parsed) {
                    if (typeof entry !== "string") continue;
                    if (seen.has(entry)) continue;
                    seen.add(entry);
                    items.push(entry);
                }
                return items;
            } catch {
                return [];
            }
        }

        private parseStateJSON(stateJSON: string): Record<string, boolean> {
            if (!stateJSON) return {};
            try {
                const parsed = JSON.parse(stateJSON);
                if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) return {};
                const state: Record<string, boolean> = {};
                for (const key in parsed) {
                    if (!Object.prototype.hasOwnProperty.call(parsed, key)) continue;
                    state[key] = parsed[key] === true;
                }
                return state;
            } catch {
                return {};
            }
        }
    }
}
