# modules/

Individual bar widgets. Each subfolder is a self-contained module with a singleton backend and an optional custom view. Modules expose reactive properties and item descriptors — they own no layout logic and are position-agnostic.

## Patterns

### Pattern A — backend only

The module exposes item descriptors. The engine renders them via `DynamicChip`, `StaticChip`, or `CCToggle` — no frontend QML needed.

```
module-name/
 ├ ModuleName.qml   ← singleton: data, state, item descriptors
 └ qmldir
```

### Pattern B — backend + custom view

Used when bar appearance is too complex for chip patterns.

```
module-name/
 ├ ModuleName.qml      ← singleton: data, state
 ├ ModuleNameView.qml  ← custom visual logic
 └ qmldir
```

Custom views own their visual logic entirely and do not import `qs.components`.

## Module types

Modules declare their type via `moduleType`, which tells `ModuleRegistry` which chip component to use:

| Type      | Rendered by  | Use case                                       |
|-----------|--------------|------------------------------------------------|
| `static`  | `StaticChip` | Single icon button (power, settings, cliphist…)|
| `dynamic` | `DynamicChip`| One or more labeled chips (audio, network…)    |
| `custom`  | custom view  | Complex layout that chips can't express        |

## Inventory

| Module          | Type    | View | External dependency     | Description                                     |
|-----------------|---------|------|-------------------------|-------------------------------------------------|
| `audio`         | dynamic | —    | pactl                   | Speaker + mic volume/mute                       |
| `bluetooth`     | dynamic | —    | bluetoothctl            | Bluetooth power + connection state              |
| `cava`          | custom  | ✓    | cava                    | Audio spectrum visualizer                       |
| `cliphist`      | static  | —    | cliphist (backend only) | Opens ClipManager panel                         |
| `clock`         | custom  | ✓    | —                       | Time and date display                           |
| `idleinhibitor` | static  | —    | systemd-inhibit         | Prevents idle/sleep while toggled on            |
| `layoutswitcher`| —       | —    | —                       | Stub — absorbed into Settings panel             |
| `media`         | custom  | ✓    | —                       | MPRIS player controls (native Quickshell API)   |
| `network`       | dynamic | —    | nmcli, iwgetid          | WiFi/ethernet state                             |
| `notifications` | static  | —    | —                       | Notification count badge, opens Dashboard       |
| `power`         | static  | —    | —                       | Opens PowerManager panel                        |
| `settings`      | static  | —    | —                       | Opens Settings panel                            |
| `start`         | static  | —    | —                       | Opens Launcher panel                            |
| `status`        | dynamic | —    | /sys/class/…            | Battery percentage + backlight brightness       |
| `systeminfo`    | dynamic | —    | /proc, sensors/nvidia-smi | CPU %, RAM %, GPU temp                        |
| `tray`          | custom  | ✓    | —                       | System tray icons (native Quickshell API)       |
| `updates`       | dynamic | —    | checkupdates, kitty     | Pending Arch update count                       |
| `wallchange`    | static  | —    | —                       | Opens Wallpaper picker panel                    |
| `workspaces`    | custom  | ✓    | —                       | Hyprland workspace dots with app icons          |

## Adding a new module

1. Create `modules/yourmodule/YourModule.qml` as a `pragma Singleton`
2. Declare `moduleType`, the appropriate item descriptor(s), and any reactive properties
3. Create `modules/yourmodule/qmldir` registering the singleton
4. Import `qs.modules.yourmodule` in `shell.qml`
5. Add an entry to `ModuleRegistry.qml` (both `_map` and a `property Component`)
6. Add `"yourmodule"` to any layout JSON where you want it to appear
