# layouts/

Pure JSON data. No logic, no QML. Each file describes the left, center, and right slots of the bar. The active layout is set via `activeLayout` in `config.json`.

## Format

```json
{
  "left":   [...],
  "center": [...],
  "right":  [...]
}
```

Each slot is an array of entries. An entry is either:

- A **string** — resolves to a bare module via `ModuleRegistry.resolve(name)`
- An **array of strings** — creates a pill group containing those modules

```json
{
  "left":   [["start", "workspaces"]],
  "center": [["cava", "clock", "media"]],
  "right":  ["tray", ["audio", "network", "status"], "settings", "power"]
}
```

## Available module names

`audio`, `battery`, `backlight`, `bluetooth`, `cava`, `cliphist`, `clock`, `cpu`, `idleinhibitor`, `media`, `memory`, `network`, `notifications`, `power`, `settings`, `start`, `status`, `systeminfo`, `tray`, `updates`, `wallchange`, `workspaces`

(`battery` and `backlight` are aliases for `status`; `cpu` and `memory` are aliases for `systeminfo`)

## Included layouts

| File          | Description                              |
|---------------|------------------------------------------|
| `default.json`| Minimal: workspaces / clock / tray+power |
| `minimal.json`| Clock only                               |
| `media.json`  | Clock + media player                     |
| `01`–`09`     | Various arrangements                     |

## Adding a layout

Create any `.json` file in this folder following the format above, then set `"activeLayout": "yourfilename"` in `config.json` (without the `.json` extension). The layout switcher in the Settings panel will pick it up automatically.
