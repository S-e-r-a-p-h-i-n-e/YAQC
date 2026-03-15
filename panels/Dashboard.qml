// panels/Dashboard.qml — notification + control center hybrid
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris
import qs.components
import qs.globals
import qs.modules.audio
import qs.modules.network
import qs.modules.media
import qs.modules.notifications
import qs.modules.idleinhibitor
import qs.modules.systeminfo

Panel {
    id: dashboardPanel

    panelWidth:      380
    panelHeight:     720
    animationPreset: "slide"

    // QuickToggle width — panel width minus Panel.qml's 25px margins each side
    readonly property real contentWidth: panelWidth - 50

    ScrollView {
        id: scroll
        anchors.fill: parent
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle { implicitWidth: 4; radius: 2; color: Colors.color7; opacity: 0.4 }
        }

        Column {
            width:      scroll.width
            spacing:    14
            topPadding: 4

            // ── Date + stats ──────────────────────────────────────────────
            Column {
                width:   parent.width
                spacing: 4

                Text {
                    text:           Time.date
                    color:          Colors.foreground
                    font.family:    Style.barFont
                    font.pixelSize: 22
                    font.weight:    Font.ExtraBold
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16
                    Row {
                        spacing: 4
                        Text { text: "󰍛"; color: Colors.color7; font.family: Style.barFont; font.pixelSize: 12 }
                        Text { text: SystemInfo.cpuPercent + "%"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 12 }
                    }
                    Row {
                        spacing: 4
                        Text { text: "󰾆"; color: Colors.color7; font.family: Style.barFont; font.pixelSize: 12 }
                        Text { text: SystemInfo.memPercent + "%"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 12 }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }

            // ── Quick toggles ─────────────────────────────────────────────
            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                columns:   4
                spacing:   8

                // Wi-Fi — left click toggles, right click opens nm-applet
                QuickToggle {
                    icon:         Network.wifiEnabled ? (Network.connected ? "󰤨" : "󰤮") : "󰤭"
                    label:        "Wi-Fi"
                    active:       Network.wifiEnabled
                    onTap:        Network.toggleWifi()
                    onRightTap:   Network.openApplet()
                }
                QuickToggle {
                    icon:    Audio.sinkMuted ? "󰝟" : "󰕾"
                    label:   "Sound"
                    active:  !Audio.sinkMuted
                    onTap:   Audio.muteSink()
                }
                QuickToggle {
                    icon:    Audio.srcMuted ? "󰍭" : "󰍬"
                    label:   "Mic"
                    active:  !Audio.srcMuted
                    onTap:   Audio.muteSrc()
                }
                QuickToggle {
                    icon:    IdleInhibitor.icon
                    label:   IdleInhibitor.inhibited ? "Awake" : "Sleep"
                    active:  IdleInhibitor.inhibited
                    onTap:   IdleInhibitor.toggle()
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }

            // ── Volume sliders ────────────────────────────────────────────
            Column {
                width:   parent.width
                spacing: 12

                SliderRow {
                    icon:    Audio.speakerIcon
                    value:   Audio.sinkVolume / 100
                    onMoved: (v) => Audio.setSinkVolume(Math.round(v * 100))
                }
                SliderRow {
                    icon:    Audio.micIcon
                    value:   Audio.srcVolume / 100
                    onMoved: (v) => Audio.setSrcVolume(Math.round(v * 100))
                }
            }

            // ── Media card ────────────────────────────────────────────────
            Rectangle {
                width:   parent.width
                height:  mediaInner.implicitHeight + 24
                radius:  12
                color:   Colors.color0
                visible: Media.hasPlayer

                Column {
                    id: mediaInner
                    anchors {
                        left: parent.left; right: parent.right
                        top:  parent.top
                        margins: 14
                    }
                    spacing: 10

                    // ── Album art + title/artist ──────────────────────────
                    Row {
                        width:   parent.width
                        spacing: 12

                        // Album art
                        Rectangle {
                            width:  52
                            height: 52
                            radius: 8
                            color:  Colors.color8
                            clip:   true

                            Image {
                                anchors.fill: parent
                                source:       Media.artUrl
                                fillMode:     Image.PreserveAspectCrop
                                smooth:       true
                                visible:      Media.artUrl !== ""
                            }

                            // Fallback icon when no art
                            Text {
                                anchors.centerIn: parent
                                visible:      Media.artUrl === ""
                                text:         "󰎆"
                                color:        Colors.color0
                                font.family:  Style.barFont
                                font.pixelSize: 24
                            }
                        }

                        // Title + artist + album
                        Column {
                            width:   parent.width - 52 - 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            // Scrolling title — circular marquee
                            Item {
                                id: titleClip
                                width:  parent.width
                                height: titleText.implicitHeight
                                clip:   true

                                Text {
                                    id: titleText
                                    text:           Media.title
                                    color:          Colors.foreground
                                    font.family:    Style.barFont
                                    font.pixelSize: 13
                                    font.weight:    Font.Bold

                                    readonly property bool overflows: implicitWidth > titleClip.width

                                    SequentialAnimation on x {
                                        loops:   Animation.Infinite
                                        running: titleText.overflows

                                        PauseAnimation  { duration: 1500 }
                                        // Scroll the full text + gap off to the left
                                        NumberAnimation {
                                            from:     0
                                            to:       -(titleText.implicitWidth + 32)
                                            duration: Math.max(1, titleText.implicitWidth * 28)
                                            easing.type: Easing.Linear
                                        }
                                        // Instantly place back at right edge of clip so it feels seamless
                                        PropertyAction  { value: titleClip.width }
                                        // Scroll from right edge back to 0
                                        NumberAnimation {
                                            to:       0
                                            duration: Math.max(1, titleClip.width * 28)
                                            easing.type: Easing.Linear
                                        }
                                    }
                                }
                            }

                            Text {
                                width:          parent.width
                                text:           Media.artist
                                color:          Colors.color7
                                font.family:    Style.barFont
                                font.pixelSize: 11
                                elide:          Text.ElideRight
                            }
                            Text {
                                width:          parent.width
                                visible:        Media.album !== ""
                                text:           Media.album
                                color:          Colors.color8
                                font.family:    Style.barFont
                                font.pixelSize: 10
                                elide:          Text.ElideRight
                            }
                        }
                    }

                    // ── Seek bar ──────────────────────────────────────────
                    Column {
                        width:   parent.width
                        spacing: 4

                        Rectangle {
                            id: seekTrack
                            width:  parent.width
                            height: 4
                            radius: 2
                            color:  Colors.color8
                            opacity: 0.4

                            Rectangle {
                                width:  Media.length > 0
                                        ? Math.min(1, Media.position / Media.length) * parent.width
                                        : 0
                                height: parent.height
                                radius: parent.radius
                                color:  Colors.color7
                            }

                            MouseArea {
                                anchors.fill:    parent
                                anchors.margins: -6
                                cursorShape:     Qt.PointingHandCursor
                                onClicked:       (e) => Media.seekTo((e.x / seekTrack.width) * Media.length)
                                onPositionChanged: (e) => {
                                    if (pressed) Media.seekTo(Math.max(0, Math.min(1, e.x / seekTrack.width)) * Media.length)
                                }
                            }
                        }

                        Item {
                            width:  parent.width
                            height: 12

                            Text {
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                text:        Media.fmt(Media.position)
                                color:       Colors.color8
                                font.family: Style.barFont
                                font.pixelSize: 10
                            }
                            Text {
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                text:        Media.fmt(Media.length)
                                color:       Colors.color8
                                font.family: Style.barFont
                                font.pixelSize: 10
                            }
                        }
                    }

                    // ── Controls ──────────────────────────────────────────
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        MediaButton {
                            visible: Media.isSpotify
                            icon:    "󰒝"
                            bgColor: Media.shuffle ? Colors.color7 : Colors.color5
                            onClicked: Media.toggleShuffle()
                        }

                        MediaButton { icon: "󰒮"; bgColor: Colors.color5; onClicked: Media.prev() }
                        MediaButton { icon: Media.isPlaying ? "󰏤" : "󰐊"; bgColor: Colors.color7; onClicked: Media.toggle() }
                        MediaButton { icon: "󰒭"; bgColor: Colors.color5; onClicked: Media.next() }

                        MediaButton {
                            visible: Media.isSpotify
                            icon:    Media.loopState === MprisLoopState.Track ? "󰑘" : "󰑖"
                            bgColor: Media.loopState !== MprisLoopState.None ? Colors.color7 : Colors.color5
                            onClicked: Media.cycleLoop()
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }

            // ── Notifications header ──────────────────────────────────────
            Item {
                width:  parent.width
                height: 20

                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    text:        "Notifications" + (Notifications.count > 0 ? "  " + Notifications.count : "")
                    color:       Colors.foreground
                    font.family: Style.barFont
                    font.pixelSize: 13
                    font.weight: Font.Bold
                }
                Text {
                    visible:     Notifications.count > 0
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    text:        "Clear all"
                    color:       Colors.color8
                    font.family: Style.barFont
                    font.pixelSize: 11
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    Notifications.dismissAll()
                    }
                }
            }

            // ── Notification list ─────────────────────────────────────────
            Column {
                width:   parent.width
                spacing: 6

                Repeater {
                    model: Notifications.notifications

                    delegate: Rectangle {
                        id: notifCard
                        required property string app
                        required property string summary
                        required property string body
                        required property string time
                        required property int    index

                        width:  parent.width
                        height: notifContent.implicitHeight + 20
                        radius: 10
                        color:  Colors.color0

                        Column {
                            id: notifContent
                            anchors {
                                left: parent.left; right: dismissBtn.left
                                verticalCenter: parent.verticalCenter
                                leftMargin: 12; rightMargin: 8
                            }
                            spacing: 3

                            Row {
                                spacing: 6
                                Text {
                                    text:        notifCard.app
                                    color:       Colors.color7
                                    font.family: Style.barFont
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text:        notifCard.time
                                    color:       Colors.color8
                                    font.family: Style.barFont
                                    font.pixelSize: 10
                                    opacity:     0.6
                                }
                            }
                            Text {
                                width:       notifContent.width
                                text:        notifCard.summary
                                color:       Colors.foreground
                                font.family: Style.barFont
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                elide:       Text.ElideRight
                                visible:     text !== ""
                            }
                            Text {
                                width:            notifContent.width
                                text:             notifCard.body
                                color:            Colors.color8
                                font.family:      Style.barFont
                                font.pixelSize:   11
                                wrapMode:         Text.WordWrap
                                maximumLineCount: 2
                                elide:            Text.ElideRight
                                visible:          text !== ""
                            }
                        }

                        Text {
                            id: dismissBtn
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12 }
                            text:        "󰅖"
                            color:       Colors.color8
                            font.family: Style.barFont
                            font.pixelSize: 14

                            MouseArea {
                                anchors.fill:    parent
                                anchors.margins: -6
                                cursorShape:     Qt.PointingHandCursor
                                onClicked:       Notifications.dismissAt(notifCard.index)
                            }
                        }
                    }
                }

                Text {
                    visible:     Notifications.count === 0
                    text:        "No notifications"
                    color:       Colors.color8
                    font.family: Style.barFont
                    font.pixelSize: 12
                    opacity:     0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Item { width: 1; height: 4 }
        }
    }

    // ── Inline components ─────────────────────────────────────────────────

    component QuickToggle: Rectangle {
        property string icon:   ""
        property string label:  ""
        property bool   active: false
        signal tap()
        signal rightTap()

        // Fill grid evenly: scroll.width / 4 columns minus spacing
        width:  Math.floor((scroll.width - 24) / 4)
        height: 54
        radius: 14
        color:  active ? Colors.color7 : Colors.color0
        Behavior on color { ColorAnimation { duration: 150 } }

        Column {
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:        icon
                color:       active ? Colors.background : Colors.foreground
                font.family: Style.barFont
                font.pixelSize: 22
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:        label
                color:       active ? Colors.background : Colors.color8
                font.family: Style.barFont
                font.pixelSize: 10
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        MouseArea {
            anchors.fill:    parent
            cursorShape:     Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (e) => {
                if (e.button === Qt.RightButton) parent.rightTap()
                else parent.tap()
            }
        }
    }

    component SliderRow: Item {
        property string icon:  ""
        property real   value: 0.0
        signal moved(real newValue)

        width:  parent.width
        height: 28

        Text {
            id: sliderIcon
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            text:        icon
            color:       Colors.color7
            font.family: Style.barFont
            font.pixelSize: 22
            width:       28
        }

        Rectangle {
            id: track
            anchors {
                left: sliderIcon.right; right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 10
            }
            height: 6
            radius: 3
            color:  Colors.color0

            Rectangle {
                width:  track.width * Math.max(0, Math.min(1, value))
                height: parent.height
                radius: parent.radius
                color:  Colors.color7
                Behavior on width { NumberAnimation { duration: 80 } }
            }

            MouseArea {
                anchors.fill:    parent
                anchors.margins: -8
                cursorShape:     Qt.PointingHandCursor
                onClicked:       (e) => moved(Math.max(0, Math.min(1, e.x / track.width)))
                onPositionChanged: (e) => { if (pressed) moved(Math.max(0, Math.min(1, e.x / track.width))) }
            }
        }
    }

    component MediaButton: Rectangle {
        property string icon:    ""
        property color  bgColor: Colors.color0
        signal clicked()

        width:  36
        height: 36
        radius: 18
        color:  bgColor

        Text {
            anchors.centerIn: parent
            text:        parent.icon
            color:       Colors.background
            font.family: Style.barFont
            font.pixelSize: 16
        }
        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    parent.clicked()
        }
    }
}
