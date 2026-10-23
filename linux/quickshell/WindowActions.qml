// Window actions: hover the top-right corner of a window to get Float,
// Maximize and Close buttons, for apps that draw no close button of their own.
//
// Focus follows the mouse, so the window under the pointer is the active one
// and the buttons always act on the window you are pointing at.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    // The hot zone is centered on the window's corner, so half of it lies in
    // the gap outside the window. 28px is Apple's default macOS control size
    // (the HIG minimum is 20).
    readonly property int zone: 28
    readonly property int inset: 8

    readonly property var win: Hyprland.activeToplevel
    // activeToplevel stays null until the first focus change, so the window
    // focused at startup is read once with hyprctl.
    property var startupIpc: null
    readonly property var ipc: win ? win.lastIpcObject : startupIpc
    // fullscreen 1 is maximized, 2 real fullscreen, where the Top layer is hidden.
    readonly property bool hasWindow: !!ipc && !!ipc.at && ipc.fullscreen !== 2
    property bool open: false
    property var tokens: ({})

    // Hyprland reports no event when a floating window is moved or resized,
    // so the corner is re-read every second as well as on every event.
    Connections {
        target: Hyprland
        function onRawEvent(event) { Hyprland.refreshToplevels() }
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: Hyprland.refreshToplevels()
    }

    Process {
        command: ["hyprctl", "activewindow", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.startupIpc = JSON.parse(text)
        }
    }

    // waybar's colors.css is the shared palette; darkman repoints the symlink,
    // so it is re-read every time the buttons are shown.
    FileView {
        id: colors
        path: Quickshell.env("HOME") + "/.config/dotfiles/linux/config/waybar/colors.css"
        onLoaded: {
            const p = {}
            const re = /@define-color\s+([\w-]+)\s+([^;]+);/g
            const css = text()
            let m
            while ((m = re.exec(css)) !== null)
                p[m[1]] = m[2].trim()
            root.tokens = p
        }
    }

    function color(name) {
        const v = tokens[name]
        if (!v) return "transparent"
        const m = v.match(/rgba\(\s*(\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\s*\)/)
        return m ? Qt.rgba(m[1] / 255, m[2] / 255, m[3] / 255, m[4]) : v
    }

    WlrLayershell.namespace: "window-actions"
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: hasWindow

    anchors.top: true
    anchors.left: true
    implicitWidth: panel.width + inset + zone / 2
    implicitHeight: zone / 2 + inset + panel.height
    // The window's top-right corner sits zone / 2 in from this surface's
    // top-right corner. A window flush with the screen edge pushes it back in.
    margins.left: hasWindow ? Math.min(ipc.at[0] + ipc.size[0] + zone / 2 - implicitWidth, screen.width - implicitWidth) : 0
    margins.top: hasWindow ? ipc.at[1] - zone / 2 : 0

    mask: Region { item: root.open ? area : hotZone }

    onOpenChanged: if (open) colors.reload()

    Item {
        id: area
        anchors.fill: parent

        HoverHandler {
            onHoveredChanged: if (!hovered) root.open = false
        }

        Item {
            id: hotZone
            anchors.top: parent.top
            anchors.right: parent.right
            width: root.zone
            height: root.zone

            HoverHandler {
                onHoveredChanged: if (hovered) root.open = true
            }
        }

        // Capsule glass, 28px buttons (the macOS default control size) 4px inside it.
        Rectangle {
            id: panel
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: root.zone / 2 + root.inset
            width: row.width + 8
            height: 36
            radius: height / 2
            color: root.color("glass-bg")
            border.width: 1
            border.color: root.color("glass-edge")
            opacity: root.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Row {
                id: row
                anchors.centerIn: parent
                spacing: 6

                Repeater {
                    model: [
                        { glyph: "󰖲", dispatcher: "hl.dsp.window.float({ action = \"toggle\", window = \"address:ADDR\" })" },
                        { glyph: "󰊓", dispatcher: "hl.dsp.window.fullscreen({ mode = \"maximized\", window = \"address:ADDR\" })" },
                        { glyph: "󰅖", dispatcher: "hl.dsp.window.close({ window = \"address:ADDR\" })", destructive: true }
                    ]

                    Rectangle {
                        required property var modelData
                        width: 28
                        height: 28
                        radius: 14
                        color: mouse.containsMouse
                            ? root.color(modelData.destructive ? "urgent" : "fill-hover")
                            : root.color("fill")

                        Text {
                            anchors.centerIn: parent
                            text: modelData.glyph
                            font.family: "Iosevka Nerd Font Propo"
                            font.pixelSize: 16
                            color: mouse.containsMouse && modelData.destructive ? "white" : root.color("fg-primary")
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Hyprland.dispatch(modelData.dispatcher.replace("ADDR", root.ipc.address))
                                root.open = false
                            }
                        }
                    }
                }
            }
        }
    }
}
