import QtQuick
import QtQuick.Controls

// Slider with an accent fill; the handle grows while hovered or dragged.
Slider {
    id: control

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitWidth: 220
    implicitHeight: 28

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 6
        radius: 3
        color: Theme.glassFillHover

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Theme.accent }
                GradientStop { position: 1; color: Theme.accentSecondary }
            }
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 18
        height: 18
        radius: 9
        color: "white"
        scale: control.pressed ? 1.25 : control.hovered ? 1.12 : 1.0
        border.width: control.visualFocus ? 3 : 0
        border.color: Theme.accent

        Behavior on scale { NumberAnimation { duration: Motion.fast; easing.type: Easing.OutCubic } }
    }
}
