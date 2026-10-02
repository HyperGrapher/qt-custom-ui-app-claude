find_package(Qt6 REQUIRED COMPONENTS Test)

# The tests compile the C++ classes directly; they need Qt Qml only for the QML
# registration macros in the headers.
function(lumina_add_test name)
    qt_add_executable(${name} ${name}.cpp ${ARGN})
    target_include_directories(${name} PRIVATE ${PROJECT_SOURCE_DIR}/src)
    target_link_libraries(${name} PRIVATE Qt6::Core Qt6::Qml Qt6::Test)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

lumina_add_test(tst_tasksimulator ${PROJECT_SOURCE_DIR}/src/TaskSimulator.cpp)
lumina_add_test(tst_collectionmodel ${PROJECT_SOURCE_DIR}/src/CollectionModel.cpp)
lumina_add_test(tst_appsettings ${PROJECT_SOURCE_DIR}/src/AppSettings.cpp)
