import QtQuick

// Title and subtitle at the top of a page, with optional actions on the right.
Item {
    id: header

    property string title: ""
    property string subtitle: ""
    default property alias actions: actionRow.data

    implicitHeight: Math.max(titleColumn.implicitHeight, actionRow.implicitHeight)

    Column {
        id: titleColumn

        anchors.left: parent.left
        anchors.right: actionRow.left
        anchors.rightMargin: Theme.spacingL
        spacing: 6

        Text {
            text: header.title
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontDisplay
            font.weight: Font.Bold
            font.letterSpacing: -0.6
        }

        Text {
            width: parent.width
            text: header.subtitle
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody + 1
            wrapMode: Text.WordWrap
        }
    }

    Row {
        id: actionRow

        anchors.right: parent.right
        anchors.verticalCenter: titleColumn.verticalCenter
        spacing: Theme.spacingS
    }
}
