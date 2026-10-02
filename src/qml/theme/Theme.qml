pragma Singleton
import QtQuick

// Visual design tokens: typography, spacing, radii, colors and the animated accent of the
// current section. Change values here to restyle the whole app.
QtObject {
    id: theme

    // Typography
    readonly property string fontFamily: "Inter"
    readonly property string iconFontFamily: "Phosphor"
    readonly property string iconFillFontFamily: "Phosphor-Fill"
    readonly property int fontDisplay: 32
    readonly property int fontTitle: 22
    readonly property int fontHeading: 15
    readonly property int fontBody: 13
    readonly property int fontCaption: 11

    // Spacing scale
    readonly property int spacingXs: 4
    readonly property int spacingS: 8
    readonly property int spacingM: 12
    readonly property int spacingL: 16
    readonly property int spacingXl: 24
    readonly property int spacingXxl: 32

    // Corner radii
    readonly property int radiusWindow: 14
    readonly property int radiusPanel: 18
    readonly property int radiusCard: 16
    readonly property int radiusControl: 10
    readonly property int radiusSmall: 8

    // Window shell
    readonly property int windowShadowMargin: 18
    readonly property int titleBarHeight: 44
    readonly property int sidebarWidth: 236
    readonly property int sidebarInset: 10
    readonly property int resizeGrip: 6

    // Text
    readonly property color textPrimary: "#F7F5FF"
    readonly property color textSecondary: Qt.rgba(1, 1, 1, 0.68)
    readonly property color textMuted: Qt.rgba(1, 1, 1, 0.46)

    // Glass surfaces (white at low opacity over the aurora)
    readonly property color glassFill: Qt.rgba(1, 1, 1, 0.065)
    readonly property color glassFillHover: Qt.rgba(1, 1, 1, 0.11)
    readonly property color glassFillPressed: Qt.rgba(1, 1, 1, 0.15)
    readonly property color glassStroke: Qt.rgba(1, 1, 1, 0.12)
    readonly property color glassStrokeStrong: Qt.rgba(1, 1, 1, 0.22)
    readonly property color glassTint: Qt.rgba(0.02, 0.0, 0.06, 0.28)
    readonly property color shadow: Qt.rgba(0.0, 0.0, 0.03, 0.42)

    // Status colors
    readonly property color danger: "#F0505A"
    readonly property color success: "#3DD68C"
    readonly property color warning: "#FFB547"

    // Background
    // Ambient motion is slow enough to update at 30 Hz; it looks as smooth as 60 Hz and
    // renders half the frames when nothing else moves.
    readonly property int ambientFrameRate: 30
    readonly property var ambientSpeeds: [0.5, 1.0, 1.8]

    // Pointer-driven light play on glass cards (Preferences > Glass highlights).
    property bool glassHighlights: true

    // Current section mood. Controls bind to accent/accentSecondary, so the whole UI
    // re-tints together when the section changes.
    property int section: 0
    readonly property var mood: Palettes.moods[section]
    property color accent: mood.accent
    property color accentSecondary: mood.accentSecondary

    Behavior on accent {
        ColorAnimation {
            duration: Motion.accentShift
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on accentSecondary {
        ColorAnimation {
            duration: Motion.accentShift
            easing.type: Easing.InOutQuad
        }
    }

    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    function mix(first, second, amount) {
        return Qt.rgba(first.r + (second.r - first.r) * amount,
                       first.g + (second.g - first.g) * amount,
                       first.b + (second.b - first.b) * amount,
                       first.a + (second.a - first.a) * amount);
    }
}
