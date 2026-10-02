import QtQuick
import QtQuick.Controls

// Glass button for secondary actions. Same state model as PrimaryButton, quieter visuals.
Button {
    id: control

    property string glyph: ""

    implicitHeight: 40
    implicitWidth: contentItem.implicitWidth + 36
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    scale: down ? 0.97 : 1.0
    opacity: enabled ? 1.0 : 0.4

    Behavior on scale { NumberAnimation { duration: Motion.fast; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Motion.normal } }

    background: Rectangle {
        radius: Theme.radiusControl
        color: control.down ? Theme.glassFillPressed : control.hovered ? Theme.glassFillHover : Theme.glassFill
        border.width: 1
        border.color: control.hovered ? Theme.withAlpha(Theme.accent, 0.55) : Theme.glassStroke

        Behavior on color { ColorAnimation { duration: Motion.fast } }
        Behavior on border.color { ColorAnimation { duration: Motion.fast } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.width: 2
            border.color: Theme.withAlpha(Theme.accent, 0.9)
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
                size: 16
                color: control.hovered ? Theme.accent : Theme.textSecondary
                visible: control.glyph.length > 0
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: Motion.fast } }
            }

            Text {
                text: control.text
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
