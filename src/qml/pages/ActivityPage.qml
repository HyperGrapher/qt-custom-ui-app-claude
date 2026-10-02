import QtQuick
import Lumina

// Progress and status page driven by the mock TaskSimulator: a large progress ring, step
// timeline, status card and the task controls.
PageBase {
    id: page

    required property TaskSimulator simulator
    property bool ambientActive: true

    readonly property int state: simulator.state
    readonly property bool running: state === TaskSimulator.Running
    readonly property string statusName: {
        switch (state) {
        case TaskSimulator.Running: return "running";
        case TaskSimulator.Paused: return "paused";
        case TaskSimulator.Completed: return "completed";
        case TaskSimulator.Failed: return "failed";
        default: return "idle";
        }
    }
    readonly property string statusDetail: {
        const steps = simulator.stepNames;
        switch (state) {
        case TaskSimulator.Running:
            return qsTr("%1 · step %2 of %3").arg(steps[Math.min(simulator.completedSteps, steps.length - 1)])
                                              .arg(Math.min(simulator.completedSteps + 1, steps.length)).arg(steps.length);
        case TaskSimulator.Paused: return qsTr("Resume whenever you like. Progress is kept.");
        case TaskSimulator.Completed: return qsTr("Every step finished without issues.");
        case TaskSimulator.Failed: return qsTr("A simulated warning stopped the task. Run it again.");
        default: return qsTr("Start the simulated task to see the widgets come alive.");
        }
    }

    PageHeader {
        id: header

        width: parent.width
        title: qsTr("Activity")
        subtitle: qsTr("A simulated background task. Nothing on your system is touched.")
        opacity: page.reveal(0)
        transform: Translate { y: page.revealShift(0) }
    }

    GlassCard {
        id: ringCard

        anchors.top: header.bottom
        anchors.topMargin: Theme.spacingXl
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        width: Math.min(parent.width * 0.48, 420)
        interactive: false
        opacity: page.reveal(1)
        transform: Translate { y: page.revealShift(1) }

        ProgressRing {
            id: ring

            readonly property real ringSize: Math.min(ringCard.width - 48, ringCard.height - controls.height - 60)

            width: ringSize
            height: ringSize
            anchors.horizontalCenter: parent.horizontalCenter
            y: (ringCard.height - controls.height - 16 - ringSize) / 2
            value: page.simulator.progress
            glow: page.running ? 1 : 0
            caption: page.state === TaskSimulator.Completed ? qsTr("complete")
                     : page.state === TaskSimulator.Failed ? qsTr("stopped")
                     : qsTr("%1 of %2 steps").arg(page.simulator.completedSteps).arg(page.simulator.stepNames.length)

            Behavior on glow { NumberAnimation { duration: Motion.slow } }
        }

        Row {
            id: controls

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacingXl
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingS

            PrimaryButton {
                id: primary

                text: page.running ? qsTr("Pause")
                      : page.state === TaskSimulator.Paused ? qsTr("Resume")
                      : page.state === TaskSimulator.Idle ? qsTr("Start")
                      : qsTr("Run again")
                glyph: page.running ? Icons.pause : Icons.play
                implicitWidth: 132
                onClicked: page.running ? page.simulator.pause() : page.simulator.start()
            }

            SecondaryButton {
                id: resetButton

                text: qsTr("Reset")
                glyph: Icons.reset
                enabled: page.state !== TaskSimulator.Idle
                onClicked: page.simulator.reset()
            }
        }
    }

    StatusCard {
        id: statusCard

        anchors.top: ringCard.top
        anchors.left: ringCard.right
        anchors.leftMargin: Theme.spacingL
        anchors.right: parent.right
        status: page.statusName
        detail: page.statusDetail
        ambientActive: page.ambientActive
        opacity: page.reveal(2)
        transform: Translate { y: page.revealShift(2) }
    }

    GlassCard {
        id: stepsCard

        anchors.top: statusCard.bottom
        anchors.topMargin: Theme.spacingL
        anchors.left: statusCard.left
        anchors.right: parent.right
        anchors.bottom: ringCard.bottom
        interactive: false
        opacity: page.reveal(3)
        transform: Translate { y: page.revealShift(3) }

        Text {
            id: stepsTitle

            x: Theme.spacingXl
            y: Theme.spacingL + 4
            text: qsTr("Steps")
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontHeading
            font.weight: Font.DemiBold
        }

        SecondaryButton {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingL
            anchors.verticalCenter: stepsTitle.verticalCenter
            text: qsTr("Simulate warning")
            glyph: Icons.warning
            enabled: page.running || page.state === TaskSimulator.Paused
            onClicked: page.simulator.fail()
        }

        StepTimeline {
            anchors.top: stepsTitle.bottom
            anchors.topMargin: Theme.spacingL
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingXl - 4
            anchors.right: parent.right
            steps: page.simulator.stepNames
            completedSteps: page.simulator.completedSteps
            running: page.running
            ambientActive: page.ambientActive
        }
    }
}
