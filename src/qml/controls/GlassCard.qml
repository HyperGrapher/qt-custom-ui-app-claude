import QtQuick

// Interactive glass card. On hover it lifts, tilts a few degrees toward the pointer, and a
// specular spot follows the pointer across the surface.
Item {
    id: card

    default property alias content: contentArea.data
    property bool interactive: true
    property real radius: Theme.radiusCard
    readonly property bool hovered: hoverHandler.hovered
    readonly property bool lightPlay: Theme.glassHighlights && !Motion.reducedMotion
    readonly property real maxTilt: 4

    property real hover: interactive && hovered ? 1 : 0
    property real tiltX: 0
    property real tiltY: 0

    signal clicked

    Behavior on hover { NumberAnimation { duration: Motion.normal; easing.type: Easing.OutCubic } }
    Behavior on tiltX { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
    Behavior on tiltY { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

    scale: 1 + 0.015 * hover
    transform: [
        Rotation {
            origin.x: card.width / 2
            origin.y: card.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: card.tiltX
        },
        Rotation {
            origin.x: card.width / 2
            origin.y: card.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: card.tiltY
        }
    ]

    function updateTilt(position) {
        if (!interactive || !lightPlay) {
            tiltX = 0;
            tiltY = 0;
            return;
        }
        const nx = position.x / Math.max(1, width) - 0.5;
        const ny = position.y / Math.max(1, height) - 0.5;
        tiltY = nx * 2 * maxTilt;
        tiltX = -ny * 2 * maxTilt;
    }

    SoftShadow {
        anchors.fill: surface
        anchors.margins: -blur
        anchors.topMargin: -blur + 4 + 8 * card.hover
        anchors.bottomMargin: -blur - 4 - 8 * card.hover
        radius: card.radius
        blur: 18 + 10 * card.hover
        color: Qt.rgba(0, 0, 0.03, 0.30 + 0.14 * card.hover)
    }

    ShaderEffect {
        id: surface

        anchors.fill: parent

        property real radius: card.radius
        property real hover: card.hover
        property real highlightAmount: card.lightPlay ? 1 : 0
        property real devicePixelRatio: Screen.devicePixelRatio
        property size itemSize: Qt.size(width, height)
        property point pointer
        property color fillColor: Qt.rgba(1, 1, 1, 0.07)
        property color tintColor: Theme.accent

        fragmentShader: "qrc:/shaders/glass.frag.qsb"
    }

    Item {
        id: contentArea

        anchors.fill: parent
    }

    HoverHandler {
        id: hoverHandler

        enabled: card.interactive
        onPointChanged: {
            surface.pointer = point.position;
            card.updateTilt(point.position);
        }
        onHoveredChanged: {
            if (!hovered)
                card.updateTilt(Qt.point(card.width / 2, card.height / 2));
        }
    }

    TapHandler {
        enabled: card.interactive
        onTapped: card.clicked()
    }
}
