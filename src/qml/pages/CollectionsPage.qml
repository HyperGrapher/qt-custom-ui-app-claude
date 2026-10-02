import QtQuick
import Lumina

// Card collection: category filter with a sliding pill, and a grid of glass cards that
// animate when filtered (add/remove) or shuffled (move).
PageBase {
    id: page

    required property CollectionModel collection

    PageHeader {
        id: header

        width: parent.width
        title: qsTr("Collections")
        subtitle: qsTr("%1 spaces, neatly kept. Filter or shuffle to see the grid move.").arg(page.collection.count)
        opacity: page.reveal(0)
        transform: Translate { y: page.revealShift(0) }

        SecondaryButton {
            text: qsTr("Shuffle")
            glyph: Icons.shuffle
            onClicked: page.collection.shuffle()
        }
    }

    SegmentedControl {
        id: filter

        anchors.top: header.bottom
        anchors.topMargin: Theme.spacingL + 2
        options: page.collection.categories
        currentIndex: page.collection.categories.indexOf(page.collection.category)
        opacity: page.reveal(1)
        transform: Translate { y: page.revealShift(1) }
        onActivated: index => page.collection.category = options[index]
    }

    GridView {
        id: grid

        readonly property int columns: Math.max(2, Math.floor(width / 230))

        anchors.top: filter.bottom
        anchors.topMargin: Theme.spacingS
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: -8
        anchors.rightMargin: -8
        clip: true
        topMargin: 10
        bottomMargin: 10
        cellWidth: width / columns
        cellHeight: 172
        model: page.collection
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: false

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Motion.slow; easing.type: Easing.OutCubic }
                NumberAnimation { property: "scale"; from: 0.86; to: 1; duration: Motion.slow; easing.type: Easing.OutBack }
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: Motion.normal; easing.type: Easing.OutQuad }
                NumberAnimation { property: "scale"; to: 0.86; duration: Motion.normal; easing.type: Easing.InQuad }
            }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: Motion.slow; easing.type: Easing.OutCubic }
            NumberAnimation { properties: "opacity,scale"; to: 1; duration: Motion.normal }
        }
        move: Transition {
            NumberAnimation { properties: "x,y"; duration: Motion.slow + 120; easing.type: Easing.InOutCubic }
        }
        moveDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: Motion.slow + 120; easing.type: Easing.InOutCubic }
        }

        delegate: Item {
            id: cell

            required property int index
            required property string title
            required property string subtitle
            required property string iconName
            required property string sizeLabel
            required property real fill
            required property int hue

            readonly property color tint: Qt.hsla(hue / 360, 0.75, 0.66, 1)
            readonly property int revealOrder: 2 + Math.min(index, 6)

            width: grid.cellWidth
            height: grid.cellHeight

            GlassCard {
                id: card

                anchors.fill: parent
                anchors.margins: 8
                opacity: page.reveal(cell.revealOrder)
                transform: Translate { y: page.revealShift(cell.revealOrder) }

                Rectangle {
                    id: badge

                    x: Theme.spacingL
                    y: Theme.spacingL
                    width: 40
                    height: 40
                    radius: 12
                    color: Theme.withAlpha(cell.tint, 0.18)
                    border.width: 1
                    border.color: Theme.withAlpha(cell.tint, 0.35)

                    Icon {
                        anchors.centerIn: parent
                        glyph: Icons.named(cell.iconName)
                        size: 20
                        color: cell.tint
                        scale: card.hovered ? 1.12 : 1.0

                        Behavior on scale { NumberAnimation { duration: Motion.normal; easing.type: Easing.OutBack } }
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingL
                    anchors.verticalCenter: badge.verticalCenter
                    text: cell.sizeLabel
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption + 1
                    font.weight: Font.Medium
                }

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: badge.bottom
                    anchors.margins: Theme.spacingL
                    anchors.topMargin: Theme.spacingM
                    spacing: 3

                    Text {
                        width: parent.width
                        text: cell.title
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontHeading
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: cell.subtitle
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption + 1
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    id: meter

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Theme.spacingL
                    height: 5
                    radius: 2.5
                    color: Qt.rgba(1, 1, 1, 0.08)

                    Rectangle {
                        width: parent.width * cell.fill * page.reveal(cell.revealOrder + 2)
                        height: parent.height
                        radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Theme.withAlpha(cell.tint, 0.65) }
                            GradientStop { position: 1; color: cell.tint }
                        }
                    }
                }
            }
        }
    }
}
