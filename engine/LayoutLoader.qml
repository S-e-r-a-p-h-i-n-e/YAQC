// engine/LayoutLoader.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.globals

Scope {
    id: root

    readonly property real   barSize: 40
    readonly property string barFont: "JetBrainsMono Nerd Font"

    property var layoutLeft:   []
    property var layoutCenter: []
    property var layoutRight:  []

    FileView {
        path: Qt.resolvedUrl("../layouts/" + Config.activeLayout + ".json")
        adapter: JsonAdapter {
            property var left:   []
            property var center: []
            property var right:  []
            onLeftChanged:   root.layoutLeft   = left   || []
            onCenterChanged: root.layoutCenter = center || []
            onRightChanged:  root.layoutRight  = right  || []
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            screen: modelData
            color:  Colors.background
            exclusionMode: ExclusionMode.Auto

            anchors {
                top:    Config.navbarLocation !== "bottom"
                bottom: Config.navbarLocation !== "top"
                left:   Config.navbarLocation !== "right"
                right:  Config.navbarLocation !== "left"
            }

            implicitHeight: Config.isHorizontal ? root.barSize : 0
            implicitWidth:  Config.isHorizontal ? 0            : root.barSize

            // ── HORIZONTAL ────────────────────────────────────────────────
            Row {
                visible: Config.isHorizontal
                spacing: 8
                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                Repeater {
                    model: Config.isHorizontal ? root.layoutLeft : []
                    delegate: Loader {
                        id: hlLoader
                        required property string modelData
                        sourceComponent: ModuleRegistry.resolve(modelData)
                        Binding { when: hlLoader.status === Loader.Ready; target: hlLoader.item; property: "isHorizontal"; value: true }
                        Binding { when: hlLoader.status === Loader.Ready; target: hlLoader.item; property: "barThickness";  value: root.barSize }
                        Binding { when: hlLoader.status === Loader.Ready; target: hlLoader.item; property: "barFont";       value: root.barFont }
                    }
                }
            }

            Row {
                visible: Config.isHorizontal
                spacing: 8
                anchors.centerIn: parent
                Repeater {
                    model: Config.isHorizontal ? root.layoutCenter : []
                    delegate: Loader {
                        id: hcLoader
                        required property string modelData
                        sourceComponent: ModuleRegistry.resolve(modelData)
                        Binding { when: hcLoader.status === Loader.Ready; target: hcLoader.item; property: "isHorizontal"; value: true }
                        Binding { when: hcLoader.status === Loader.Ready; target: hcLoader.item; property: "barThickness";  value: root.barSize }
                        Binding { when: hcLoader.status === Loader.Ready; target: hcLoader.item; property: "barFont";       value: root.barFont }
                    }
                }
            }

            Row {
                visible: Config.isHorizontal
                spacing: 8
                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                Repeater {
                    model: Config.isHorizontal ? root.layoutRight : []
                    delegate: Loader {
                        id: hrLoader
                        required property string modelData
                        sourceComponent: ModuleRegistry.resolve(modelData)
                        Binding { when: hrLoader.status === Loader.Ready; target: hrLoader.item; property: "isHorizontal"; value: true }
                        Binding { when: hrLoader.status === Loader.Ready; target: hrLoader.item; property: "barThickness";  value: root.barSize }
                        Binding { when: hrLoader.status === Loader.Ready; target: hrLoader.item; property: "barFont";       value: root.barFont }
                    }
                }
            }

            // ── VERTICAL ──────────────────────────────────────────────────
            Column {
                visible: !Config.isHorizontal
                spacing: 8
                anchors { top: parent.top; topMargin: 12; horizontalCenter: parent.horizontalCenter }
                Repeater {
                    model: !Config.isHorizontal ? root.layoutLeft : []
                    delegate: Loader {
                        id: vtLoader
                        required property string modelData
                        sourceComponent: ModuleRegistry.resolve(modelData)
                        Binding { when: vtLoader.status === Loader.Ready; target: vtLoader.item; property: "isHorizontal"; value: false }
                        Binding { when: vtLoader.status === Loader.Ready; target: vtLoader.item; property: "barThickness";  value: root.barSize }
                        Binding { when: vtLoader.status === Loader.Ready; target: vtLoader.item; property: "barFont";       value: root.barFont }
                    }
                }
            }

            Column {
                visible: !Config.isHorizontal
                spacing: 8
                anchors.centerIn: parent
                Repeater {
                    model: !Config.isHorizontal ? root.layoutCenter : []
                    delegate: Loader {
                        id: vcLoader
                        required property string modelData
                        sourceComponent: ModuleRegistry.resolve(modelData)
                        Binding { when: vcLoader.status === Loader.Ready; target: vcLoader.item; property: "isHorizontal"; value: false }
                        Binding { when: vcLoader.status === Loader.Ready; target: vcLoader.item; property: "barThickness";  value: root.barSize }
                        Binding { when: vcLoader.status === Loader.Ready; target: vcLoader.item; property: "barFont";       value: root.barFont }
                    }
                }
            }

            Column {
                visible: !Config.isHorizontal
                spacing: 8
                anchors { bottom: parent.bottom; bottomMargin: 12; horizontalCenter: parent.horizontalCenter }
                Repeater {
                    model: !Config.isHorizontal ? root.layoutRight : []
                    delegate: Loader {
                        id: vbLoader
                        required property string modelData
                        sourceComponent: ModuleRegistry.resolve(modelData)
                        Binding { when: vbLoader.status === Loader.Ready; target: vbLoader.item; property: "isHorizontal"; value: false }
                        Binding { when: vbLoader.status === Loader.Ready; target: vbLoader.item; property: "barThickness";  value: root.barSize }
                        Binding { when: vbLoader.status === Loader.Ready; target: vbLoader.item; property: "barFont";       value: root.barFont }
                    }
                }
            }
        }
    }
}
