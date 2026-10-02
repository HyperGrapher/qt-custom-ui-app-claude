pragma Singleton
import QtQuick

// Glyphs of the bundled Phosphor icon font (MIT license). Using a font keeps icons sharp at
// every display scale, and recoloring is a plain color change.
QtObject {
    id: icons

    readonly property string house: "\ue2c2"
    readonly property string squaresFour: "\ue464"
    readonly property string pulse: "\ue000"
    readonly property string gearSix: "\ue272"
    readonly property string sparkle: "\ue6a2"
    readonly property string minus: "\ue32a"
    readonly property string square: "\ue45e"
    readonly property string copy: "\ue1ca"
    readonly property string close: "\ue4f6"
    readonly property string play: "\ue3d0"
    readonly property string pause: "\ue39e"
    readonly property string reset: "\ue038"
    readonly property string check: "\ue182"
    readonly property string checkCircle: "\ue184"
    readonly property string warning: "\ue4e0"
    readonly property string warningCircle: "\ue4e2"
    readonly property string lightning: "\ue2de"
    readonly property string cloud: "\ue1aa"
    readonly property string folder: "\ue24a"
    readonly property string image: "\ue2ca"
    readonly property string musicNotes: "\ue340"
    readonly property string filmStrip: "\ue792"
    readonly property string code: "\ue1bc"
    readonly property string bookOpen: "\ue0e6"
    readonly property string shuffle: "\ue422"
    readonly property string moon: "\ue330"
    readonly property string gauge: "\ue628"
    readonly property string drop: "\ue210"
    readonly property string palette: "\ue6c8"
    readonly property string cpu: "\ue610"
    readonly property string hardDrives: "\ue2a0"
    readonly property string shieldCheck: "\ue40c"
    readonly property string rocket: "\ue3fc"
    readonly property string star: "\ue46a"
    readonly property string waveform: "\ue802"
    readonly property string planet: "\ue652"
    readonly property string atom: "\ue5e4"
    readonly property string leaf: "\ue2da"
    readonly property string compass: "\ue1c8"
    readonly property string circleNotch: "\ueb44"
    readonly property string hourglass: "\ue2b8"
    readonly property string sliders: "\ue434"
    readonly property string eye: "\ue220"
    readonly property string cube: "\ue1da"
    readonly property string flask: "\ue79e"

    function named(name) {
        const glyph = icons[name];
        return typeof glyph === "string" ? glyph : cube;
    }
}
