# Architecture

YAQC is **layout-driven and data-configured** — bar structure is defined by JSON, appearance is controlled by JSON, and QML files are responsible only for behaviour and rendering, never for hardcoded values.

---

## Structure

```
quickshell/
 ├ shell.qml          ← entry point
 ├ config.json        ← behaviour config (live-reloading)
 ├ style.json         ← appearance config (live-reloading)
 ├ globals/           ← singletons available everywhere
 ├ engine/            ← bar, dashboard, wallpaper, clipboard, app engines
 ├ layouts/           ← JSON layout definitions
 ├ modules/           ← individual bar widgets
 ├ components/        ← reusable visual primitives
 └ panels/            ← overlay surfaces
```

---

## Layers

```
shell.qml
 ├ engine/WallpaperWindow     (background layer, below everything)
 ├ engine/LayoutLoader        (bar per screen)
 └ globals/                   (Config, Style, Colors — read by everything)
     └ engine/                (reads layouts/, instantiates modules/, drives dashboard/clipboard/apps)
         └ modules/           (widgets — backend singleton + optional *View.qml)
             └ components/    (drawing primitives used by panels and custom views)
     └ panels/                (overlay surfaces — use Panel.qml + components/)
```

---

## `/globals`

Singletons registered in `globals/qmldir`, available to every QML file without a local import path.

| Singleton    | Responsibility                                                          |
|--------------|-------------------------------------------------------------------------|
| `Config`     | Behaviour values from `config.json` + `isHorizontal` derived property  |
| `Style`      | Appearance values from `style.json` with hardcoded defaults             |
| `Colors`     | Theme colors sourced from wallust templates                             |
| `Animations` | Shared animation durations and easing curves                            |
| `Time`       | Reactive time/date strings                                              |
| `EventBus`   | Cross-module signal bus (panel toggle, location change, layout change)  |

`Config` owns *behaviour* (where is the bar, which layout, is it transparent). `Style` owns *appearance* (how big, what font, what spacing). Neither contains logic belonging to the other.

---

## `/engine`

The machinery that constructs the bar, drives the dashboard, and manages wallpaper, clipboard history, and app discovery. You don't touch engine files to add a new module or panel — only if the structural or infrastructure behaviour of those systems needs to change.

### Files

| File                   | Responsibility                                                                 |
|------------------------|--------------------------------------------------------------------------------|
| `LayoutLoader.qml`     | Reads the active layout JSON, creates a `PanelWindow` per screen, positions three `BarSlot` instances (left/center/right) for each orientation |
| `SlotLayout.qml`       | Receives a module list, renders them as a `Row` or `Column`, resolves each entry as either a `PillGroup` (array) or a bare module (string) |
| `PillGroup.qml`        | Wraps a group of modules in a pill-shaped background, injects `inPill: true` into chip-based modules |
| `ModuleRegistry.qml`   | Single registry for all renderable components. `resolve(name)` maps module names to navbar components; `resolveWidget(id)` maps widget IDs to dashboard card components |
| `DashboardEngine.qml`  | Grid packer, placement algorithm, widget registry, edit mode state, and `add`/`remove`/`move` operations. Pure logic — no visual output |
| `AppEngine.qml`        | Discovers installed applications by scanning `.desktop` files. Powers the Launcher panel |
| `ClipboardEngine.qml`  | Manages clipboard history (via cliphist) and favorites (flat text file). Powers the ClipManager panel |
| `WallpaperEngine.qml`  | File discovery for the wallpaper picker panel. `apply(path)` saves to `Config.wallpaperPath`, which `WallpaperWindow` reacts to |
| `WallpaperWindow.qml`  | Self-contained background renderer. Spawns one `PanelWindow` at `WlrLayer.Background` per screen via internal `Variants`. Handles crossfade, parallax on empty desktop, and smart video pause via `QtMultimedia` |

### Navbar flow

```
config.json (activeLayout)
    ↓
LayoutLoader — reads layouts/<name>.json
    ↓
SlotLayout (left / center / right)
    ↓
  string entry → ModuleRegistry.resolve() → Loader → module
  array entry  → PillGroup → ModuleRegistry.resolve() → Loader → module
```

### Dashboard flow

```
DashboardEngine — reads Config.dashboardLayout, computes placements[]
    ↓
Dashboard.qml — Repeater over placements
    ↓
ModuleRegistry.resolveWidget(id) → Loader → widget card
```

### Wallpaper flow

```
panels/Wallpaper.qml (picker) — user selects a file
    ↓
WallpaperEngine.apply(path)
    ↓
Config.saveSetting("wallpaperPath", path) — persisted to config.json
    ↓
engine/WallpaperWindow (binding on Config.wallpaperPath) — crossfades to new wallpaper
```

### Prop injection

The engine injects three props into every loaded navbar module via `Binding`:

| Prop           | Value                 |
|----------------|-----------------------|
| `isHorizontal` | `Config.isHorizontal` |
| `barThickness` | `Style.moduleSize`    |
| `inPill`       | `true` (pill only, guarded with `hasOwnProperty`) |

Modules must declare these props to receive them. Custom views that don't use chip components don't need `inPill`.

---

## `/layouts`

Pure JSON data. No logic, no QML. Each file describes what goes in the left, center, and right slots.

```json
{
  "left": ["workspaces"],
  "center": ["clock"],
  "right": ["tray", "notifications", "settings", "power"]
}
```

A string resolves to a bare module. An array creates a pill group:

```json
{
  "left": [["start", "workspaces"]],
  "center": [["cava", "clock", "media"]],
  "right": ["tray", ["audio", "network", "status"], "power"]
}
```

Switch layouts by changing `activeLayout` in `config.json`.

---

## `/modules`

Each subfolder is a self-contained widget. Three patterns exist:

### Pattern A — backend only (most modules)

```
module-name/
 ├ ModuleName.qml   ← singleton: data, state, item descriptors
 └ qmldir
```

The module exposes reactive properties and item descriptor objects. The engine renders them via `DynamicChip`, `StaticChip`, or `CCToggle` — no frontend QML needed.

### Pattern B — backend + custom view

```
module-name/
 ├ ModuleName.qml      ← singleton: data, state
 ├ ModuleNameView.qml  ← custom visual logic
 └ qmldir
```

Used when bar appearance is too complex for chip patterns — custom layout, animation, or per-orientation rendering.

Custom views own their visual logic entirely. They don't depend on shared components and inline whatever primitives they need.

### Module inventory

| Module          | Type      | View | Description                                      |
|-----------------|-----------|------|--------------------------------------------------|
| `audio`         | dynamic   | —    | Speaker + mic volume/mute via pactl polling      |
| `bluetooth`     | dynamic   | —    | Bluetooth power + connection state               |
| `cava`          | custom    | ✓    | Audio visualizer bar (requires cava binary)      |
| `cliphist`      | static    | —    | Bar button — opens ClipManager panel via IPC     |
| `clock`         | custom    | ✓    | Time and date display                            |
| `idleinhibitor` | static    | —    | Prevents idle/sleep while active                 |
| `layoutswitcher`| —         | —    | Stub — functionality absorbed into Settings panel|
| `media`         | custom    | ✓    | MPRIS media player controls                      |
| `network`       | dynamic   | —    | WiFi/ethernet state via nmcli polling            |
| `notifications` | static    | —    | Notification count — opens Dashboard via IPC     |
| `power`         | static    | —    | Opens PowerManager panel via IPC                 |
| `settings`      | static    | —    | Opens Settings panel via IPC                     |
| `start`         | static    | —    | Opens Launcher panel via IPC                     |
| `status`        | dynamic   | —    | Battery percentage + backlight brightness        |
| `systeminfo`    | dynamic   | —    | CPU %, RAM %, GPU temp                           |
| `tray`          | custom    | ✓    | System tray icons via Quickshell SystemTray API  |
| `updates`       | dynamic   | —    | Pending update count via checkupdates            |
| `wallchange`    | static    | —    | Opens Wallpaper picker panel via IPC             |
| `workspaces`    | custom    | ✓    | Hyprland workspace dots with app icons           |

---

## `/components`

Reusable visual primitives. These know how to draw things but nothing about what they're displaying.

### Engine components

Used by `ModuleRegistry` as the engine's rendering contract with modules.

| Component    | Description                                                                    |
|--------------|--------------------------------------------------------------------------------|
| `DynamicChip`| Renders a list of `{ icon, label, bgColor, onClicked… }` descriptors as chips. Handles horizontal/vertical layout and `inPill` transparency |
| `StaticChip` | Single circular icon button driven by one item descriptor. Handles active state |
| `CCToggle`   | Square toggle card with icon + label for dashboard control center widgets      |

### UI components

Used by panels and settings UI. Custom `*View.qml` modules should not depend on these.

| Component        | Description                                                          |
|------------------|----------------------------------------------------------------------|
| `Panel`          | Sliding overlay window with tension fillets and dismiss overlay      |
| `AnimatedElement`| Wraps content with slide/scale/fade entrance animation               |
| `Button`         | Text button for settings UI                                          |
| `Toggle`         | On/off toggle with label                                             |
| `ScreenBorder`   | Thin border + rounded corners around each screen                     |

---

## `/panels`

Full overlay surfaces that appear on top of the bar. Each panel uses `Panel.qml` as its window container and is toggled via `EventBus.togglePanel(panelId, screen)`.

Two panels are always-on rather than toggled: `WallpaperWindow` (background layer) and `NotificationPopups` (toast overlay).

| Panel               | Trigger          | Description                                                     |
|---------------------|------------------|-----------------------------------------------------------------|
| `Launcher`          | IPC / start module | App launcher with fuzzy search. Powered by `AppEngine`        |
| `ClipManager`       | IPC / cliphist module | Clipboard history + favorites. Powered by `ClipboardEngine` |
| `Wallpaper`         | IPC / wallchange module | Wallpaper file picker. Calls `WallpaperEngine.apply()`    |
| `EmojiPicker`       | IPC only         | Emoji picker with category tabs and keyword search              |
| `Dashboard`         | notifications module | Control center + media + notification list. Layout from `DashboardEngine` |
| `Settings`          | settings module  | Bar configuration (location, layout, borders, transparency)     |
| `AdvancedSettings`  | Settings panel   | Extended appearance configuration (spacing, sizing, radii)      |
| `PowerManager`      | power module     | Full-screen power menu: lock, logout, suspend, reboot, shutdown |
| `NotificationPopups`| always-on        | Live toast popup stack. Auto-dismisses per urgency/timeout      |
| `NotificationCard`  | —                | Individual toast card component used by `NotificationPopups`    |

### IPC handlers

Several panels can be triggered externally via `qs ipc call <target> toggle`:

| Target      | Panel          |
|-------------|----------------|
| `launcher`  | Launcher       |
| `clipboard` | ClipManager    |
| `wallpaper` | Wallpaper      |
| `theming`   | Settings       |
| `emoji`     | EmojiPicker    |

---

## Design Decisions

### Config vs Style separation

`config.json` owns behaviour (where is the bar, which layout, transparency). `style.json` owns appearance (sizes, fonts, spacing, radii). Keeping them separate means visual tweaks never touch structural settings and vice versa.

### Backend-only modules

Most modules don't need a `*View.qml`. The chip pattern handles rendering entirely from data — the module exposes reactive properties and item descriptors, the engine decides how to render them. This keeps module code focused on system integration.

### Single registry, two contexts

`ModuleRegistry` is the single source of truth for all renderable components. `resolve(name)` handles the navbar bar; `resolveWidget(id)` handles the dashboard. Both contexts can share the same backend singleton — the registry decides the rendering per context.

### Dashboard engine separation

The dashboard's grid logic, placement algorithm, and edit mode state live in `DashboardEngine`, not in `Dashboard.qml`. The panel file contains only structure and has no logic. This mirrors how `LayoutLoader` owns bar logic while staying out of the panel files.

### Wallpaper as engine infrastructure

The wallpaper system is split across two engine files. `WallpaperEngine` handles file discovery and applies a wallpaper by saving to `Config`. `WallpaperWindow` is self-contained infrastructure — it manages its own `Variants` loop and `PanelWindow` instances at `WlrLayer.Background`. This means `shell.qml` needs only `WallpaperWindow {}` with no arguments, and the picker panel calls only `WallpaperEngine.apply(path)`.

### Custom views own their visuals

When a module needs a custom view, it owns its visual logic completely and doesn't depend on shared chip components. `DynamicChip` and `StaticChip` stay as engine primitives and don't leak into module internals.