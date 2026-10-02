import QtQuick

// Animated window background: one shader pass draws the aurora, the vignette and the
// antialiased rounded window corners.
Item {
    id: background

    property real time: 0
    property real intensity: 1.0
    property real cornerRadius: 0

    // Shows a palette at once, without animation (used at startup).
    function setMood(mood) {
        spreadAnimation.stop();
        assignPalette("to", mood);
        assignPalette("from", mood);
        aurora.spread = 1;
    }

    // Spreads a new palette from "origin" (in this item's coordinates) across the window.
    // If a previous spread is still running, its current mix becomes the new start palette,
    // so rapid switching retargets smoothly instead of queuing.
    function spreadMood(mood, origin) {
        if (spreadAnimation.running) {
            foldCurrentMixIntoStart();
        } else {
            copyTargetToStart();
        }
        spreadAnimation.stop();
        assignPalette("to", mood);
        aurora.origin = Qt.point(origin.x / Math.max(1, width), origin.y / Math.max(1, height));
        aurora.uniformBlend = Motion.reducedMotion ? 1 : 0;
        aurora.spread = 0;
        spreadAnimation.start();
    }

    function assignPalette(prefix, mood) {
        for (let i = 0; i < 4; ++i)
            aurora[prefix + "Color" + i] = mood.blobs[i];
        aurora[prefix + "Base"] = mood.base;
    }

    function copyTargetToStart() {
        for (let i = 0; i < 4; ++i)
            aurora["fromColor" + i] = aurora["toColor" + i];
        aurora.fromBase = aurora.toBase;
    }

    function foldCurrentMixIntoStart() {
        const amount = aurora.spread;
        for (let i = 0; i < 4; ++i)
            aurora["fromColor" + i] = Theme.mix(aurora["fromColor" + i], aurora["toColor" + i], amount);
        aurora.fromBase = Theme.mix(aurora.fromBase, aurora.toBase, amount);
    }

    ShaderEffect {
        id: aurora

        anchors.fill: parent

        property real time: background.time
        property real cornerRadius: background.cornerRadius
        property real devicePixelRatio: Screen.devicePixelRatio
        property size itemSize: Qt.size(width, height)
        property real spread: 1
        property real uniformBlend: 0
        property real intensity: background.intensity
        property point origin: Qt.point(0, 0)
        property color fromColor0
        property color fromColor1
        property color fromColor2
        property color fromColor3
        property color fromBase
        property color toColor0
        property color toColor1
        property color toColor2
        property color toColor3
        property color toBase

        fragmentShader: "qrc:/shaders/aurora.frag.qsb"
    }

    NumberAnimation {
        id: spreadAnimation

        target: aurora
        property: "spread"
        to: 1
        duration: Motion.moodSpread
        easing.type: Easing.InOutSine
    }
}
