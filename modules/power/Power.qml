// modules/power/Power.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "⏻",
        bgColor:   Colors.color7,
        fgColor:   Colors.background,
        onClicked: function() { Power.open() }
    })

    function open() {
        Quickshell.execDetached({ command: ["sh", "-c",
            "wlogout -b 5 -l ~/.config/wlogout/layout -C ~/.config/wlogout/style.css"] })
    }
}
