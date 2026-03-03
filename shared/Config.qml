// quickshell/shared/Config.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/config.json"
    
    readonly property string tmpPath: Quickshell.env("HOME") + "/.config/quickshell/config_tmp.json"

    property string navbarLocation: "top"
    property bool enableBorders: true

    FileView {
        id: configFile
        path: root.configPath

        adapter: JsonAdapter {
            id: configAdapter
            
            property string navbarLocation: "top"
            property bool enableBorders: true
            property bool visualizerEnabled: false

            onNavbarLocationChanged: root.navbarLocation = navbarLocation
            onEnableBordersChanged: root.enableBorders = enableBorders
        }
    }

    function saveSetting(key, value) {
        if (key === "navbarLocation") root.navbarLocation = value;
        if (key === "enableBorders") root.enableBorders = value;

        let fileData = {
            navbarLocation: root.navbarLocation,
            enableBorders: root.enableBorders
        };

        let jsonString = JSON.stringify(fileData, null, 2);

        Quickshell.execDetached({
            command: ["sh", "-c", `mkdir -p ~/.config/quickshell && echo '${jsonString}' > ${root.tmpPath} && mv ${root.tmpPath} ${root.configPath}`]
        });
    }
}