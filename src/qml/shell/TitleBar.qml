import QtQuick

// Custom title area: drag to move, double-click to maximize/restore, window buttons on the
// right. It sits below the rest of the UI, so presses on controls never reach it, while
// presses on empty space (including the sidebar's logo area) do.
Item {
    id: titleBar

    required property Window window
    readonly property bool maximized: window.visibility === Window.Maximized
                                      || window.visibility === Window.FullScreen

    function toggleMaximize() {
        if (maximized)
            window.showNormal();
        else
            window.showMaximized();
    }

    implicitHeight: Theme.titleBarHeight

    DragHandler {
        target: null
        grabPermissions: PointerHandler.CanTakeOverFromAnything
        onActiveChanged: if (active) titleBar.window.startSystemMove()
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.DragThreshold
        onDoubleTapped: titleBar.toggleMaximize()
    }

    Row {
        id: buttons

        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingS + 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        WindowButton {
            glyph: Icons.minus
            onClicked: titleBar.window.showMinimized()
        }

        WindowButton {
            glyph: titleBar.maximized ? Icons.copy : Icons.square
            onClicked: titleBar.toggleMaximize()
        }

        WindowButton {
            glyph: Icons.close
            danger: true
            onClicked: titleBar.window.close()
        }
    }
}
