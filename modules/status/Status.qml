// modules/status/Status.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

QtObject {
    readonly property string moduleType: "dynamic"

    // Status exposes battery (in the meantime)
    // Each is only included in items if the hardware is present
    readonly property var items: {
        let out = []
        if (Status.hasBattery)
            out.push({
                icon:    Status.battIcon,
                label:   Status.battPercent + "%",
                bgColor: Status.battLow ? Colors.color1 : Colors.color0
            })
        return out
    }

    // ── Battery ───────────────────────────────────────────────────────────
    property int    battPercent: 0
    property string battStatus:  "Unknown"
    property bool   hasBattery:  false
    readonly property string battIcon: {
        if (battStatus === "Charging" || battStatus === "Full") return "󱐋"
        let p = battPercent
        if (p > 80) return ""
        if (p > 60) return ""
        if (p > 40) return ""
        if (p > 20) return ""
        return ""
    }
    readonly property bool battLow: battPercent <= 15 && battStatus !== "Charging"

    // ── Polling ───────────────────────────────────────────────────────────
    property var _batProc: Process {
        id: batProc
        command: ["/bin/bash", "-c",
            "cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null); " +
            "sta=$(cat /sys/class/power_supply/BAT0/status   2>/dev/null); " +
            "[ -n \"$cap\" ] && echo \"$cap $sta\""]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { batProc._buf = l.trim() } }
        onExited: {
            let parts = _buf.split(" ")
            if (parts[0] !== "") {
                Status.battPercent = parseInt(parts[0]) || 0
                Status.battStatus  = parts[1] || "Unknown"
                Status.hasBattery  = true
            }
            _buf = ""
        }
    }
    property var _batTimer: Timer { interval: 30000; running: true; repeat: true; onTriggered: batProc.running = true }
    Component.onCompleted: { batProc.running = true; blProc.running = true }
}
