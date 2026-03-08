// globals/EventBus.qml
pragma Singleton

import QtQuick

QtObject {
    // Panel visibility
    signal togglePanel(string panelId)

    // Bar configuration
    signal changeLocation(string newLocation)
    signal toggleBorders(bool state)
    signal changeLayout(string layoutName)
}
