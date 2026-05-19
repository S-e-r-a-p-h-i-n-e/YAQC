// components/Toggle.qml
import QtQuick
import qs.globals

Item {
    id: root

    property string labelText:      "Setting"
    property bool   checked:        true
    property bool   disabled:       false
    property string disabledReason: ""   // shown below the toggle when disabled and non-empty

    signal toggled(bool newState)

    implicitWidth:  parent ? parent.width : 200
    implicitHeight: root.disabled && root.disabledReason !== "" ? 46 : 30
    Behavior on implicitHeight { NumberAnimation { duration: 150 } }

    opacity: root.disabled ? 0.35 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Text {
        anchors.left:            parent.left
        anchors.verticalCenter:  parent.verticalCenter
        text:                    root.labelText
        color:                   Colors.foreground
        font.family:             "JetBrainsMono Nerd Font"
        font.pixelSize:          14
        font.weight:             Font.Bold
    }

    Text {
        anchors.left:    parent.left
        anchors.bottom:  parent.bottom
        text:            root.disabledReason
        color:           Colors.color1
        font.family:     "JetBrainsMono Nerd Font"
        font.pixelSize:  11
        visible:         root.disabled && root.disabledReason !== ""
        opacity:         0.85
    }

    Rectangle {
        id: track
        anchors.right:           parent.right
        anchors.verticalCenter:  parent.verticalCenter
        width:  44
        height: 24
        radius: height / 2
        color:  root.checked ? Colors.color2 : Colors.color0
        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            id: thumb
            width:  15
            height: 15
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            x:     root.checked ? track.width - width - 2 : 2
            color: Colors.foreground
            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape:  root.disabled ? Qt.ForbiddenCursor : Qt.PointingHandCursor
            enabled:      !root.disabled
            onClicked:    root.toggled(!root.checked)
        }
    }
}
