import QtQuick
import Lumina

// Small diagnostics box: frame rate, frame times and a running frame counter. When the
// counter stands still, the app is not rendering at all.
Rectangle {
    id: overlay

    property alias window: stats.window
    property bool ambientActive: false

    implicitWidth: 196
    implicitHeight: column.implicitHeight + 20
    radius: Theme.radiusControl
    color: Qt.rgba(0.02, 0.0, 0.05, 0.62)
    border.width: 1
    border.color: Theme.glassStroke

    FrameStats {
        id: stats

        active: overlay.visible
    }

    Column {
        id: column

        x: 12
        y: 10
        spacing: 3

        component Line: Text {
            color: Theme.textSecondary
            font.family: "monospace"
            font.pixelSize: 11
        }

        Line {
            text: "FPS        " + stats.framesPerSecond.toFixed(1)
            color: Theme.textPrimary
        }
        Line { text: "frame avg  " + stats.averageFrameMs.toFixed(1) + " ms" }
        Line { text: "frame max  " + stats.worstFrameMs.toFixed(1) + " ms" }
        Line { text: "frames     " + stats.totalFrames }
        Line { text: "ambient    " + (overlay.ambientActive ? "running" : "paused") }
        Line { text: "motion     " + (Motion.reducedMotion ? "reduced" : "full") }
    }
}
