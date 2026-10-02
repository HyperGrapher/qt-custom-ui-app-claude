cmake_minimum_required(VERSION 3.16)

project(QtCustomDemo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add QuickControls2 here
find_package(Qt6 6.3 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup()

qt_add_executable(appQtQuickDemo WIN32
    main.cpp
)

qt_add_qml_module(appQtQuickDemo
    URI QtCustomDemo
    VERSION 1.0
    QML_FILES Main.qml
)

target_link_libraries(appQtQuickDemo
    PRIVATE 
        Qt6::Quick
        Qt6::QuickControls2
)
