import QtQuick

// Invisible resize zones along the window edges. They hand the resize to the window manager
// (startSystemResize), which works on X11, Wayland and Windows and keeps native snapping.
// With a translucent window the zones cover the shadow margin, like GNOME's client-side
// decorations; "grip" is how far they reach into the visible window.
Item {
    id: border

    required property Window window
    property real outside: 0
    property real grip: Theme.resizeGrip
    readonly property real thickness: outside + grip
    readonly property real corner: thickness + 10

    component Zone: MouseArea {
        property int edges: 0

        acceptedButtons: Qt.LeftButton
        onPressed: border.window.startSystemResize(edges)
    }

    Zone {
        edges: Qt.LeftEdge
        cursorShape: Qt.SizeHorCursor
        x: 0
        y: border.corner
        width: border.thickness
        height: border.height - 2 * border.corner
    }
    Zone {
        edges: Qt.RightEdge
        cursorShape: Qt.SizeHorCursor
        x: border.width - width
        y: border.corner
        width: border.thickness
        height: border.height - 2 * border.corner
    }
    Zone {
        edges: Qt.TopEdge
        cursorShape: Qt.SizeVerCursor
        x: border.corner
        y: 0
        width: border.width - 2 * border.corner
        height: border.thickness
    }
    Zone {
        edges: Qt.BottomEdge
        cursorShape: Qt.SizeVerCursor
        x: border.corner
        y: border.height - height
        width: border.width - 2 * border.corner
        height: border.thickness
    }
    Zone {
        edges: Qt.TopEdge | Qt.LeftEdge
        cursorShape: Qt.SizeFDiagCursor
        width: border.corner
        height: border.corner
    }
    Zone {
        edges: Qt.TopEdge | Qt.RightEdge
        cursorShape: Qt.SizeBDiagCursor
        x: border.width - width
        width: border.corner
        height: border.corner
    }
    Zone {
        edges: Qt.BottomEdge | Qt.LeftEdge
        cursorShape: Qt.SizeBDiagCursor
        y: border.height - height
        width: border.corner
        height: border.corner
    }
    Zone {
        edges: Qt.BottomEdge | Qt.RightEdge
        cursorShape: Qt.SizeFDiagCursor
        x: border.width - width
        y: border.height - height
        width: border.corner
        height: border.corner
    }
}
