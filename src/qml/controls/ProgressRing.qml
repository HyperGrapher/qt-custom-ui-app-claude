import QtQuick

// Circular progress with a gradient arc and a glowing tip. The value glides toward each new
// target, so coarse updates from C++ still look continuous.
Item {
    id: ring

    property real value: 0
    property real thickness: 14
    property real glow: 0
    property alias label: centerLabel.text
    property alias caption: captionLabel.text

    implicitWidth: 240
    implicitHeight: 240

    ShaderEffect {
        id: arc

        anchors.fill: parent

        property real value: ring.value
        property real thickness: ring.thickness
        property real devicePixelRatio: Screen.devicePixelRatio
        property real glow: ring.glow
        property size itemSize: Qt.size(width, height)
        property color startColor: Theme.accent
        property color endColor: Theme.accentSecondary
        property color trackColor: Qt.rgba(1, 1, 1, 0.08)

        fragmentShader: "qrc:/shaders/ring.frag.qsb"

        Behavior on value {
            NumberAnimation { duration: Motion.slow; easing.type: Easing.OutCubic }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            id: centerLabel

            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(arc.value * 100) + "%"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: ring.width * 0.17
            font.weight: Font.Bold
            font.letterSpacing: -1
        }

        Text {
            id: captionLabel

            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption + 1
            visible: text.length > 0
        }
    }
}
