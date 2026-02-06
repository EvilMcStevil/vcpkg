cmake_minimum_required(VERSION 3.16)
include(GNUInstallDirs)
project(tmc-asio)

set(CMAKE_CXX_STANDARD 20)


##### TMC build-time options #####

add_library(tmc-asio INTERFACE)
find_package(unofficial-tmc CONFIG REQUIRED)
find_package(Boost CONFIG REQUIRED COMPONENTS asio)

target_compile_definitions(tmc-asio INTERFACE TMC_USE_BOOST_ASIO)



target_link_libraries(tmc-asio INTERFACE unofficial::tmc Boost::asio)

# Add header files for IDE support
target_sources(tmc-asio
    INTERFACE
    FILE_SET HEADERS
    BASE_DIRS include/tmc
    FILES
    include/tmc/asio/aw_asio.hpp
    include/tmc/asio/ex_asio.hpp
)


install(TARGETS tmc-asio
    EXPORT unofficial-tmc-asio-config-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/tmc )

install(EXPORT unofficial-tmc-asio-config-targets NAMESPACE unofficial::tmc::
    FILE unofficial-tmc-asio-config-targets.cmake
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/unofficial-tmc-asio) # share/tmc

include(CMakePackageConfigHelpers)
configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in "${CMAKE_CURRENT_BINARY_DIR}/unofficial-tmc-asio-config.cmake" INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/unofficial-tmc-asio)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-tmc-asio-config.cmake DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/unofficial-tmc-asio)