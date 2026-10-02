pragma Singleton
import QtQuick

// All durations (ms), distances (px) and curves used by animations. In reduced-motion mode
// the same names resolve to short fades or zero, so components need no special cases.
QtObject {
    property bool reducedMotion: false

    // Small state changes: hover, press, focus.
    readonly property int fast: reducedMotion ? 0 : 120
    readonly property int normal: reducedMotion ? 90 : 220
    readonly property int slow: reducedMotion ? 120 : 420

    // Page transitions.
    readonly property int pageOut: reducedMotion ? 120 : 160
    readonly property int pageIn: reducedMotion ? 120 : 320
    readonly property int pageInDelay: reducedMotion ? 0 : 60
    readonly property real pageEnterShift: reducedMotion ? 0 : 18
    readonly property real pageExitShift: reducedMotion ? 0 : 12

    // Staggered entrance of page elements.
    readonly property int staggerStep: reducedMotion ? 0 : 30
    readonly property int staggerMaxSteps: 8
    readonly property int revealDuration: reducedMotion ? 0 : 300
    readonly property real revealRise: reducedMotion ? 0 : 10

    // Section mood and sidebar indicator.
    readonly property int moodSpread: reducedMotion ? 240 : 950
    readonly property int accentShift: reducedMotion ? 200 : 340
    readonly property int indicatorLead: reducedMotion ? 120 : 190
    readonly property int indicatorTrail: reducedMotion ? 120 : 330
    readonly property real indicatorOvershoot: reducedMotion ? 0 : 0.9

    // Window intro.
    readonly property int windowIntro: reducedMotion ? 0 : 520

    readonly property int easeOut: Easing.OutCubic
    readonly property int easeIn: Easing.InCubic
    readonly property int easeInOut: Easing.InOutCubic
}
