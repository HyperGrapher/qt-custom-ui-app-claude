cmake_minimum_required(VERSION 3.21)

project(Lumina VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(LUMINA_BUILD_TESTS "Build the unit tests" ON)

# Qt 6.8 is the supported target (CI and releases). 6.4 is the oldest version the code
# still builds with, which keeps it testable on stock Ubuntu 24.04 packages.
find_package(Qt6 6.4 REQUIRED COMPONENTS Gui Qml Quick QuickControls2 ShaderTools)

qt_standard_project_setup()

qt_add_executable(Lumina WIN32
    src/main.cpp
)

set(LUMINA_CPP_SOURCES
    src/AmbientClock.h src/AmbientClock.cpp
    src/AppSettings.h src/AppSettings.cpp
    src/CollectionModel.h src/CollectionModel.cpp
    src/FrameStats.h src/FrameStats.cpp
    src/TaskSimulator.h src/TaskSimulator.cpp
    src/WindowChrome.h src/WindowChrome.cpp
    src/PlatformWindow.h
)

if(WIN32)
    list(APPEND LUMINA_CPP_SOURCES src/PlatformWindowWin.cpp)
else()
    list(APPEND LUMINA_CPP_SOURCES src/PlatformWindowGeneric.cpp)
endif()

set(LUMINA_SINGLETONS
    src/qml/theme/Theme.qml
    src/qml/theme/Motion.qml
    src/qml/theme/Palettes.qml
    src/qml/theme/Icons.qml
)

set(LUMINA_QML_FILES
    src/qml/Main.qml
    ${LUMINA_SINGLETONS}
    src/qml/shell/ResizeBorder.qml
    src/qml/shell/TitleBar.qml
    src/qml/shell/WindowButton.qml
    src/qml/navigation/LiquidIndicator.qml
    src/qml/navigation/Sidebar.qml
    src/qml/navigation/SidebarItem.qml
    src/qml/pages/ActivityPage.qml
    src/qml/pages/CollectionsPage.qml
    src/qml/pages/OverviewPage.qml
    src/qml/pages/PageBase.qml
    src/qml/pages/PageHeader.qml
    src/qml/pages/PageHost.qml
    src/qml/pages/PreferencesPage.qml
    src/qml/controls/AnimatedNumber.qml
    src/qml/controls/GlassCard.qml
    src/qml/controls/GlassPanel.qml
    src/qml/controls/Icon.qml
    src/qml/controls/PerformanceOverlay.qml
    src/qml/controls/PrimaryButton.qml
    src/qml/controls/ProgressRing.qml
    src/qml/controls/SecondaryButton.qml
    src/qml/controls/SegmentedControl.qml
    src/qml/controls/SettingRow.qml
    src/qml/controls/StatusCard.qml
    src/qml/controls/StepTimeline.qml
    src/qml/controls/StyledSlider.qml
    src/qml/controls/ToggleSwitch.qml
    src/qml/effects/AuroraBackground.qml
    src/qml/effects/EnergyOrb.qml
    src/qml/effects/SoftShadow.qml
    src/qml/DemoTour.qml
)

set_source_files_properties(${LUMINA_SINGLETONS} PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

# The folders under src/qml only organize the sources. Aliasing every file to the module
# root keeps all types in one directory, so they see each other without extra imports.
foreach(qml_file IN LISTS LUMINA_QML_FILES)
    get_filename_component(qml_name "${qml_file}" NAME)
    set_source_files_properties("${qml_file}" PROPERTIES QT_RESOURCE_ALIAS "${qml_name}")
endforeach()

qt_add_qml_module(Lumina
    URI Lumina
    VERSION 1.0
    RESOURCE_PREFIX /qt/qml
    # Keeps the module folder from colliding with the executable of the same name.
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/Lumina
    SOURCES ${LUMINA_CPP_SOURCES}
    QML_FILES ${LUMINA_QML_FILES}
)

qt_add_shaders(Lumina "lumina_shaders"
    PREFIX "/shaders"
    BASE src/shaders
    FILES
        src/shaders/aurora.frag
        src/shaders/glass.frag
        src/shaders/orb.frag
        src/shaders/ring.frag
        src/shaders/softrect.frag
)

qt_add_resources(Lumina "lumina_fonts"
    PREFIX "/fonts"
    BASE resources/fonts
    FILES
        resources/fonts/Inter-Regular.ttf
        resources/fonts/Inter-Medium.ttf
        resources/fonts/Inter-SemiBold.ttf
        resources/fonts/Inter-Bold.ttf
        resources/fonts/Phosphor.ttf
        resources/fonts/Phosphor-Fill.ttf
)

target_include_directories(Lumina PRIVATE src)
target_compile_definitions(Lumina PRIVATE PROJECT_VERSION_STRING="${PROJECT_VERSION}")

target_link_libraries(Lumina
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)

if(WIN32)
    target_link_libraries(Lumina PRIVATE dwmapi)
endif()

if(LUMINA_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
