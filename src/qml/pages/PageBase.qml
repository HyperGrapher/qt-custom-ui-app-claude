import QtQuick

// Base for every page. Provides the staggered entrance: one clock (revealTime) runs when the
// page enters, and each element asks reveal(order) for its own eased 0..1 progress. One
// animation drives all elements, and nothing queues on rapid switching.
Item {
    id: page

    property bool isCurrent: false
    property real revealTime: 1e6

    signal entered

    readonly property int revealEnd: Motion.pageInDelay
                                     + Motion.staggerMaxSteps * Motion.staggerStep
                                     + Motion.revealDuration

    function reveal(order) {
        const start = Motion.pageInDelay + Math.min(order, Motion.staggerMaxSteps) * Motion.staggerStep;
        const linear = Math.max(0, Math.min(1, (revealTime - start) / Math.max(1, Motion.revealDuration)));
        return 1 - Math.pow(1 - linear, 3);
    }

    function revealShift(order) {
        return (1 - reveal(order)) * Motion.revealRise;
    }

    function playReveal() {
        revealAnimation.stop();
        revealTime = 0;
        revealAnimation.start();
        entered();
    }

    NumberAnimation {
        id: revealAnimation

        target: page
        property: "revealTime"
        to: page.revealEnd
        duration: page.revealEnd
    }
}
