// engine/WallpaperEngine.qml
// Native wallpaper engine — no swww or mpvpaper dependency.
// Rendering is handled by WallpaperWindow (engine/WallpaperWindow.qml).
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

Singleton {
    id: root

    // ── File discovery ────────────────────────────────────────────────────
    property var wallpapers: []
    readonly property string wallDir: Quickshell.env("HOME") + "/.config/quickshell/wallpapers"
    readonly property var    videoExts: ["mp4", "webm", "mkv", "mov", "avi"]

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
                let files  = this.text.split('\n').filter(p => p.trim().length > 0)
                let parsed = []
                for (let i = 0; i < files.length; i++) {
                    let path  = files[i]
                    let name  = path.substring(path.lastIndexOf('/') + 1)
                    let ext   = name.substring(name.lastIndexOf('.') + 1).toLowerCase()
                    let video = root.videoExts.indexOf(ext) !== -1
                    let gif   = ext === "gif"
                    parsed.push({ name, path, video, gif })
                }
                parsed.sort((a, b) => a.name.localeCompare(b.name))
                root.wallpapers = parsed
            }
        }
    }

    function refresh() { finder.running = true }

    // ── Apply ─────────────────────────────────────────────────────────────
    // Saves to Config so WallpaperWindow reacts and the path persists across restarts.
    function apply(path) {
        Config.saveSetting("wallpaperPath", path)
    }

    Component.onCompleted: refresh()
}
