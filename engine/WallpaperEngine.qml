// quickshell/engine/WallpaperEngine.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var wallpapers: []
    readonly property string wallDir: Quickshell.env("HOME") + "/wallpapers" // Replace with your own wallpaper path

    // Track which backend is currently active so we can tear it down cleanly
    // before switching: "swww" | "mpvpaper" | ""
    property string activeBackend: ""

    // Video extensions handled by mpvpaper
    readonly property var videoExts: ["mp4", "webm", "mkv", "mov", "avi"]

    function isVideo(path) {
        let ext = path.substring(path.lastIndexOf('.') + 1).toLowerCase()
        return videoExts.indexOf(ext) !== -1
    }

    Process {
        id: finder
        command: [
            "sh", "-c",
            "find '" + root.wallDir + "' -type f \\( " +
            "-iname \\*.jpg -o -iname \\*.jpeg -o -iname \\*.png -o " +
            "-iname \\*.webp -o -iname \\*.gif -o " +
            "-iname \\*.mp4 -o -iname \\*.webm -o -iname \\*.mkv -o " +
            "-iname \\*.mov -o -iname \\*.avi \\)"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let files = this.text.split('\n').filter(p => p.trim().length > 0)
                let parsed = []
                for (let i = 0; i < files.length; i++) {
                    let path = files[i]
                    let name = path.substring(path.lastIndexOf('/') + 1)
                    let ext  = name.substring(name.lastIndexOf('.') + 1).toLowerCase()
                    let video = root.videoExts.indexOf(ext) !== -1
                    let gif   = ext === "gif"
                    parsed.push({ name: name, path: path, video: video, gif: gif })
                }
                parsed.sort((a, b) => a.name.localeCompare(b.name))
                root.wallpapers = parsed
            }
        }
    }

    function refresh() {
        finder.running = true
    }

    function apply(path) {
        if (isVideo(path)) {
            _applyVideo(path)
        } else {
            _applyImage(path)
        }
    }

    function _applyImage(path) {
        let cmd = activeBackend === "mpvpaper"
            ? "pkill -x mpvpaper; sleep 0.3; swww img '" + path + "' --transition-type grow --transition-pos 0.5,0.5 --transition-step 90"
            : "swww img '" + path + "' --transition-type grow --transition-pos 0.5,0.5 --transition-step 90"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        activeBackend = "swww"
    }

    function _applyVideo(path) {
        // Kill existing backend, then launch mpvpaper across all monitors
        // no-audio and loop are passed as mpv options
        let kill = activeBackend !== "" ? "pkill -x mpvpaper; pkill -x swww-daemon; sleep 0.3; " : ""
        let cmd  = kill + "mpvpaper -o 'no-audio loop' '*' '" + path + "'"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        activeBackend = "mpvpaper"
    }

    Component.onCompleted: refresh()
}
