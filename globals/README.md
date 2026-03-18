# globals/

Singletons registered in `qmldir` and available to every QML file in the project without a local import path. These are the foundation everything else reads from — no logic belongs here beyond parsing config files and exposing reactive properties.

## Files

| File             | Singleton    | Description                                                                   |
|------------------|--------------|-------------------------------------------------------------------------------|
| `Config.qml`     | `Config`     | Behaviour values from `config.json`. Also exposes `isHorizontal` (derived from `navbarLocation`) and `loaded` (true once the file has been read — used to gate `PanelWindow` creation since Wayland anchors are immutable after creation) |
| `Style.qml`      | `Style`      | Appearance values from `style.json`. Exposes a `saveSetting(key, value)` function that atomically writes back to disk via a temp file |
| `Colors.qml`     | `Colors`     | Theme colors populated by wallust templates. `color0`–`color15` plus `background` and `foreground` |
| `Animations.qml` | `Animations` | Shared animation duration constants and easing curve references               |
| `Time.qml`       | `Time`       | Reactive `time` and `date` strings, updated on a timer                        |
| `EventBus.qml`   | `EventBus`   | Cross-module signal bus. Signals: `togglePanel`, `changeLocation`, `toggleBorders`, `toggleTransparentNavbar`, `changeLayout` |

## Rules

- Globals expose data. They don't contain UI logic, rendering, or module-specific behaviour.
- `Config` owns *behaviour*. `Style` owns *appearance*. Never mix them.
- `EventBus` is the only cross-cutting communication channel. Modules and panels should not import each other directly — they signal through `EventBus`.
