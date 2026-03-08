// modules/clock/Clock.qml
import QtQuick
import qs.globals

Item {
    id: root

    // Injected by LayoutLoader
    property bool   isHorizontal: true
    property real   barThickness: 40
    property string barFont:      "JetBrainsMono Nerd Font"
    property real   fontSize:     12

    Text {
        id: timeMetrics
        text:            Time.time
        font.family:     label.font.family
        font.pixelSize:  label.font.pixelSize
        font.weight:     label.font.weight
        visible:         false
    }

    implicitWidth:  root.isHorizontal ? (timeMetrics.implicitWidth + 30) : root.barThickness
    implicitHeight: root.isHorizontal ? root.barThickness : (timeMetrics.implicitWidth + 30)

    Rectangle {
        id: pill
        anchors.centerIn: parent

        readonly property real thickness: root.barThickness / 1.65
        readonly property real length:    timeMetrics.implicitWidth + 30

        width:  root.isHorizontal ? length    : thickness
        height: root.isHorizontal ? thickness : length
        radius: (root.isHorizontal ? height : width) / 2
        color:  Colors.color7

        Text {
            id: label
            anchors.centerIn: parent

            color:          Colors.background
            text:           mouseArea.containsMouse
                                ? "󰣇"
                                : (root.isHorizontal
                                    ? Time.time
                                    : Time.time.replace(":", "\n"))
            font.family:    root.barFont
            font.pixelSize: root.fontSize
            font.weight:    Font.ExtraBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
        }

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    EventBus.togglePanel("dashboard")
        }
    }
}
