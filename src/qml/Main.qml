import QtQuick
import Lumina

// Root window: wires the window shell, ambient background, sidebar and pages together.
Window {
    id: root

    required property WindowChrome chrome
    required property AppSettings appSettings
    required property TaskSimulator taskSimulator
    required property CollectionModel collectionModel
    required property bool reducedMotionForced
    required property string tourDirectory

    readonly property bool maximized: visibility === Window.Maximized || visibility === Window.FullScreen
    readonly property bool shown: visible && visibility !== Window.Minimized && visibility !== Window.Hidden
    // All decorative endless motion depends on this one flag.
    readonly property bool ambientActive: shown && appSettings.ambientEnabled && !Motion.reducedMotion
    readonly property real frameMargin: chrome.translucent && !maximized ? Theme.windowShadowMargin : 0
    readonly property real cornerRadius: chrome.translucent && !maximized ? Theme.radiusWindow : 0

    readonly property var sections: [
        { title: qsTr("Overview"), glyph: Icons.house },
        { title: qsTr("Collections"), glyph: Icons.squaresFour },
        { title: qsTr("Activity"), glyph: Icons.pulse },
        { title: qsTr("Preferences"), glyph: Icons.gearSix }
    ]

    // Switches section: moves the sidebar pill, spreads the new mood from the clicked icon,
    // re-tints the accent and transitions the page. Safe to call at any rate.
    function navigate(index, originInSidebar) {
        if (index === Theme.section)
            return;
        const origin = sidebar.mapToItem(background, originInSidebar.x, originInSidebar.y);
        background.spreadMood(Palettes.moods[index], origin);
        Theme.section = index;
        pageHost.show(index);
        appSettings.lastSection = index;
    }

    width: 1180
    height: 760
    minimumWidth: 940
    minimumHeight: 620
    visible: true
    title: "Lumina"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowMinMaxButtonsHint
    color: chrome.translucent ? "transparent" : Palettes.moods[Theme.section].base

    Binding {
        target: Motion
        property: "reducedMotion"
        value: root.reducedMotionForced || root.appSettings.reducedMotion
    }

    Binding {
        target: Theme
        property: "glassHighlights"
        value: root.appSettings.glassHighlights
    }

    Component.onCompleted: {
        const section = appSettings.lastSection;
        Theme.section = section;
        background.setMood(Palettes.moods[section]);
        pageHost.showImmediately(section);
        if (!Motion.reducedMotion)
            introAnimation.start();
    }

    AmbientClock {
        id: ambientClock

        running: root.ambientActive
        speed: Theme.ambientSpeeds[root.appSettings.ambientSpeed]
        frameRate: Theme.ambientFrameRate
    }

    SoftShadow {
        anchors.fill: surface
        anchors.margins: -blur
        anchors.topMargin: -blur + 3
        anchors.bottomMargin: -blur - 5
        visible: root.frameMargin > 0
        radius: root.cornerRadius
        blur: root.frameMargin
        color: Qt.rgba(0, 0, 0, 0.5)
    }

    Item {
        id: surface

        anchors.fill: parent
        anchors.margins: root.frameMargin

        AuroraBackground {
            id: background

            anchors.fill: parent
            time: ambientClock.time
            intensity: root.appSettings.backgroundIntensity
            cornerRadius: root.cornerRadius
        }

        TitleBar {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            window: root
        }

        Sidebar {
            id: sidebar

            x: Theme.sidebarInset
            y: Theme.sidebarInset
            width: Theme.sidebarWidth
            height: parent.height - 2 * Theme.sidebarInset
            sections: root.sections
            currentIndex: Theme.section
            reducedMotion: Motion.reducedMotion
            focus: true
            onActivated: (index, origin) => root.navigate(index, origin)
            onReducedMotionToggled: enabled => root.appSettings.reducedMotion = enabled
        }

        PageHost {
            id: pageHost

            anchors.left: sidebar.right
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.top: parent.top
            anchors.topMargin: Theme.titleBarHeight + 14
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 26

            pages: [
                Component {
                    OverviewPage {
                        ambientTime: ambientClock.time
                        onRunDemoRequested: root.taskSimulator.start()
                    }
                },
                Component {
                    CollectionsPage {
                        collection: root.collectionModel
                    }
                },
                Component {
                    ActivityPage {
                        simulator: root.taskSimulator
                        ambientActive: root.ambientActive
                    }
                },
                Component {
                    PreferencesPage {
                        settings: root.appSettings
                    }
                }
            ]
        }

        PerformanceOverlay {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.top: parent.top
            anchors.topMargin: Theme.titleBarHeight
            visible: root.appSettings.performanceOverlay
            window: root
            ambientActive: root.ambientActive
        }

        ParallelAnimation {
            id: introAnimation

            NumberAnimation { target: surface; property: "opacity"; from: 0; to: 1; duration: Motion.windowIntro; easing.type: Easing.OutCubic }
            NumberAnimation { target: surface; property: "scale"; from: 0.985; to: 1; duration: Motion.windowIntro; easing.type: Easing.OutCubic }
        }
    }

    ResizeBorder {
        anchors.fill: parent
        window: root
        outside: root.frameMargin
        visible: !root.maximized
    }

    Shortcut {
        sequences: ["Ctrl+1"]
        onActivated: sidebar.select(0)
    }
    Shortcut {
        sequences: ["Ctrl+2"]
        onActivated: sidebar.select(1)
    }
    Shortcut {
        sequences: ["Ctrl+3"]
        onActivated: sidebar.select(2)
    }
    Shortcut {
        sequences: ["Ctrl+4"]
        onActivated: sidebar.select(3)
    }

    Loader {
        active: root.tourDirectory.length > 0
        sourceComponent: DemoTour {
            window: root
            outputDirectory: root.tourDirectory
            host: pageHost
            onNavigateRequested: index => sidebar.select(index)
        }
    }
}
