// Shows nwg-dock-hyprland when the pointer reaches the bottom edge, the way
// the macOS Dock does: anywhere along the edge, after resting there 0.2s
// (macOS's default autohide-delay), with no need to flick the mouse.
//
// The dock's own hotspot covers only the dock's width and shows it only if the
// pointer arrives fast. This strip sits over it (the dock is started with
// -hl top), so the dock's hotspot is never reached.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    WlrLayershell.namespace: "dock-edge"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    // 4px, like the macOS Dock's activation rows. It lies inside the 12px gap
    // under the windows, so it never covers them.
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 4

    function signalDock(offset) {
        Quickshell.execDetached(["pkill", "-RTMIN+" + offset, "-f", "^nwg-dock-hyprland"])
    }

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (hovered) {
                showTimer.restart()
            } else {
                showTimer.stop()
                hideTimer.restart()
            }
        }
    }

    Timer {
        id: showTimer
        interval: 200
        onTriggered: root.signalDock(2)
    }

    // The dock hides itself 1s after the pointer leaves it, but only if the
    // pointer went into it. Otherwise it would stay up, so after the same 1s
    // it is hidden unless the pointer is over it or back on the edge.
    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: if (!hover.hovered) check.running = true
    }

    Process {
        id: check
        command: ["sh", "-c", "hyprctl cursorpos; hyprctl layers -j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const nl = text.indexOf("\n")
                const [x, y] = text.slice(0, nl).split(",").map(Number)
                for (const mon of Object.values(JSON.parse(text.slice(nl + 1))))
                    for (const level of Object.values(mon.levels))
                        for (const l of level)
                            if (l.namespace === "nwg-dock" && x >= l.x && x < l.x + l.w && y >= l.y && y < l.y + l.h)
                                return
                root.signalDock(3)
            }
        }
    }
}
