cmake_minimum_required(VERSION 3.16)

project(sonegx-video-player VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
link_directories("/usr/local/lib")
find_package(Qt6 6.4 COMPONENTS Quick  Core Concurrent REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(MPV REQUIRED mpv)
qt_add_resources( QMLRC qml.qrc
)
qt_add_resources(IMAGESRC images.qrc
)
qt_add_executable(sonegx-video-player
    main.cpp
    jsonfile.cpp
    jsonfile.h
    aes.cpp
    aes.h
     ${QMLRC}
     ${IMAGESRC}
)

qt_add_qml_module(sonegx-video-player
    URI Dapp
    VERSION 1.0
    SOURCES QMpv/qmpv.cpp QMpv/qmpv.h QMpv/qthelper.hpp

)

set_target_properties(sonegx-video-player PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(sonegx-video-player
    PRIVATE QtAES  Qt6::Quick Qt6::Concurrent mpv)

install(TARGETS sonegx-video-player
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
