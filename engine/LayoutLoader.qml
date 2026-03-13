// engine/LayoutLoader.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.globals

Scope {
    id: root

    // Exposed so panels can offset themselves correctly
    readonly property real barSize: Style.barSize

    property var layoutLeft:   []
    property var layoutCenter: []
    property var layoutRight:  []

    FileView {
        path: Qt.resolvedUrl("../layouts/" + Config.activeLayout + ".json")
        adapter: JsonAdapter {
            property var left:   []
            property var center: []
            property var right:  []
            onLeftChanged:   root.layoutLeft   = JSON.parse(JSON.stringify(left   || []))
            onCenterChanged: root.layoutCenter = JSON.parse(JSON.stringify(center || []))
            onRightChanged:  root.layoutRight  = JSON.parse(JSON.stringify(right  || []))
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            screen:        modelData
            color:         Colors.background
            exclusionMode: ExclusionMode.Auto

            anchors {
                top:    Config.navbarLocation !== "bottom"
                bottom: Config.navbarLocation !== "top"
                left:   Config.navbarLocation !== "right"
                right:  Config.navbarLocation !== "left"
            }

            implicitHeight: Config.isHorizontal ? Style.barSize : 0
            implicitWidth:  Config.isHorizontal ? 0              : Style.barSize

            component BarSlot: SlotLayout {
                isHorizontal: Config.isHorizontal
                moduleSize:   Style.moduleSize
            }

            // ── Horizontal ────────────────────────────────────────────────
            BarSlot {
                visible: Config.isHorizontal
                modules: root.layoutLeft
                anchors.left:           parent.left
                anchors.leftMargin:     12
                anchors.verticalCenter: parent.verticalCenter
            }
            BarSlot {
                visible: Config.isHorizontal
                modules: root.layoutCenter
                anchors.centerIn: parent
            }
            BarSlot {
                visible: Config.isHorizontal
                modules: root.layoutRight
                anchors.right:          parent.right
                anchors.rightMargin:    12
                anchors.verticalCenter: parent.verticalCenter
            }

            // ── Vertical ──────────────────────────────────────────────────
            BarSlot {
                visible: !Config.isHorizontal
                modules: root.layoutLeft
                anchors.top:              parent.top
                anchors.topMargin:        12
                anchors.horizontalCenter: parent.horizontalCenter
            }
            BarSlot {
                visible: !Config.isHorizontal
                modules: root.layoutCenter
                anchors.centerIn: parent
            }
            BarSlot {
                visible: !Config.isHorizontal
                modules: root.layoutRight
                anchors.bottom:           parent.bottom
                anchors.bottomMargin:     12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
