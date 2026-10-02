import QtQuick
import QtQuick.Controls

// Switch whose knob stretches while it travels (squash and stretch) and whose track
// fades to the accent color.
Switch {
    id: control

    // 0 = off, 1 = on; everything visual derives from this one animated value.
    property real travel: checked ? 1 : 0

    implicitWidth: indicator.implicitWidth
    implicitHeight: indicator.implicitHeight
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    padding: 0
    spacing: 0
    opacity: enabled ? 1.0 : 0.4

    Behavior on travel {
        NumberAnimation { duration: Motion.normal + 40; easing.type: Easing.InOutCubic }
    }

    indicator: Rectangle {
        id: track

        implicitWidth: 46
        implicitHeight: 26
        radius: height / 2
        color: Theme.mix(control.hovered ? Theme.glassFillPressed : Theme.glassFillHover,
                         Theme.accent, control.travel)
        border.width: 1
        border.color: Theme.mix(Theme.glassStrokeStrong, Theme.withAlpha(Theme.accent, 1.0), control.travel)

        readonly property real knobBase: 20
        // Widest in the middle of the travel, normal size at both ends.
        readonly property real knobWidth: knobBase + 8 * Math.sin(control.travel * Math.PI)

        SoftShadow {
            x: knob.x - blur
            y: knob.y - blur + 2
            width: knob.width + blur * 2
            height: knob.height + blur * 2
            radius: knob.radius
            blur: 6
            color: Qt.rgba(0, 0, 0, 0.35)
        }

        Rectangle {
            id: knob

            width: track.knobWidth
            height: track.knobBase
            radius: height / 2
            y: (track.height - height) / 2
            x: 3 + control.travel * (track.width - 6 - width)
            color: "white"
            scale: control.down ? 0.92 : 1.0

            Behavior on scale { NumberAnimation { duration: Motion.fast } }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: height / 2
            color: "transparent"
            border.width: 2
            border.color: Theme.withAlpha(Theme.accent, 0.9)
            visible: control.visualFocus
        }
    }

    contentItem: Item {}
}
