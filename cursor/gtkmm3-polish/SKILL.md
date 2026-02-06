---
name: gtkmm3-polish
description: >-
  Polishes gtkmm 3 desktop projects for consistent behavior, look, and code
  organization: shared visual identity, scoped CSS, canonical setup-method
  structure, and sibling parity. Excludes functional logic changes unless noted
  in note.md as an unavoidable side effect.
---

# gtkmm 3: polish (UI, structure, naming)

## When this applies

Use for **gtkmm 3.x** C++ codebases where the goal is parity-quality polish across sibling applications: layout, styling, naming, and code organization. Typical triggers: “polish the UI”, “consistent naming”, “spacing/margins”, “project structure”, “make this app look/work like sibling gtkmm ports”.

**Hard boundary:** do **not** change algorithms, SQL/query text, protocol payloads, file formats, validation rules, or thread semantics.

## Preconditions

- **gtkmm 3 only** (`pkg-config gtkmm-3.0`).
- Run the existing build script after each coherent batch until warning-clean.
- Prefer small reviewable diffs.

## Visual identity and GTK styling

**Industrial GTK:** theme owns colors/fonts/states. Polish aligns geometry and scoped app CSS only.

### What stays default

| GTK widget / pattern | Rule |
|----------------------|------|
| `Gtk::Button`, `Gtk::CheckButton`, `Gtk::Label`, `Gtk::Frame`, `Gtk::Notebook`, `Gtk::MenuBar`, `Gtk::Toolbar`, `Gtk::Separator`, plain `Gtk::SpinButton`, `Gtk::ComboBoxText`, `Gtk::Dialog` chrome | No cosmetic style classes; no per-widget `CssProvider`. |
| `Gtk::TreeView`, `Gtk::TextView` (no custom draw) | Theme default, layout via `Gtk::ScrolledWindow`. |
| `Gtk::TreeView` (exception) | Scoped class allowed only for stable background (`@theme_base_color`) without breaking selected-row readability. No unscoped `treeview` selectors, no `override_*`. If selection becomes unreadable, remove the class or add scoped `:selected` rules with `@theme_selected_bg_color` / `@theme_selected_fg_color`. Never hardcode non-theme selected colors. |
| `Gtk::FileFilter` | `set_name` is filter label only (not styling). |

### Layout numbers

| Place | Setting |
|-------|---------|
| `Gtk::Grid` | `set_row_spacing(6)`, `set_column_spacing(8)`. |
| Notebook page / tight sheet | `set_margin_* (8)`. |
| Dialog outer content / first-level `VBox` | `set_margin_* (12)`. |
| `Gtk::ScrolledWindow` around list/text | `set_policy(AUTOMATIC, AUTOMATIC)`, `set_shadow_type(SHADOW_IN)`, `set_margin_bottom(5)`. |
| Primary single-line editors / combos | `set_hexpand(true)`. |
| Main `Notebook` / `Paned` | `set_hexpand(true)`, `set_vexpand(true)`. |

### Menu bar, toolbar, and panes

- Use **`Gtk::MenuBar`** as first row in main content with mnemonic `Gtk::MenuItem` + `set_use_underline(true)`.
- No custom style classes on `Gtk::MenuBar`.
- If a toolbar is present, build it in a dedicated **`setup_toolbar`** method and place it as the next packed row after `Gtk::MenuBar` in the same main vertical `Gtk::Box`.
- Toolbar should use `Gtk::Toolbar` + `Gtk::ToolButton`/`Gtk::SeparatorToolItem` with theme-default look; no custom classes, border-stripping, or per-widget CSS hacks.
- Keep toolbar icon sizing and spacing consistent across sibling apps (`Gtk::ICON_SIZE_SMALL_TOOLBAR` or existing repo standard).
- Do not replace a real toolbar with ad-hoc `Gtk::Box`+`Gtk::Button` strips unless the product explicitly has no toolbar.
- For 3-column configurators, use nested horizontal `Gtk::Paned`.

### Scoped CSS and provider

1. Remove theme fights (`override_*`, `set_name` for colors, manual RGBA painting).
2. Use one app-wide provider with `Gtk::StyleContext::add_provider_for_screen(...)`.
3. Apply classes via `add_class(...)`; never attach duplicate providers per instance.
4. Keep class names as `constexpr const char`.

## Code organization parity (required)

Sibling gtkmm applications must be consistent in **both behavior and non-functional structure**.

- Implement class methods directly in the class body without namespace qualifiers.
- Main window class must split setup into explicit methods and call them in stable order.
- Preferred method set:
  - `setup_ui`
  - `setup_toolbar` (required when toolbar exists)
  - `setup_menu_bar` / `setup_menus`
  - `setup_signals`
  - `setup_accel_groups` (when used)
  - `setup_data` (after widgets are created)
- If a toolbar exists, a dedicated `setup_toolbar` method is required (do not hide toolbar build inside unrelated methods).
- Keep setup-method naming and responsibility boundaries consistent across sibling ports.

### Main shell (required)

- **`src/<feature>.cpp`**'s `run` method to keep feature's header minimal:

```cpp
int main(int argc, char *argv[]) {
    auto app = Gtk::Application::create(argc, argv, "vendor.<kebab-case feature>-gtk3");
    Feature window(app, argc, argv);
    return app->run(window);
}
```

- **`src/main.cpp`**'s `main` method:

```cpp
int main(int argc, char *argv[]) { run(argc, argv); }
```

### Widget allocation policy (required)

- **Class-wide widgets with stable lifetime** (main controls used across methods/signals) should be value members (`Gtk::Button button_save;`, `Gtk::Toolbar toolbar_main;`) — not heap pointers.
- **Dynamic local child widgets** created during setup should use `Gtk::make_managed<T>(...)` and be added immediately to a parent container.
- Use raw widget pointers only when GTK ownership is external/indirect (e.g. `get_content_area()`), and initialize class pointer members with `nullptr`.
- Avoid mixing ownership styles for the same layer (do not keep both owning pointers and value members for equivalent widgets).

## UI polish (presentational only)

- Keep spacing/margins consistent with this skill’s table.
- **Undocumented geometry cleanup:** any margin/padding/spacing/alignment or visual tweak not documented here must be removed; prefer GTK defaults over ad-hoc offsets.
- Keep strings Russian if project already uses Russian.

## Project structure

- Use `-Iinclude`; headers under `include/<feature>/`.
- Keep window/dialog/UI helper split clear; avoid monolithic UI+logic files when polishing structure.
- Include order: GTK/gtkmm, standard library, project headers.

## Naming and style

- Types: `PascalCase`.
- Functions/methods/locals/params: `snake_case`.
- Members: `snake_case` (trailing `_` when codebase uses it).
- Setup methods should use consistent `setup_*` naming.

## Verification

1. Build with existing script.
2. Smoke run main window and key dialogs.
3. Update `note.md` with non-functional polish and CSS/provider notes.
