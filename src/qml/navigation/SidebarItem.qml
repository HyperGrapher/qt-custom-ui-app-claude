import QtQuick
import QtQuick.Controls

// One navigation entry. The selected state itself is drawn by LiquidIndicator; this item
// handles hover, press, keyboard focus and the icon "pop" when it becomes selected.
AbstractButton {
    id: control

    property string glyph: Icons.house
    property bool selected: false
    property string shortcutHint: ""
    readonly property point iconCenter: Qt.point(iconSlot.x + iconSlot.width / 2,
                                                 iconSlot.y + iconSlot.height / 2)

    implicitHeight: 46
    hoverEnabled: true
    focusPolicy: Qt.TabFocus
    scale: down ? 0.97 : 1.0

    Behavior on scale { NumberAnimation { duration: Motion.fast; easing.type: Easing.OutCubic } }

    onSelectedChanged: if (selected) popAnimation.restart()

    background: Rectangle {
        radius: 12
        color: control.hovered && !control.selected ? Theme.glassFillHover : "transparent"
        border.width: control.visualFocus ? 2 : 0
        border.color: Theme.withAlpha(Theme.accent, 0.9)

        Behavior on color { ColorAnimation { duration: Motion.fast } }
    }

    contentItem: Item {
        Item {
            id: iconSlot

            x: 16 + (control.hovered && !control.selected ? 2 : 0)
            width: 22
            height: 22
            anchors.verticalCenter: parent.verticalCenter

            Behavior on x { NumberAnimation { duration: Motion.normal; easing.type: Easing.OutCubic } }

            Icon {
                id: icon

                anchors.centerIn: parent
                glyph: control.glyph
                size: 20
                filled: control.selected
                color: control.selected ? Theme.accent : Theme.textSecondary

                Behavior on color { ColorAnimation { duration: Motion.normal } }
            }
        }

        Text {
            anchors.left: iconSlot.right
            anchors.leftMargin: Theme.spacingM
            anchors.verticalCenter: parent.verticalCenter
            text: control.text
            color: control.selected || control.hovered ? Theme.textPrimary : Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody + 1
            font.weight: control.selected ? Font.DemiBold : Font.Medium

            Behavior on color { ColorAnimation { duration: Motion.fast } }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingM
            anchors.verticalCenter: parent.verticalCenter
            text: control.shortcutHint
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            opacity: control.hovered ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: Motion.normal } }
        }
    }

    SequentialAnimation {
        id: popAnimation

        NumberAnimation { target: icon; property: "scale"; to: 1.2; duration: 110; easing.type: Easing.OutQuad }
        NumberAnimation { target: icon; property: "scale"; to: 1.0; duration: 260; easing.type: Easing.OutBack }
    }
}
