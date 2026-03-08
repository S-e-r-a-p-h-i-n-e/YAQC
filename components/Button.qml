// components/Button.qml
import QtQuick
import qs.globals

Rectangle {
    id: root

    signal buttonClicked()

    property string style:       "circle"
    property string labelText
    property string labelFont
    property real   buttonSize:  parent.height / 1.65
    property color  buttonColor

    height: buttonSize
    width:  style === "circle" ? height : implicitWidth
    radius: height / 2
    color:  buttonColor

    Text {
        anchors.centerIn: parent
        text:             root.labelText
        font.family:      root.labelFont
        color:            Colors.background
        font.pixelSize:   parent.height / 1.65
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.buttonClicked()
    }
}
