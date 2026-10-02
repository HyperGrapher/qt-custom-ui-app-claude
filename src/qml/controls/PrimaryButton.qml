import QtQuick
import QtQuick.Controls

// Main call-to-action button: accent gradient pill with a glow that reacts to hover and
// press. "breathing" adds a slow pulse to the glow (hero use only; off with reduced motion).
Button {
    id: control

    property string glyph: ""
    property bool breathing: false
    property real breath: 0

    implicitHeight: 44
    implicitWidth: Math.max(140, contentItem.implicitWidth + 44)
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    scale: down ? 0.97 : 1.0
    opacity: enabled ? 1.0 : 0.42

    Behavior on scale { NumberAnimation { duration: Motion.fast; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Motion.normal } }

    SequentialAnimation on breath {
        running: control.breathing && control.enabled && !Motion.reducedMotion
        loops: Animation.Infinite
        onRunningChanged: if (!running) control.breath = 0
        NumberAnimation { to: 1; duration: 1800; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0; duration: 1800; easing.type: Easing.InOutSine }
    }

    background: Item {
        SoftShadow {
            anchors.fill: pill
            anchors.margins: -blur
            anchors.topMargin: -blur + 6
            anchors.bottomMargin: -blur - 6
            radius: pill.radius
            blur: 22
            color: Theme.withAlpha(Theme.accent, 0.7)
            opacity: !control.enabled ? 0 : control.down ? 0.35 : control.hovered ? 0.95 : 0.55 + 0.3 * control.breath

            Behavior on opacity { NumberAnimation { duration: Motion.normal } }
        }

        Rectangle {
            id: pill

            anchors.fill: parent
            radius: height / 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Theme.accent }
                GradientStop { position: 1; color: Theme.accentSecondary }
            }

            // Brightening layer for hover; animating its opacity is cheaper than recoloring.
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "white"
                opacity: control.down ? 0.0 : control.hovered ? 0.14 : 0.0

                Behavior on opacity { NumberAnimation { duration: Motion.fast } }
            }

            // Top edge highlight gives the pill some volume.
            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.28)
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: height / 2
            color: "transparent"
            border.width: 2
            border.color: Theme.withAlpha(Theme.textPrimary, 0.85)
            visible: control.visualFocus
        }
    }

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        Row {
            id: contentRow

            anchors.centerIn: parent
            spacing: Theme.spacingS

            Icon {
                glyph: control.glyph
                size: 18
                filled: true
                color: "#160B24"
                visible: control.glyph.length > 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: control.text
                color: "#160B24"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody + 1
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
