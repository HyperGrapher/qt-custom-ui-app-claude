import QtQuick

// Vertical list of task steps. Connector lines fill as steps complete and the active step's
// dot pulses.
Column {
    id: timeline

    property var steps: []
    property int completedSteps: 0
    property bool running: false
    property bool ambientActive: true

    spacing: 0

    Repeater {
        model: timeline.steps

        delegate: Item {
            id: step

            required property int index
            required property string modelData
            readonly property bool done: index < timeline.completedSteps
            readonly property bool active: index === timeline.completedSteps && timeline.running
            readonly property bool last: index === timeline.steps.length - 1

            width: timeline.width
            height: 48

            Rectangle {
                id: connector

                x: dot.x + dot.width / 2 - 1
                y: dot.y + dot.height + 4
                width: 2
                height: step.height - dot.height - 8
                radius: 1
                color: Qt.rgba(1, 1, 1, 0.1)
                visible: !step.last

                Rectangle {
                    width: parent.width
                    height: step.done ? parent.height : 0
                    radius: 1
                    color: Theme.accent

                    Behavior on height { NumberAnimation { duration: Motion.slow; easing.type: Easing.InOutCubic } }
                }
            }

            Rectangle {
                id: dot

                x: 4
                y: 6
                width: 18
                height: 18
                radius: 9
                color: step.done ? Theme.accent : "transparent"
                border.width: 2
                border.color: step.done || step.active ? Theme.accent : Qt.rgba(1, 1, 1, 0.25)
                scale: step.active ? 1.1 : 1.0

                Behavior on color { ColorAnimation { duration: Motion.normal } }
                Behavior on border.color { ColorAnimation { duration: Motion.normal } }
                Behavior on scale { NumberAnimation { duration: Motion.normal; easing.type: Easing.OutBack } }

                Icon {
                    anchors.centerIn: parent
                    glyph: Icons.check
                    size: 11
                    color: "#160B24"
                    opacity: step.done ? 1 : 0
                    scale: step.done ? 1 : 0.4

                    Behavior on opacity { NumberAnimation { duration: Motion.normal } }
                    Behavior on scale { NumberAnimation { duration: Motion.normal; easing.type: Easing.OutBack } }
                }

                Rectangle {
                    id: ripple

                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.accent
                    opacity: 0
                }

                ParallelAnimation {
                    running: step.active && timeline.ambientActive && !Motion.reducedMotion
                    loops: Animation.Infinite
                    onRunningChanged: if (!running) ripple.opacity = 0

                    NumberAnimation { target: ripple; property: "scale"; from: 1; to: 2.1; duration: 1200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: ripple; property: "opacity"; from: 0.7; to: 0; duration: 1200; easing.type: Easing.OutCubic }
                }
            }

            Text {
                anchors.left: dot.right
                anchors.leftMargin: Theme.spacingM + 2
                y: dot.y + (dot.height - height) / 2
                text: step.modelData
                color: step.done || step.active ? Theme.textPrimary : Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody + 1
                font.weight: step.active ? Font.DemiBold : Font.Normal

                Behavior on color { ColorAnimation { duration: Motion.normal } }
            }
        }
    }
}
