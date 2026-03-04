// quickshell/components/Panel.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.shared

Scope {
    id: rootScope

    property bool showPanel: false
    property real panelWidth: 400
    property real panelHeight: 400
    property real navbarOffset: 0
    property real visualGap: 0
    
    property int keyboardFocus: WlrKeyboardFocus.OnDemand

    default property Component panelContent 

    Variants {
        model: Quickshell.screens

        PanelWindow {
            screen: modelData
            visible: rootScope.showPanel
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            
            WlrLayershell.keyboardFocus: rootScope.keyboardFocus

            anchors {
                top: Config.navbarLocation === "top"
                bottom: Config.navbarLocation === "bottom"
                left: Config.navbarLocation === "left"
                right: Config.navbarLocation === "right"
            }

            margins {
                top: Config.navbarLocation === "top" ? (rootScope.navbarOffset + rootScope.visualGap) : 0
                bottom: Config.navbarLocation === "bottom" ? (rootScope.navbarOffset + rootScope.visualGap) : 0
                left: Config.navbarLocation === "left" ? (rootScope.navbarOffset + rootScope.visualGap) : 0
                right: Config.navbarLocation === "right" ? (rootScope.navbarOffset + rootScope.visualGap) : 0
            }

            implicitWidth: rootScope.panelWidth
            implicitHeight: rootScope.panelHeight

            Item {
                anchors.fill: parent
                clip: true 

                Rectangle {
                    id: bg
                    color: Colors.background
                    radius: 20

                    anchors {
                        fill: parent
                        topMargin: Config.navbarLocation === "top" ? -radius : 0
                        bottomMargin: Config.navbarLocation === "bottom" ? -radius : 0
                        leftMargin: Config.navbarLocation === "left" ? -radius : 0
                        rightMargin: Config.navbarLocation === "right" ? -radius : 0
                    }
                }

                Loader {
                    anchors.fill: parent
                    anchors.margins: 25
                    sourceComponent: rootScope.panelContent
                }
            }
        }
    }
}