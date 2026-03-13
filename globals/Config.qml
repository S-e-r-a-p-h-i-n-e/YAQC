// globals/Config.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/config.json"
    readonly property string tmpPath:    Quickshell.env("HOME") + "/.config/quickshell/.config.json.tmp"

    property string navbarLocation: "top"
    property bool   enableBorders:  true
    property string activeLayout:   "default"

    readonly property bool isHorizontal: navbarLocation === "top" || navbarLocation === "bottom"

    FileView {
        path: root.configPath
        adapter: JsonAdapter {
            property string navbarLocation: "top"
            property bool   enableBorders:  true
            property string activeLayout:   "default"

            onNavbarLocationChanged: root.navbarLocation = navbarLocation
            onEnableBordersChanged:  root.enableBorders  = enableBorders
            onActiveLayoutChanged:   root.activeLayout   = activeLayout
        }
    }

    readonly property var settingKeys: ["navbarLocation", "enableBorders", "activeLayout"]

    function saveSetting(key, value) {
        root[key] = value

        let fileData = {}
        for (let k of root.settingKeys) fileData[k] = root[k]

        let jsonString = JSON.stringify(fileData, null, 2)
        Quickshell.execDetached({
            command: ["sh", "-c",
                `mkdir -p ~/.config/quickshell && echo '${jsonString}' > ${root.tmpPath} && mv ${root.tmpPath} ${root.configPath}`]
        })
    }
}
