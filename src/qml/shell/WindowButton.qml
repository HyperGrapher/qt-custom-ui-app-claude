import QtQuick
import QtQuick.Controls

// Minimize / maximize / close button of the custom title area. "danger" makes the hover
// state red (close button).
AbstractButton {
    id: control

    property string glyph: Icons.minus
    property bool danger: false

    implicitWidth: 44
    implicitHeight: 32
    hoverEnabled: true
    focusPolicy: Qt.NoFocus

    background: Rectangle {
        radius: Theme.radiusSmall
        color: {
            if (control.danger && (control.hovered || control.down))
                return control.down ? Qt.darker(Theme.danger, 1.15) : Theme.danger;
            if (control.down)
                return Theme.glassFillPressed;
            return control.hovered ? Theme.glassFillHover : "transparent";
        }

        Behavior on color { ColorAnimation { duration: Motion.fast } }
    }

    contentItem: Icon {
        glyph: control.glyph
        size: 16
        color: control.danger && control.hovered ? "white" : Theme.textSecondary
    }
}
