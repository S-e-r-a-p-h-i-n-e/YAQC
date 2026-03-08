// modules/buttons/Buttons.qml
import QtQuick
import Quickshell
import qs.globals
import qs.components

Flow {
    id: root

    property bool   isHorizontal: true
    property real   barThickness: 40
    property string barFont:      "JetBrainsMono Nerd Font"

    spacing: 13
    flow: isHorizontal ? Flow.LeftToRight : Flow.TopToBottom

    Button {
        labelText:   "󱊣"
        labelFont:   root.barFont
        buttonSize:  root.barThickness / 1.65
        buttonColor: Colors.color7
        onButtonClicked: EventBus.togglePanel("tray")
    }

    Button {
        labelText:   "󰂚"
        labelFont:   root.barFont
        buttonSize:  root.barThickness / 1.65
        buttonColor: Colors.color7
        onButtonClicked: Quickshell.execDetached({ command: ["swaync-client", "-t"] })
    }

    Button {
        labelText:   ""
        labelFont:   root.barFont
        buttonSize:  root.barThickness / 1.65
        buttonColor: Colors.color7
        onButtonClicked: EventBus.togglePanel("theming")
    }

    Button {
        labelText:   "⏻"
        labelFont:   root.barFont
        buttonSize:  root.barThickness / 1.65
        buttonColor: Colors.color7
        onButtonClicked: Quickshell.execDetached({ command: ["wlogout"] })
    }
}
