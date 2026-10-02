import QtQuick

// The single time source for all ambient (decorative, endless) animation. Everything
// ambient reads "time" from here, so pausing this one object stops all of it, and when
// nothing else animates Qt Quick renders no frames at all.
Item {
    id: clock

    property bool running: false
    property real speed: 1.0
    // Updates per second. Ambient motion is slow, so 30 Hz looks as smooth as vsync while
    // rendering half as many frames when nothing else moves. 0 = every rendered frame.
    property int frameRate: Theme.ambientFrameRate
    // A start offset avoids the symmetric look all sine paths have at t = 0.
    property real time: 42.0

    Timer {
        interval: Math.round(1000 / Math.max(1, clock.frameRate))
        repeat: true
        running: clock.running && clock.frameRate > 0
        onTriggered: clock.time += interval / 1000 * clock.speed
    }

    FrameAnimation {
        running: clock.running && clock.frameRate === 0
        onTriggered: clock.time += frameTime * clock.speed
    }
}
