import QtQuick

// Row of options with a selection pill that slides between them.
FocusScope {
    id: control

    property var options: []
    property int currentIndex: 0

    signal activated(int index)

    implicitWidth: row.implicitWidth + 8
    implicitHeight: 36
    activeFocusOnTab: true

    Keys.onLeftPressed: if (currentIndex > 0) activated(currentIndex - 1)
    Keys.onRightPressed: if (currentIndex < options.length - 1) activated(currentIndex + 1)

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusControl
        color: Theme.glassTint
        border.width: 1
        border.color: control.activeFocus ? Theme.withAlpha(Theme.accent, 0.9) : Theme.glassStroke
    }

    Rectangle {
        id: pill

        readonly property Item target: repeater.count > control.currentIndex ? repeater.itemAt(control.currentIndex) : null

        x: target ? row.x + target.x : 4
        y: 4
        width: target ? target.width : 0
        height: parent.height - 8
        radius: Theme.radiusSmall
        color: Theme.withAlpha(Theme.accent, 0.24)
        border.width: 1
        border.color: Theme.withAlpha(Theme.accent, 0.5)

        Behavior on x { NumberAnimation { duration: Motion.normal + 60; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: Motion.normal + 60; easing.type: Easing.OutCubic } }
    }

    Row {
        id: row

        x: 4
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            id: repeater

            model: control.options

            delegate: Item {
                id: option

                required property int index
                required property string modelData
                readonly property bool selected: index === control.currentIndex

                width: label.implicitWidth + 28
                height: control.height - 8

                Text {
                    id: label

                    anchors.centerIn: parent
                    text: option.modelData
                    color: option.selected ? Theme.textPrimary : hover.hovered ? Theme.textPrimary : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.weight: option.selected ? Font.DemiBold : Font.Medium

                    Behavior on color { ColorAnimation { duration: Motion.fast } }
                }

                HoverHandler {
                    id: hover

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: control.activated(option.index)
                }
            }
        }
    }
}
