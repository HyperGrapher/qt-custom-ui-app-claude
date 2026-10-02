import QtQuick

// Summary page: greeting, the energy orb hero, a "Run demo" call to action and three stats.
PageBase {
    id: page

    property real ambientTime: 0

    signal runDemoRequested

    readonly property var greeting: {
        const hour = new Date().getHours();
        if (hour < 5 || hour >= 22)
            return qsTr("Good night");
        if (hour < 12)
            return qsTr("Good morning");
        if (hour < 18)
            return qsTr("Good afternoon");
        return qsTr("Good evening");
    }

    function runDemo() {
        orb.playPulse();
        focusScore.value = 84 + Math.round(Math.random() * 15);
        hoursSaved.value = Math.round((hoursSaved.value + 0.6 + Math.random() * 1.4) * 10) / 10;
        streak.value = streak.value + 1;
        runDemoRequested();
    }

    onEntered: {
        focusScore.replay();
        hoursSaved.replay();
        streak.replay();
    }

    PageHeader {
        id: header

        width: parent.width
        title: page.greeting
        subtitle: qsTr("Everything is in balance. Here is the pulse of your workspace today.")
        opacity: page.reveal(0)
        transform: Translate { y: page.revealShift(0) }
    }

    Item {
        id: hero

        anchors.top: header.bottom
        anchors.bottom: stats.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: Theme.spacingL

        readonly property real orbSize: Math.max(160, Math.min(width, height - runButton.height - 8) * 1.08)

        EnergyOrb {
            id: orb

            width: hero.orbSize
            height: hero.orbSize
            anchors.horizontalCenter: parent.horizontalCenter
            y: (hero.height - runButton.height - hero.orbSize * 0.86) / 2 - hero.orbSize * 0.07
            time: page.ambientTime
            opacity: page.reveal(1)
            scale: 0.9 + 0.1 * page.reveal(1)
        }

        PrimaryButton {
            id: runButton

            anchors.horizontalCenter: parent.horizontalCenter
            y: orb.y + hero.orbSize * 0.86
            text: qsTr("Run demo")
            glyph: Icons.play
            breathing: page.isCurrent
            opacity: page.reveal(2)
            transform: Translate { y: page.revealShift(2) }
            onClicked: page.runDemo()
        }
    }

    Row {
        id: stats

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        height: 122
        spacing: Theme.spacingL

        readonly property real cardWidth: (width - 2 * spacing) / 3

        component StatCard: GlassCard {
            id: card

            property string glyph
            property string label
            property string note
            property real value: 0
            property int decimals: 0
            property int order: 0

            function replay() {
                numberText.replay();
            }

            width: stats.cardWidth
            height: stats.height
            opacity: page.reveal(order)
            transform: Translate { y: page.revealShift(card.order) }

            Rectangle {
                id: badge

                x: Theme.spacingL + 2
                y: Theme.spacingL + 2
                width: 34
                height: 34
                radius: 10
                color: Theme.withAlpha(Theme.accent, 0.16)

                Icon {
                    anchors.centerIn: parent
                    glyph: card.glyph
                    size: 18
                    color: Theme.accent
                }
            }

            Text {
                anchors.left: badge.right
                anchors.leftMargin: Theme.spacingM
                anchors.verticalCenter: badge.verticalCenter
                text: card.label
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
            }

            AnimatedNumber {
                id: numberText

                value: card.value
                decimals: card.decimals
                x: Theme.spacingL + 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.spacingL
                font.pixelSize: 30
                font.weight: Font.Bold
                font.letterSpacing: -0.8
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingL + 2
                anchors.baseline: numberText.baseline
                text: card.note
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption + 1
                font.weight: Font.Medium
            }
        }

        StatCard {
            id: focusScore

            glyph: Icons.gauge
            label: qsTr("Focus score")
            note: qsTr("+6 this week")
            value: 92
            order: 3
        }

        StatCard {
            id: hoursSaved

            glyph: Icons.hourglass
            label: qsTr("Hours saved")
            note: qsTr("since Monday")
            value: 14.2
            decimals: 1
            order: 4
        }

        StatCard {
            id: streak

            glyph: Icons.rocket
            label: qsTr("Launch streak")
            note: qsTr("days in a row")
            value: 8
            order: 5
        }
    }
}
