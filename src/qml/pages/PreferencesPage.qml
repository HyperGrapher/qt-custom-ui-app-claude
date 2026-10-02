import QtQuick
import Lumina

// Settings page. Every change applies live and is saved by AppSettings.
PageBase {
    id: page

    required property AppSettings settings

    PageHeader {
        id: header

        width: parent.width
        title: qsTr("Preferences")
        subtitle: qsTr("Tune motion and appearance. Changes apply immediately and are saved.")
        opacity: page.reveal(0)
        transform: Translate { y: page.revealShift(0) }
    }

    Flickable {
        id: flick

        anchors.top: header.bottom
        anchors.topMargin: Theme.spacingL
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentHeight: groups.implicitHeight + 12
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: groups

            width: flick.width
            spacing: Theme.spacingL

            component Group: GlassPanel {
                id: group

                property string title
                property int order
                default property alias rows: rowColumn.data

                width: groups.width
                height: rowColumn.implicitHeight + 52
                radius: Theme.radiusCard
                opacity: page.reveal(order)
                transform: Translate { y: page.revealShift(group.order) }

                Text {
                    x: Theme.spacingXl
                    y: Theme.spacingL
                    text: group.title
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.4
                }

                Column {
                    id: rowColumn

                    x: Theme.spacingXl
                    y: 36
                    width: parent.width - 2 * Theme.spacingXl
                }
            }

            Group {
                title: qsTr("MOTION")
                order: 1

                SettingRow {
                    width: parent.width
                    glyph: Icons.moon
                    title: qsTr("Reduced motion")
                    description: qsTr("Static background, quick cross-fades, no stagger or tilt.")

                    ToggleSwitch {
                        checked: page.settings.reducedMotion
                        onToggled: page.settings.reducedMotion = checked
                    }
                }

                SettingRow {
                    width: parent.width
                    glyph: Icons.drop
                    title: qsTr("Ambient background")
                    description: qsTr("Slowly flowing color blobs behind the interface.")

                    ToggleSwitch {
                        checked: page.settings.ambientEnabled
                        onToggled: page.settings.ambientEnabled = checked
                    }
                }

                SettingRow {
                    width: parent.width
                    glyph: Icons.waveform
                    title: qsTr("Ambient speed")
                    description: qsTr("How fast the background drifts.")
                    enabled: page.settings.ambientEnabled && !page.settings.reducedMotion
                    opacity: enabled ? 1 : 0.45

                    Behavior on opacity { NumberAnimation { duration: Motion.normal } }

                    SegmentedControl {
                        options: [qsTr("Calm"), qsTr("Normal"), qsTr("Lively")]
                        currentIndex: page.settings.ambientSpeed
                        onActivated: index => page.settings.ambientSpeed = index
                    }
                }
            }

            Group {
                title: qsTr("APPEARANCE")
                order: 2

                SettingRow {
                    width: parent.width
                    glyph: Icons.palette
                    title: qsTr("Background intensity")
                    description: qsTr("Strength of the blob colors over the base color.")

                    StyledSlider {
                        from: 0.2
                        to: 1.0
                        value: page.settings.backgroundIntensity
                        onMoved: page.settings.backgroundIntensity = value
                    }
                }

                SettingRow {
                    width: parent.width
                    glyph: Icons.sparkle
                    title: qsTr("Glass highlights")
                    description: qsTr("Cards tilt toward the pointer and catch its light.")

                    ToggleSwitch {
                        checked: page.settings.glassHighlights
                        onToggled: page.settings.glassHighlights = checked
                    }
                }
            }

            Group {
                title: qsTr("DIAGNOSTICS")
                order: 3

                SettingRow {
                    width: parent.width
                    glyph: Icons.gauge
                    title: qsTr("Performance overlay")
                    description: qsTr("Frame rate, frame times and a frame counter. A still counter means no rendering.")

                    ToggleSwitch {
                        checked: page.settings.performanceOverlay
                        onToggled: page.settings.performanceOverlay = checked
                    }
                }

                SettingRow {
                    width: parent.width
                    glyph: Icons.reset
                    title: qsTr("Restore defaults")
                    description: qsTr("Resets every preference on this page.")

                    Row {
                        spacing: Theme.spacingS

                        PrimaryButton {
                            text: qsTr("Export")
                            enabled: false
                            implicitWidth: 100
                        }

                        SecondaryButton {
                            text: qsTr("Reset")
                            onClicked: page.settings.resetToDefaults()
                        }
                    }
                }
            }
        }
    }
}
