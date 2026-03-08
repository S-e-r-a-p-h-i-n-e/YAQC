// quickshell/shared/Colors.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property alias themeAdapter: themeAdapter

  readonly property color background: themeAdapter.special.background
  readonly property color foreground: themeAdapter.special.foreground
  readonly property color cursor: themeAdapter.special.cursor

  readonly property color color0: themeAdapter.colors.color0
  readonly property color color1: themeAdapter.colors.color1
  readonly property color color2: themeAdapter.colors.color2
  readonly property color color3: themeAdapter.colors.color3
  readonly property color color4: themeAdapter.colors.color4
  readonly property color color5: themeAdapter.colors.color5
  readonly property color color6: themeAdapter.colors.color6
  readonly property color color7: themeAdapter.colors.color7
  readonly property color color8: themeAdapter.colors.color8
  readonly property color color9: themeAdapter.colors.color9
  readonly property color color10: themeAdapter.colors.color10
  readonly property color color11: themeAdapter.colors.color11
  readonly property color color12: themeAdapter.colors.color12
  readonly property color color13: themeAdapter.colors.color13
  readonly property color color14: themeAdapter.colors.color14
  readonly property color color15: themeAdapter.colors.color15

  FileView {
    id: themeFile
    adapter: JsonAdapter {
      id: themeAdapter

      property JsonObject special: JsonObject {
        property color background: "#111513"
        property color foreground: "#EBDEB7"
      }

      property JsonObject colors: JsonObject {
        property color color0: "#393C3A"
        property color color1: "#323413"
        property color color2: "#4A4517"
        property color color3: "#63571B"
        property color color4: "#7B6820"
        property color color5: "#947924"
        property color color6: "#947924"
        property color color7: "#DAC88F"
        property color color8: "#988C64"
        property color color9: "#424619"
        property color color10: "#635D1F"
        property color color11: "#847325"
        property color color12: "#A48A2A"
        property color color13: "#C5A130"
        property color color14: "#C5A130"
        property color color15: "#DAC88F"
      }
    }
  }
}