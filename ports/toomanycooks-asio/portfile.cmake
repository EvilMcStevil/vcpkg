vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tzcnt/tmc-asio
    REF v${VERSION}
    SHA512 be3466c4e2cf1d5241bb9dfb5a1c6a6d82627d3d6f66150a4c9d8cd95fa129587f6a381b877bb2d96d1e9474e918652445ee95789783e744b87eedb08ef3628d
    HEAD_REF main
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        #-DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "toomanycooks-asio")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
