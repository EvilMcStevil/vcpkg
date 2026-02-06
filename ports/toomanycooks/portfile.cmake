vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tzcnt/TooManyCooks
    REF v${VERSION}
    SHA512 4d2006b1348869c35105d37c3aebed218cb63fde34aa577c8ca8e402f88fd98f9185db5f8fa6abc8622b86498cab04a5dd260e9a98ac232aca871e143d5c9a68
    HEAD_REF main
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/tmc_build.cpp" DESTINATION "${SOURCE_PATH}")



vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        #-DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
# vcpkg_cmake_config_fixup(PACKAGE_NAME "toomanycooks")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
