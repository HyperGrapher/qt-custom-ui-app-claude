import QtQuick

// Selection pill behind the active sidebar item. Its two edges animate separately: the edge
// in the direction of travel leads, the other trails with a small overshoot, so the pill
// stretches like a drop of liquid and then settles. A new target simply retargets both
// edges from where they are.
Item {
    id: indicator

    property real topEdge: 0
    property real bottomEdge: 0
    property bool movingDown: true

    function moveTo(top, bottom) {
        movingDown = top > topEdge;
        topEdge = top;
        bottomEdge = bottom;
    }

    function jumpTo(top, bottom) {
        topBehavior.enabled = false;
        bottomBehavior.enabled = false;
        topEdge = top;
        bottomEdge = bottom;
        topBehavior.enabled = true;
        bottomBehavior.enabled = true;
    }

    y: topEdge
    height: Math.max(0, bottomEdge - topEdge)

    Behavior on topEdge {
        id: topBehavior

        NumberAnimation {
            duration: indicator.movingDown ? Motion.indicatorTrail : Motion.indicatorLead
            easing.type: indicator.movingDown ? Easing.OutBack : Easing.OutCubic
            easing.overshoot: Motion.indicatorOvershoot
        }
    }

    Behavior on bottomEdge {
        id: bottomBehavior

        NumberAnimation {
            duration: indicator.movingDown ? Motion.indicatorLead : Motion.indicatorTrail
            easing.type: indicator.movingDown ? Easing.OutCubic : Easing.OutBack
            easing.overshoot: Motion.indicatorOvershoot
        }
    }

    SoftShadow {
        anchors.fill: pill
        anchors.margins: -blur
        radius: pill.radius
        blur: 20
        color: Theme.withAlpha(Theme.accent, 0.38)
    }

    Rectangle {
        id: pill

        anchors.fill: parent
        radius: 12
        border.width: 1
        border.color: Theme.withAlpha(Theme.accent, 0.5)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Theme.withAlpha(Theme.accent, 0.32) }
            GradientStop { position: 1; color: Theme.withAlpha(Theme.accentSecondary, 0.12) }
        }
    }

    Rectangle {
        width: 3
        height: Math.min(parent.height - 18, 22)
        radius: 1.5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.accent
    }
}
