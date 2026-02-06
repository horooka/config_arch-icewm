---
name: delphi-to-gtkmm3
description: >-
  Ports VCL Delphi to C++17 gtkmm 3: programmatic UI, parity with menus, dialogs,
  stores, timers, threads, and I/O. Canonical layout (thin main, include/<feature>/,
  widgets + I/O split), sibling GUI rules (grid spacing, SHADOW_IN, prefixed CSS),
  Russian UI/comments, RED OS / Astra / ALT, GResource icons. Use for Delphi,
  VCL, .dfm, gtkmm 3, GTK 3 migration on Linux.
---

# Delphi → gtkmm 3 porting

## When this applies

**VCL-oriented Delphi** (`.dpr`, `.pas`, `.dfm`, events) on **gtkmm 3.x** and **C++17**. FireMonkey or Pascal-only with no UI is out of scope unless the user explicitly widens scope.

## Delphi source (what you port from)

- **Layout**: `.dfm` + unit — treat as the visual spec; **logic** in `.pas` (handlers, validation, I/O).
- **Semantics**: map **events** (`OnClick`, `OnChange`, grids, timers) and **Caption/Hint**; preserve meaning, not control names.
- **Assets**: note icon roles (toolbar, tree, dialog); **PNG licensing** is the programmer’s problem (see Icons).

- **Common configurators**: one **main shell**, several **dialogs**, **XML or list files** for data the UI edits, optional **DB / server** settings — inventory **`.dpr`**, each **`.dfm`**, and **non-UI** units (XML, encoding, SQL client code, sockets) before mapping to gtkmm.

## Ported Linux repo (what you produce)

Match **sibling gtkmm 3 ports** from the same product line for **build layout**, **include paths**, and **GUI metrics** (this skill defines the conventions; no specific repository name is required).

### Build and stack

- **Script** at repo root: **`glib-compile-resources --generate-source`** → e.g. `icons_resource.c`; then **`g++`** with explicit **`src/*.cpp`** + generated sources, **`-Iinclude`**, **`pkg-config --cflags --libs gtkmm-3.0`**, **`-std=c++17`**, **`-Wall -Wextra`**. Per-distro differences → **separate scripts**, not fragile `if` chains (see **Target Linux distributions**).
- **gtkmm 3 only** — do not mix **gtkmm 4**.
- **Dependencies**: distro packages (dev headers, compiler); **do not** assume Flatpak as the default build or ship path.

### Tree layout

- **`icons.gresource.xml`**: stable URI prefix (e.g. `/org/icons/…`); regenerate C when XML or PNGs change.
- **`-Iinclude`**: app headers in **`include/<feature>/`** (kebab-case, matches project name). Vendored C++ in **`include/<library>/`**. C SDK headers at **`include/`** root only when upstream paths require it.

### Source roles (names flexible)

| Role | Typical paths |
|------|-----------------|
| Entry | **`src/main.cpp`** — `Gtk::Application::create(argc, argv, app_id)`, construct window, `return app->run(window)`; CLI hooks as **window methods**, not fat `main`. |
| Main shell | **`src/<feature>.cpp`** + **`include/<feature>/<feature>.hpp`** — `Gtk::ApplicationWindow`, menu, toolbar, panes, status. |
| Dialogs | **`src/pick_dialogs.cpp`** (+ header); split TUs if a dialog grows large. |
| I/O / domain | **`src/<domain>_list_io.cpp`**, **`queries.cpp`**, **`utils.cpp`** — XML, KeyFile, SQL, encoding; **avoid constructing widgets** here. |
| Shared UI | **`include/<feature>/widgets.hpp`** (or `.cpp/.hpp`) — composites (`TreeView` subclasses, date/time controls), **scoped app CSS classes** + **single** `add_provider_for_screen` install (see § **Visual identity**). |

- **Includes**: granular **`#include <gtkmm/…>`** in large TUs; **`#include <gtkmm.h>`** only in small shared headers if it clearly helps.
- **`Gtk::Application` id**: stable reverse-DNS (e.g. **`vendor.<kebak-case feature>-gtk3`**)
- **UI**: build in C++ (`Gtk::make_managed`, `pack_start`, `set_*`). **No Glade `.ui` / Builder** as the primary definition.

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

### Feature class organization (required)

- Implement class methods directly in the class body without namespace qualifiers.
- Keep window construction split into explicit `setup_*` methods with stable order.
- Minimum recommended set for sibling parity:
  - `setup_ui`
  - `setup_toolbar` (if exists)
  - `setup_menu_bar` (if exists)
  - `setup_signals`
  - `setup_accel_groups` (if exists)
  - `setup_data`
- Do not mix toolbar construction into unrelated methods; keep `setup_toolbar` dedicated so sibling gtkmm apps stay structurally consistent.

### Widget allocation policy (required)

- **Main-window/class-wide widgets** should be value members with deterministic lifetime (preferred over owning heap pointers).
- **Locally created child widgets** should use `Gtk::make_managed<T>(...)` and be attached to a parent immediately.
- Use pointer members only when nullable semantics are required; initialize such members with `nullptr`.
- Non-owning pointers obtained from GTK APIs (`get_content_area()`, etc.) are allowed as local variables; do not store them as owning state.

## Template code usage

Template file at /home/snusoed/.config/xtemplate.txt provides **templates** for boilerplate utility functions like tinyxml2, glibkeyfile, tinyjson **configurations read-write** (`tinyxml2 read-write`,  `glibkeyfile read-write`, `tinyjson read-write`) and `cp1251_to_utf8` for legacy encoding translation

## Visual identity and GTK styling

**Industrial GTK**: the **active theme** owns colors, fonts, and states. Ports only enforce **geometry** (margins, expand, scroll chrome) and a **small, identical CSS sheet** for widgets that **deliberately** break default look (e.g. invisible caret on masked date/time fields).

### What stays 100 % default (no CSS, no `override_*`, no `set_name` for theming)

| GTK widget / pattern | Rule |
|----------------------|------|
| `Gtk::Button`, `Gtk::CheckButton`, `Gtk::Label`, `Gtk::Frame`, `Gtk::Notebook`, `Gtk::MenuBar`, `Gtk::Toolbar`, `Gtk::Separator`, plain `Gtk::SpinButton` (numeric arrows only), `Gtk::ComboBoxText`, `Gtk::Dialog` chrome | No `StyleContext` cosmetic classes; no per-widget `CssProvider`. |
| `Gtk::TreeView`, `Gtk::TextView` (no custom draw) | Theme only; layout via parent `Gtk::ScrolledWindow` (see below). |
| `Gtk::TreeView` (enterprise exception) | If visual parity requires a controlled list background, allow a **scoped app-specific class** on the specific tree (e.g. `add_class("treeview-bg")`) with theme token CSS only (e.g. `background-color: @theme_base_color;`) **without overriding selection readability**. No `override_*`, no unscoped `treeview` selectors. If selected rows become unreadable, remove the class or add scoped `:selected` rules using `@theme_selected_bg_color` / `@theme_selected_fg_color`; never hardcode non-theme selected colors. |
| `Gtk::FileFilter` | `set_name` is the **filter label** in the chooser — **not** CSS; use a clear user string (e.g. `XML`). |

### Layout numbers (same in every sibling repo)

| Place | Setting |
|-------|---------|
| `Gtk::Grid` | `set_row_spacing(6)`, `set_column_spacing(8)`. |
| Notebook page / tight property sheet | `set_margin_* (8)` on the page container. |
| Dialog outer content / first-level `VBox` | `set_margin_* (12)`. |
| `Gtk::ScrolledWindow` around list or `TextView` | `set_policy(AUTOMATIC, AUTOMATIC)`, `set_shadow_type(SHADOW_IN)`, `set_margin_bottom(5)` on scroller **or** tree so the **last row clears the horizontal scrollbar**. |
| Primary single-line editors / combos / path rows | `set_hexpand(true)`. |
| Main `Notebook` / `Paned` | `set_hexpand(true)`, `set_vexpand(true)` where Delphi used **alClient**. |

### Application menu bar (Файл / Правка / Сервис / …)

- Prefer **`Gtk::MenuBar`** as the **first packed row** of the main vertical `Gtk::Box` (under the window title, above any toolbar), with top-level **`Gtk::MenuItem`**, label with a mnemonic prefix (`"_"` before a letter) and **`set_use_underline(true)`** (or the **`MenuItem(ustring, bool)`** constructor), then **`set_submenu(Gtk::Menu)`** — align with other **sibling** gtkmm 3 apps in the same product line.
- **Do not** build a “menu strip” from **`Gtk::MenuButton`** inside **`Gtk::HeaderBar`** and then use custom borderless/transparent CSS to force a look — that **fights the active theme** and no longer matches default GTK menu appearance. **`Gtk::MenuBar`** stays **unclassed** for styling (see table above).
- A **`Gtk::HeaderBar`** is fine for **title** and **genuine** header actions; it is the wrong place for traditional main menus.

### Application toolbar (main window)

- If command actions exist (save/add/delete/open/help), implement a real **`Gtk::Toolbar`** in dedicated **`setup_toolbar`**; do not emulate toolbar with plain `Gtk::Box` rows unless product design explicitly has no toolbar.
- Pack toolbar as a separate row directly below `Gtk::MenuBar` in the same main vertical container.
- Use `Gtk::ToolButton`/`Gtk::SeparatorToolItem`, keep action/icon semantics, and keep icon sizing consistent (`Gtk::ICON_SIZE_SMALL_TOOLBAR` or project convention).
- Keep toolbar theme-default: no custom style classes, no border-reset CSS, no per-widget `CssProvider`.

### Triple pane layout (left / center / right)

- For classic 3-column configurators, use **nested `Gtk::Paned`** (horizontal):
  - outer paned: `pack1(left_panel, false, false)` + `pack2(inner_paned, true, true)`
  - inner paned: `pack1(center_panel, true, false)` + `pack2(right_panel, false, false)`
- Set initial splitter positions with `set_position(...)` from known width constants; keep both paneds `set_hexpand(true)` and `set_vexpand(true)`.
- Prefer this over ad-hoc separator logic in `Gtk::Grid`, because native paned handles are theme-consistent and lower maintenance.

### Non-default styling: scoped classes + one screen provider

Use **scoped app-specific CSS classes** (no required prefix). Do **not** use theme-wide selectors like `entry { … }` or `spinbutton { … }`.

| Custom widget / behavior | `StyleContext` classes | CSS intent |
|--------------------------|------------------------|------------|
| Masked **date** field (segment typing, caret hidden) | dedicated class on the inner `Gtk::Entry` (e.g. `datefield-entry`) | `caret-color: transparent` |
| Masked **time** (`HH:MM:SS` segments, caret hidden) | dedicated class on `Gtk::SpinButton` (e.g. `timeofday-spin`) | `caret-color: transparent` |
| Same control in **milliseconds** mode | add second mode class alongside the base one (e.g. `timeofday-ms-mode`) | `caret-color: currentColor` |

**Implementation (gtkmm 3):**

1. **`constexpr const char`** (or one anonymous namespace) for each class string — keep names consistent within the project.
2. **One** `Glib::RefPtr<Gtk::CssProvider>` with a **single** `load_from_data` (or `load_from_resource` for a bundled `app.css`) containing all custom widget rules.
3. Register **once** with **`Gtk::StyleContext::add_provider_for_screen(Gdk::Screen::get_default(), provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)`** (e.g. from `install_application_css_once()` in **`widgets.hpp`** / `style.cpp`, called from `main` or first custom widget ctor).
4. Each instance: apply classes via `get_style_context()->add_class("...")` only — **never** attach a duplicate `CssProvider` per widget for the same bytes.
5. **`note.md`**: table of custom classes + one line per rule + where the provider is installed.

**Forbidden for cross-app identity:** `override_*_color`, painting full backgrounds with **`Gdk::RGBA`** to mimic VCL, **`set_name("…")` for colors**, unscoped CSS (`*`, `entry`, `treeview` without a scoped class).

## Target Linux distributions

**RED OS**, **Astra Linux**, **ALT Linux** — package / pkg-config names may differ.

- **Scripts**: separate build scripts per variant when flags or packages differ; keep **`src/`** shared.
- **Code**: **`#ifdef` / alternate APIs** only for **RED OS** when unavoidable (macro set **only** in the RED OS script). Default path = portable for Astra/ALT unless the user asks otherwise.
- **`note.md`**: document RED-only branches and **which script** to run per target.

## Language

- **UI strings**: **Russian**, aligned with Delphi wording where it matters.
- **Comments**: **Russian**, short; focus on GTK threading, Delphi mapping, non-obvious invariants.

## Naming (C++)

- **Types**: `PascalCase`. **Functions / methods / namespaces / locals / params**: `snake_case`. **Members**: `snake_case` + trailing **`_`** when useful.
- **Files**: `snake_case` (`pick_dialogs.hpp`).
- Prefer **`Gtk::make_managed`** and parent ownership; avoid orphan **`new`**.

## TreeModel columns and stores

- **`ColumnRecord` subclasses**: **`*_cols`** suffix; fields **without** `col_` prefix.
- **Stores**: **`liststore_*`**, **`treestore_*`**.

```cpp
class UserCols : public Gtk::TreeModel::ColumnRecord {
public:
    Gtk::TreeModelColumn<int> id;
    Gtk::TreeModelColumn<Glib::ustring> name;
    UserCols() { add(id); add(name); }
};
// row[user_cols_.id]
Glib::RefPtr<Gtk::ListStore> liststore_users_;
Glib::RefPtr<Gtk::TreeStore> treestore_hierarchy_;
```

## Icons

- **GResource** PNGs **32×32**; register in **`.gresource.xml`** → **`glib-compile-resources`** → **`Gdk::Pixbuf::create_from_resource`** after startup.

## Accelerators and tooltips

- Shortcuts for quit, open/save, primary actions; mirror on toolbar where Delphi did. Prefer **`Gtk::Application`** + **`set_accel_for_action`**; one style per repo. Delphi **Hint** → **`set_tooltip_text`**. Log bindings in **`note.md`**.

## Threading and GTK

- **Never** GTK from worker threads → **`Glib::Dispatcher`**, **`signal_idle()`**, or default main context. **`std::optional`** for nullable scalars when it replaces Delphi sentinels **without** changing rules.

## Build verification

- **Build script** until **warning-clean**; **smoke-run** (main window + one critical dialog) when possible.

## `note.md` (repo root)

1. **Multithreading** — workers, shutdown, UI marshaling.
2. **Custom widgets** — class, file, role, thread assumptions.
3. **Accelerators** — action → key → target.
4. **Icons** — resource path, meaning.
5. **GTK styling / CSS** — every custom class, optional **`app.css`** in `GResource`, **`add_provider_for_screen`** location, one line per rule.
6. **Distribution** — distros, scripts, RED-only code.
7. **Functional gaps** — stubs / known non-parity.

## Porting pipeline

Vertical slices when useful (one feature UI → storage end-to-end).

1. **Analyze Delphi** — `.dpr`, units, `.dfm`; forms → `Gtk::Window` / `Dialog` / `HeaderBar`; grids → `TreeView` + store; list **non-UI** units.
2. **Skeleton** — layout from § **Ported Linux repo**; **milestone: clean build + window shows**.
3. **UI + models** — **`*_cols`**, stores, § **Visual identity**; persist column widths etc. if Delphi did.
4. **Signals** — consistent **`sigc::mem_fun`** / lambdas; no dead menu items without **`note.md`** reason.
5. **Logic + I/O** — parity for files, XML, SQL, sockets, encodings (e.g. **CP1251 → UTF-8** where the legacy format requires it), **KeyFile**; **UI on main thread only**; document dispatchers in **`note.md`**. Implement **as much as u can** and **denote the rest** functional in **`note.md`**
6. **Resources** — icons, toolbars vs `TImageList`.
7. **Polish** — tooltips, accels, Russian strings, scoped custom CSS per § **Visual identity**, **`note.md`**.
8. **Smoke** — script + minimal manual checklist in **`note.md`**.

## Delphi → gtkmm (quick map)

| Delphi / VCL | gtkmm 3 |
|--------------|---------|
| `TForm` | `Gtk::Window`, `Gtk::ApplicationWindow`, `Gtk::Dialog` |
| `TPanel`, `TGroupBox` | `Gtk::Box`, `Gtk::Frame`, `Gtk::Grid` |
| `TButton`, `TBitBtn` | `Gtk::Button` |
| `TEdit`, `TMemo` | `Gtk::Entry`, `Gtk::TextView` |
| `TComboBox` | `Gtk::ComboBox`, `Gtk::ComboBoxText`, composite |
| `TStringGrid`, lists | `Gtk::TreeView` + `ListStore` / `TreeStore` |
| `TTimer` | `Glib::signal_timeout()` + `sigc::slot` |
| Modal dialog | `Gtk::Dialog::run()` or async signal flow |
