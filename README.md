# YAQC

### Yet Another Quickshell Configuration

YAQC is a **modular, layout-driven Quickshell configuration** designed around separation of concerns and composable UI systems.

The project originally started as a **fork**, but has since evolved into its own architecture focused on:

* layout-driven UI construction
* modular system widgets
* reusable UI components
* clean separation between structure and functionality

Instead of hardcoding UI structure in QML, YAQC treats the shell more like a **runtime UI engine** that assembles the interface dynamically.

---

## 📜 Philosophy

YAQC follows a few key ideas:

### Layouts are data

UI structure is defined through **layout definitions**, not hardcoded QML.

This allows:

* multiple layouts
* quick experimentation
* cleaner UI logic

---

### Modules are self-contained

Modules provide **functionality**, not layout control.

Examples:

* clock
* media player
* workspaces
* system controls

Modules can be placed anywhere in a layout without modification.

---

### Components are reusable primitives

Components act as the shell’s **UI toolkit**, providing shared building blocks used across modules.

Examples include buttons, toggles, panels, and animated elements.

---

### The shell is an assembly system

Rather than defining a static UI, the shell dynamically builds the interface by loading:

1. layouts
2. modules
3. components

This allows the interface to behave more like a **composable system** than a fixed bar configuration.

---

## 🛠️ Features

* Layout-driven interface
* Modular widget system
* Dynamic module loading
* Reusable UI components
* Multiple layout support
* Panels for extended interfaces
* Clean and maintainable project structure

---

## 🎯 Project Goals

<div align="center">

| 📋 **TODO** | **STATUS** |
| :---: | :---: |
| Replace waybar | ✅ |
| Replace rofi | ✅ |
| Replace wlogout | ✅ |
| Replace SwayNC | ✅ |
| Port all necessary bash scripts into native QML modules/functionality | ⏳ |

</div>

---

## 🌲 Project Structure

```
quickshell/
├ components/   # reusable UI elements
├ engine/       # layout engine and module loading
├ globals/      # shared services and configuration
├ layouts/      # layout definitions
├ modules/      # functional UI widgets
├ panels/       # dashboard / overlay panels
├ shell/        # shell entry point
│
├ config.json
├ style.json
└ shell.qml
```

A full explanation of how these parts interact is documented in:

**[Docs/ARCHITECTURE.md](https://github.com/S-e-r-a-p-h-i-n-e/YAQC/blob/main/Docs/ARCHITECTURE.md)**

---

## ⚙️ Configuration

YAQC exposes configuration through JSON files.

### `config.json`

Controls shell behaviour.

Examples:

* active layout
* feature toggles
* behaviour settings

---

### `style.json`

Controls appearance.

Examples:

* spacing
* colors
* sizing
* UI scaling

---

## 📝 Documentation

The architecture and internal design of the system are documented in:

**[Docs/ARCHITECTURE.md](https://github.com/S-e-r-a-p-h-i-n-e/YAQC/blob/main/Docs/ARCHITECTURE.md)**

This includes:

* layout engine internals
* module system
* component hierarchy
* shell initialization

---

## 📊 Project Status

YAQC began as a fork but has since diverged significantly in structure and design.

The project now serves as an exploration of how a **Quickshell configuration can be structured as a modular UI system** rather than a single static layout.

---

## 🤍 Credits

Big Thanks to:

* **[NeKoRoSyS](https://github.com/NeKoRoSYS)** for starting this project and being collaborative, the amount of ideas you have for both our projects is honestly insane and commendable
