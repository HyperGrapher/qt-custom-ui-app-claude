import QtQuick

// Shows one page at a time with a cross-fade and a short vertical slide whose direction
// follows the sidebar (moving down the list makes content rise).
//
// Each slot has a "presence" (0..1) and an "offset". Switching restarts short animations
// from the current values, so rapid switching retargets instead of queuing. Pages are
// created on first visit and then kept, so their state survives. Only the current page is
// enabled, so a fading page never takes input.
Item {
    id: host

    property list<Component> pages
    readonly property int currentIndex: internal.currentIndex
    readonly property int direction: internal.direction

    function show(index) {
        if (index === internal.currentIndex || index < 0 || index >= pages.length)
            return;
        internal.direction = index > internal.currentIndex ? 1 : -1;
        internal.currentIndex = index;
    }

    // Starts on a page without a transition, but with its entrance stagger.
    function showImmediately(index) {
        internal.direction = 1;
        internal.currentIndex = index;
    }

    // Test/diagnostic access: presence values of all slots.
    function presences() {
        const values = [];
        for (let i = 0; i < repeater.count; ++i)
            values.push(repeater.itemAt(i).presence);
        return values;
    }

    QtObject {
        id: internal

        property int currentIndex: -1
        property int direction: 1
    }

    Repeater {
        id: repeater

        model: host.pages.length

        delegate: Item {
            id: slot

            required property int index
            readonly property bool isCurrent: index === host.currentIndex
            property bool visited: false
            property real presence: 0
            property real offset: 0
            property int enterDelay: 0

            width: host.width
            height: host.height
            visible: presence > 0.001
            enabled: isCurrent
            opacity: presence
            transform: Translate { y: slot.offset }

            onIsCurrentChanged: {
                if (isCurrent)
                    enter();
                else
                    leave();
            }

            function enter() {
                exitAnimation.stop();
                const fromHidden = presence < 0.001;
                visited = true;
                if (fromHidden) {
                    offset = Motion.pageEnterShift * host.direction;
                    if (loader.item)
                        loader.item.playReveal();
                }
                enterDelay = fromHidden ? Motion.pageInDelay : 0;
                enterAnimation.restart();
            }

            function leave() {
                enterAnimation.stop();
                exitAnimation.exitTarget = -Motion.pageExitShift * host.direction;
                exitAnimation.restart();
            }

            Loader {
                id: loader

                anchors.fill: parent
                active: slot.visited
                sourceComponent: host.pages[slot.index]
                onLoaded: item.isCurrent = Qt.binding(() => slot.isCurrent)
            }

            SequentialAnimation {
                id: enterAnimation

                PauseAnimation { duration: slot.enterDelay }
                ParallelAnimation {
                    NumberAnimation {
                        target: slot
                        property: "presence"
                        to: 1
                        duration: Motion.pageIn
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: slot
                        property: "offset"
                        to: 0
                        duration: Motion.pageIn
                        easing.type: Easing.OutCubic
                    }
                }
            }

            ParallelAnimation {
                id: exitAnimation

                property real exitTarget: 0

                NumberAnimation {
                    target: slot
                    property: "presence"
                    to: 0
                    duration: Motion.pageOut
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: slot
                    property: "offset"
                    to: exitAnimation.exitTarget
                    duration: Motion.pageOut
                    easing.type: Easing.InQuad
                }
            }
        }
    }
}
