import QtQuick

// Card that shows the state of the mock task. The icon morphs (rotate and cross-fade) and
// the color shifts between states; a halo pulses while the task runs.
GlassCard {
    id: card

    // One of: "idle", "running", "paused", "completed", "failed"
    property string status: "idle"
    property string detail: ""
    property bool ambientActive: true

    readonly property var statusInfo: ({
        idle: { glyph: Icons.hourglass, title: qsTr("Ready when you are"), color: Theme.textSecondary },
        running: { glyph: Icons.lightning, title: qsTr("Working on it"), color: Theme.accent },
        paused: { glyph: Icons.pause, title: qsTr("Paused"), color: Theme.warning },
        completed: { glyph: Icons.checkCircle, title: qsTr("All done"), color: Theme.success },
        failed: { glyph: Icons.warningCircle, title: qsTr("Needs attention"), color: Theme.danger }
    })
    readonly property var current: statusInfo[status] !== undefined ? statusInfo[status] : statusInfo.idle

    implicitHeight: 104
    interactive: false

    property color statusColor: current.color
    Behavior on statusColor { ColorAnimation { duration: Motion.normal } }

    onStatusChanged: iconSwap.restart()

    Item {
        id: badge

        width: 52
        height: 52
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingL + 4
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: halo

            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: card.statusColor
            opacity: 0
        }

        ParallelAnimation {
            running: card.status === "running" && card.ambientActive && !Motion.reducedMotion
            loops: Animation.Infinite
            onRunningChanged: if (!running) halo.opacity = 0

            NumberAnimation { target: halo; property: "scale"; from: 1; to: 1.55; duration: 1400; easing.type: Easing.OutCubic }
            NumberAnimation { target: halo; property: "opacity"; from: 0.6; to: 0; duration: 1400; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Theme.withAlpha(card.statusColor, 0.18)
            border.width: 1
            border.color: Theme.withAlpha(card.statusColor, 0.45)
        }

        Icon {
            id: statusIcon

            anchors.centerIn: parent
            glyph: card.current.glyph
            size: 24
            filled: true
            color: card.statusColor
        }

        SequentialAnimation {
            id: iconSwap

            ParallelAnimation {
                NumberAnimation { target: statusIcon; property: "opacity"; from: 0; to: 1; duration: Motion.normal }
                NumberAnimation { target: statusIcon; property: "rotation"; from: -90; to: 0; duration: Motion.normal + 80; easing.type: Easing.OutBack }
                NumberAnimation { target: statusIcon; property: "scale"; from: 0.6; to: 1; duration: Motion.normal + 80; easing.type: Easing.OutBack }
            }
        }
    }

    Column {
        anchors.left: badge.right
        anchors.leftMargin: Theme.spacingL
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingL
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Text {
            text: card.current.title
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontHeading + 1
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: card.detail
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            wrapMode: Text.WordWrap
        }
    }
}
