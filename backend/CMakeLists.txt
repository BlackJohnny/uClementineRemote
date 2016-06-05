find_package(Protobuf REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PROTOBUF_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(PROTO_FILE modules/UClementineRemote/pb/remotecontrolmessages.proto)
PROTOBUF_GENERATE_CPP(PROTO_SRCS PROTO_HDRS ${PROTO_FILE})

set(
    UClementineRemotebackend_SRCS
    modules/UClementineRemote/backend.cpp
    modules/UClementineRemote/clementineproxy.cpp
    modules/UClementineRemote/playlists.cpp
    modules/UClementineRemote/playlist.cpp
    modules/UClementineRemote/song.cpp
    ${PROTO_SRCS}
    ${PROTO_HDRS}
)

FILE(GLOB ProtoFiles ${PROTO_FILE})

# Make the unit test files visible on qtcreator
add_custom_target(UClementineRemotebackend_UNITTEST_QML_FILES ALL SOURCES "tests/unit/tst_mytype.qml")

# Make proto files visible on qtcreator
add_custom_target(proto SOURCES ${ProtoFiles})

add_library(UClementineRemotebackend MODULE
    ${UClementineRemotebackend_SRCS}
)

set_target_properties(UClementineRemotebackend PROPERTIES
         LIBRARY_OUTPUT_DIRECTORY UClementineRemote)

qt5_use_modules(UClementineRemotebackend Gui Qml Quick Network)

target_link_libraries(UClementineRemotebackend ${PROTOBUF_LIBRARIES})

# Copy qmldir file to build dir for running in QtCreator
add_custom_target(UClementineRemotebackend-qmldir ALL
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/modules/UClementineRemote/qmldir ${CMAKE_CURRENT_BINARY_DIR}/UClementineRemote
    DEPENDS ${QMLFILES}
)

# Install plugin file
install(TARGETS UClementineRemotebackend DESTINATION ${QT_IMPORTS_DIR}/UClementineRemote/)
install(FILES   modules/UClementineRemote/qmldir DESTINATION ${QT_IMPORTS_DIR}/UClementineRemote/)

