import QtQuick

// One preference: icon, title, description, and a control on the right.
Item {
    id: row

    property string glyph: Icons.sliders
    property string title: ""
    property string description: ""
    default property alias control: controlSlot.data

    implicitHeight: 64
    implicitWidth: 480

    Rectangle {
        id: iconBadge

        width: 36
        height: 36
        radius: 10
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.withAlpha(Theme.accent, 0.14)

        Icon {
            anchors.centerIn: parent
            glyph: row.glyph
            size: 18
            color: Theme.accent
        }
    }

    Column {
        anchors.left: iconBadge.right
        anchors.leftMargin: Theme.spacingM + 2
        anchors.right: controlSlot.left
        anchors.rightMargin: Theme.spacingL
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: row.title
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody + 1
            font.weight: Font.Medium
        }

        Text {
            width: parent.width
            text: row.description
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption + 1
            wrapMode: Text.WordWrap
            visible: text.length > 0
        }
    }

    Item {
        id: controlSlot

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
