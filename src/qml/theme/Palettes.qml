pragma Singleton
import QtQuick

// One color mood per section. "blobs" feed the aurora shader, "base" is the darkest
// background color, "accent" and "accentSecondary" tint every control while the section
// is active. Text is always light, so keep bases dark.
QtObject {
    readonly property var moods: [
        {
            name: "Nebula",
            blobs: ["#6A3DF0", "#C13CFF", "#2D1B69", "#FF6FB5"],
            base: "#120A2A",
            accent: "#B58CFF",
            accentSecondary: "#FF7DC4"
        },
        {
            name: "Lagoon",
            blobs: ["#00B3A4", "#1FD1F9", "#0B3D5C", "#7CF5C8"],
            base: "#04161F",
            accent: "#4BE3D0",
            accentSecondary: "#5CC8FF"
        },
        {
            name: "Ember",
            blobs: ["#FF7A45", "#FF3D6E", "#FFC15E", "#5A1A3A"],
            base: "#1E0A12",
            accent: "#FF9A6B",
            accentSecondary: "#FF5C8A"
        },
        {
            name: "Glacier",
            blobs: ["#5B8CFF", "#8FB8FF", "#2A3A7A", "#B7A6FF"],
            base: "#0A1024",
            accent: "#8FB0FF",
            accentSecondary: "#C3B5FF"
        }
    ]
}
