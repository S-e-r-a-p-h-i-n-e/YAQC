// globals/Style.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Defaults are defined here — valid from frame 0, before the file loads.
    // The JsonAdapter pushes updates via onChanged handlers once the file is read.

    // ── Bar ───────────────────────────────────────────────────────────────
    property real   barSize:    50
    property real   moduleSize: 28
    property string barFont:    "JetBrainsMono Nerd Font"
    property real   barPadding: 12

    // ── Slots ─────────────────────────────────────────────────────────────
    property real slotSpacing: 8

    // ── Pills ─────────────────────────────────────────────────────────────
    property real pillPadding: 16
    property real pillSpacing: 6
    property real pillOpacity: 0.6

    // ── Chips ─────────────────────────────────────────────────────────────
    property real chipSpacing:      6
    property real chipInnerSpacing: 5

    // ── Border ────────────────────────────────────────────────────────────
    property real borderWidth:  10
    property real cornerRadius: 20

    FileView {
        path: Qt.resolvedUrl("../style.json")
        adapter: JsonAdapter {
            property real   barSize:    50
            property real   moduleSize: 28
            property string barFont:    "JetBrainsMono Nerd Font"
            property real   barPadding: 12

            property real slotSpacing: 8

            property real pillPadding: 16
            property real pillSpacing: 6
            property real pillOpacity: 0.6

            property real chipSpacing:      6
            property real chipInnerSpacing: 5

            property real borderWidth:  10
            property real cornerRadius: 20

            onBarSizeChanged:          root.barSize          = barSize
            onModuleSizeChanged:       root.moduleSize       = moduleSize
            onBarFontChanged:          root.barFont          = barFont
            onBarPaddingChanged:       root.barPadding       = barPadding
            onSlotSpacingChanged:      root.slotSpacing      = slotSpacing
            onPillPaddingChanged:      root.pillPadding      = pillPadding
            onPillSpacingChanged:      root.pillSpacing      = pillSpacing
            onPillOpacityChanged:      root.pillOpacity      = pillOpacity
            onChipSpacingChanged:      root.chipSpacing      = chipSpacing
            onChipInnerSpacingChanged: root.chipInnerSpacing = chipInnerSpacing
            onBorderWidthChanged:      root.borderWidth      = borderWidth
            onCornerRadiusChanged:     root.cornerRadius     = cornerRadius
        }
    }
}
