// modules/workspaces/Workspaces.qml
import QtQuick
import Quickshell.Hyprland
import qs.globals
import qs.components

ListView {
    id: root

    // Injected by LayoutLoader
    property bool   isHorizontal: true
    property real   barThickness: 40
    property string barFont:      "JetBrainsMono Nerd Font"

    orientation: isHorizontal ? ListView.Horizontal : ListView.Vertical
    spacing:     15

    model: Hyprland.workspaces

    readonly property real baseSize: barThickness / 1.65

    implicitWidth:  isHorizontal ? contentWidth  : barThickness
    implicitHeight: isHorizontal ? barThickness  : contentHeight
    clip: false

    delegate: Item {
        id: wsDelegate
        required property var modelData

        width:  root.isHorizontal ? layout.implicitWidth : root.barThickness
        height: root.isHorizontal ? root.barThickness    : layout.implicitHeight

        Flow {
            id: layout
            anchors.centerIn: parent
            flow:    root.isHorizontal ? Flow.LeftToRight : Flow.TopToBottom
            spacing: 6

            // Empty workspace dot
            Rectangle {
                visible: appRepeater.count === 0
                height:  root.baseSize
                width:   height
                radius:  height / 2
                color:   wsDelegate.modelData.focused ? Colors.color7 : Colors.color5
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text:             wsDelegate.modelData.focused ? "󰣇" : wsDelegate.modelData.name
                    color:            wsDelegate.modelData.focused ? Colors.background : Colors.foreground
                    font.family:      root.barFont
                    font.pixelSize:   12
                    font.weight:      Font.ExtraBold
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    wsDelegate.modelData.activate()
                }
            }

            // App dots
            Repeater {
                id: appRepeater
                model: wsDelegate.modelData.toplevels

                delegate: Rectangle {
                    required property var modelData

                    height: root.baseSize
                    width:  height
                    radius: height / 2
                    color:  modelData.activated ? Colors.color7 : Colors.color5
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            let ipc      = modelData.lastIpcObject || {};
                            let appClass = ipc["class"] || ipc["initialClass"] || modelData.title || "?";
                            return appClass.substring(0, 1).toUpperCase();
                        }
                        color:          modelData.activated ? Colors.background : Colors.foreground
                        font.family:    root.barFont
                        font.pixelSize: 12
                        font.weight:    Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            Hyprland.dispatch("focuswindow address:0x" + modelData.address);
                        }
                    }
                }
            }
        }
    }
}
