import QtQuick

// Text that counts toward its value instead of jumping.
Text {
    id: label

    property real value: 0
    property int decimals: 0
    property string suffix: ""
    property real shownValue: 0

    text: shownValue.toFixed(decimals) + suffix
    color: Theme.textPrimary
    font.family: Theme.fontFamily

    // Counts up from zero, used when a page reveals its numbers.
    function replay() {
        countAnimation.stop();
        shownValue = 0;
        countAnimation.to = value;
        countAnimation.start();
    }

    onValueChanged: {
        countAnimation.stop();
        countAnimation.to = value;
        countAnimation.start();
    }
    Component.onCompleted: shownValue = value

    NumberAnimation {
        id: countAnimation

        target: label
        property: "shownValue"
        duration: Motion.reducedMotion ? 0 : 900
        easing.type: Easing.OutCubic
    }
}
