import QtQuick

// Hero sphere of the Overview page. Its colors come from the current section mood and its
// swirl follows the shared ambient clock, so it freezes with the rest of the ambient motion.
ShaderEffect {
    id: orb

    property real time: 0
    property real pulse: 0
    property color colorA: Theme.mood.blobs[0]
    property color colorB: Theme.mood.blobs[1]
    property color colorC: Theme.mood.blobs[3]
    readonly property real pixelSize: 2 / Math.max(1, width * Screen.devicePixelRatio)

    // Plays one swell-and-settle pulse.
    function playPulse() {
        pulseAnimation.restart();
    }

    fragmentShader: "qrc:/shaders/orb.frag.qsb"

    Behavior on colorA { ColorAnimation { duration: Motion.moodSpread } }
    Behavior on colorB { ColorAnimation { duration: Motion.moodSpread } }
    Behavior on colorC { ColorAnimation { duration: Motion.moodSpread } }

    SequentialAnimation {
        id: pulseAnimation

        NumberAnimation {
            target: orb
            property: "pulse"
            to: 1
            duration: Motion.slow
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: orb
            property: "pulse"
            to: 0
            duration: Motion.slow * 2.5
            easing.type: Easing.InOutSine
        }
    }
}
