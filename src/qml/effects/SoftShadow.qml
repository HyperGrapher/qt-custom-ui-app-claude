import QtQuick

// Soft shadow or glow for a rounded rectangle, drawn in one cheap shader pass.
// Anchor it to the shape with negative margins of "blur" so the falloff has room.
ShaderEffect {
    id: effect

    property real radius: Theme.radiusCard
    property real blur: 16
    property color color: Theme.shadow
    readonly property size itemSize: Qt.size(width, height)

    fragmentShader: "qrc:/shaders/softrect.frag.qsb"
}
