import QtQuick

// Static glass surface for grouping content (sidebar, setting groups). Interactive cards
// use GlassCard, which adds pointer-driven light.
Rectangle {
    property real tintStrength: 0

    radius: Theme.radiusPanel
    border.width: 1
    border.color: Theme.glassStroke
    gradient: Gradient {
        GradientStop {
            position: 0
            color: Qt.rgba(1, 1, 1, 0.09)
        }
        GradientStop {
            position: 1
            color: Qt.rgba(1, 1, 1, 0.04)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Theme.glassTint
        opacity: parent.tintStrength
        visible: opacity > 0
    }
}
