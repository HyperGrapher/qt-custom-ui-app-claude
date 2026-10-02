import QtQuick

// Floating glass sidebar: brand, section navigation with the liquid selection pill, and a
// quick reduced-motion switch at the bottom.
FocusScope {
    id: sidebar

    property var sections: []
    property int currentIndex: 0
    property bool reducedMotion: false

    // origin: center of the clicked icon in sidebar coordinates (start of the mood spread)
    signal activated(int index, point origin)
    signal reducedMotionToggled(bool enabled)

    readonly property int itemHeight: 46
    readonly property int itemSpacing: 6

    function originFor(index) {
        const item = repeater.itemAt(index);
        if (!item)
            return Qt.point(width / 2, nav.y);
        return item.mapToItem(sidebar, item.iconCenter.x, item.iconCenter.y);
    }

    function select(index) {
        if (index < 0 || index >= sections.length)
            return;
        activated(index, originFor(index));
    }

    function indicatorTop(index) {
        return index * (itemHeight + itemSpacing);
    }

    onCurrentIndexChanged: indicator.moveTo(indicatorTop(currentIndex), indicatorTop(currentIndex) + itemHeight)
    Component.onCompleted: indicator.jumpTo(indicatorTop(currentIndex), indicatorTop(currentIndex) + itemHeight)

    Keys.onUpPressed: select(Math.max(0, currentIndex - 1))
    Keys.onDownPressed: select(Math.min(sections.length - 1, currentIndex + 1))

    GlassPanel {
        anchors.fill: parent
        tintStrength: 1
    }

    Row {
        id: brand

        x: 22
        y: 22
        spacing: Theme.spacingM

        Rectangle {
            width: 30
            height: 30
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            gradient: Gradient {
                GradientStop { position: 0; color: Theme.accent }
                GradientStop { position: 1; color: Theme.accentSecondary }
            }

            Icon {
                anchors.centerIn: parent
                glyph: Icons.sparkle
                filled: true
                size: 16
                color: "#160B24"
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Lumina"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 17
            font.weight: Font.Bold
            font.letterSpacing: 0.3
        }
    }

    Text {
        x: 24
        y: nav.y - 26
        text: qsTr("WORKSPACE")
        color: Theme.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.letterSpacing: 1.4
    }

    Item {
        id: nav

        x: 12
        y: 110
        width: parent.width - 24
        height: sidebar.sections.length * (sidebar.itemHeight + sidebar.itemSpacing)

        LiquidIndicator {
            id: indicator

            width: parent.width
        }

        Column {
            width: parent.width
            spacing: sidebar.itemSpacing

            Repeater {
                id: repeater

                model: sidebar.sections

                delegate: SidebarItem {
                    required property int index
                    required property var modelData

                    width: nav.width
                    height: sidebar.itemHeight
                    text: modelData.title
                    glyph: modelData.glyph
                    shortcutHint: "Ctrl+" + (index + 1)
                    selected: index === sidebar.currentIndex
                    onClicked: sidebar.select(index)
                }
            }
        }
    }

    Rectangle {
        id: motionCard

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 12
        height: 64
        radius: 14
        color: Theme.glassFill
        border.width: 1
        border.color: Theme.glassStroke

        Icon {
            id: motionIcon

            x: 14
            anchors.verticalCenter: parent.verticalCenter
            glyph: Icons.moon
            size: 18
            color: Theme.accent
        }

        Column {
            anchors.left: motionIcon.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: qsTr("Reduced motion")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
            }

            Text {
                text: sidebar.reducedMotion ? qsTr("Calm and static") : qsTr("Full animation")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }
        }

        ToggleSwitch {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: sidebar.reducedMotion
            onToggled: sidebar.reducedMotionToggled(checked)
        }
    }
}
