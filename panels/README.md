# panels/

Overlay surfaces that appear on top of the bar. Each panel uses `Panel.qml` as its window container and reads from engine singletons for data. Two entries (`NotificationPopups`, `WallpaperWindow`) are always-on rather than toggled.

## Panels

| Panel               | panelId      | Trigger                   | Description                                                          |
|---------------------|--------------|---------------------------|----------------------------------------------------------------------|
| `Launcher`          | `launcher`   | start module / IPC        | App launcher with fuzzy search. Data from `AppEngine`               |
| `ClipManager`       | `clipboard`  | cliphist module / IPC     | Clipboard history + favorites. Data from `ClipboardEngine`          |
| `Wallpaper`         | `wallpaper`  | wallchange module / IPC   | Wallpaper file picker. Calls `WallpaperEngine.apply(path)` on select |
| `EmojiPicker`       | `emoji`      | IPC only                  | Emoji picker with category tabs and keyword search. Writes to clipboard on select |
| `Dashboard`         | `dashboard`  | notifications module      | Control center grid + media player + notification list. Layout from `DashboardEngine` |
| `Settings`          | `theming`    | settings module           | Bar configuration: location, layout, borders, transparency          |
| `AdvancedSettings`  | `advanced`   | Settings panel button     | Extended appearance config: spacing, sizing, radii — all `Style` values |
| `PowerManager`      | `power`      | power module              | Full-screen power menu: lock, logout, suspend, reboot, shutdown     |
| `NotificationPopups`| —            | always-on                 | Live toast popup stack. Each card auto-dismisses per urgency/timeout |
| `NotificationCard`  | —            | used by NotificationPopups| Individual toast card component                                      |

`WallpaperWindow` is declared in `engine/` and instantiated directly in `shell.qml` — it is not a panel in the `Panel.qml` sense.

## IPC

Several panels can be triggered from external tools (e.g. Hyprland keybinds):

```sh
qs ipc call launcher  toggle
qs ipc call clipboard toggle
qs ipc call wallpaper toggle
qs ipc call theming   toggle
qs ipc call emoji     toggle
```

## Adding a new panel

1. Create `panels/YourPanel.qml` using `Panel` as the root element
2. Set a unique `panelId` string
3. Register it in `panels/qmldir`
4. Add an `IpcHandler` in `shell.qml` if it should be externally triggerable
5. Add a panel instance in `shell.qml` bound to `shell.activePanel === "yourpanelid"`
6. Emit `EventBus.togglePanel("yourpanelid", screen)` from whatever triggers it
