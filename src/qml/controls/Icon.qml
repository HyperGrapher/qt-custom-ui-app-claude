import QtQuick

// A glyph from the bundled icon font. Size is the glyph's pixel size.
Text {
    property string glyph: Icons.cube
    property int size: 20
    property bool filled: false

    text: glyph
    font.family: filled ? Theme.iconFillFontFamily : Theme.iconFontFamily
    font.pixelSize: size
    color: Theme.textPrimary
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.QtRendering
}
