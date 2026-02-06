cmake_minimum_required(VERSION 3.16)
INCLUDE(GNUInstallDirs)
project(tmc)

# set(CMAKE_MODULE_PATH
#     ${tmc_recommended_SOURCE_DIR}/cmake
#     ${CMAKE_MODULE_PATH})

# set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 20)

# include(cmake/CPM.cmake)

# CPMAddPackage(
#     NAME TooManyCooks
#     GIT_REPOSITORY https://github.com/tzcnt/TooManyCooks.git
#     GIT_TAG v1.3.0
#     DOWNLOAD_ONLY)

# CPMAddPackage(
#     NAME tmc_asio
#     GIT_REPOSITORY https://github.com/tzcnt/tmc-asio.git
#     GIT_TAG v1.3.0
#     DOWNLOAD_ONLY)

# include_directories(
#     ${TooManyCooks_SOURCE_DIR}/include
#     ${tmc_asio_SOURCE_DIR}/include
# )

##### TMC HWLOC support #####

message(STATUS "running find_package(libhwloc)...")
find_library(LIBHWLOC_LIBRARY NAMES hwloc)
find_path(LIBHWLOC_INCLUDE_DIR NAMES hwloc.h)
message(STATUS " found library ${LIBHWLOC_LIBRARY}")
message(STATUS " found include ${LIBHWLOC_INCLUDE_DIR}/hwloc.h")
message(STATUS " hwloc integration is enabled")
add_compile_definitions(TMC_USE_HWLOC)
link_libraries(${LIBHWLOC_LIBRARY})
# mark hwloc headers as SYSTEM to ignore warnings




##### High-performance allocators #####

# Since each new coroutine requires an allocation,
# they are sensitive to allocator performance.
# Any of tcmalloc, mimalloc, or jemalloc provide
# greatly superior performance to the default glibc malloc.
# Try to find any of these 3 before falling back to default.

find_package(mimalloc CONFIG REQUIRED)




##### TMC build-time options #####

add_library(tmc STATIC
    tmc_build.cpp)



target_include_directories(tmc SYSTEM PUBLIC ${LIBHWLOC_INCLUDE_DIR})
target_include_directories(tmc PRIVATE include)
target_link_libraries(tmc PUBLIC mimalloc ${LIBHWLOC_LIBRARY})

# Add header files for IDE support
target_sources(tmc
    PUBLIC
    FILE_SET HEADERS
    BASE_DIRS include/tmc
    FILES
    include/tmc/detail
    include/tmc/detail/atomic_bitmap.hpp
    include/tmc/detail/auto_reset_event.ipp
    include/tmc/detail/awaitable_customizer.hpp
    include/tmc/detail/barrier.ipp
    include/tmc/detail/bit_manip.hpp
    include/tmc/detail/bitmap_object_pool.hpp
    include/tmc/detail/compat.hpp
    include/tmc/detail/concepts_awaitable.hpp
    include/tmc/detail/concepts_work_item.hpp
    include/tmc/detail/container_cpu_quota.hpp
    include/tmc/detail/container_cpu_quota.ipp
    include/tmc/detail/coro_functor.hpp
    include/tmc/detail/ex_braid.ipp
    include/tmc/detail/ex_cpu_st.ipp
    include/tmc/detail/ex_cpu.ipp
    include/tmc/detail/ex_manual_st.ipp
    include/tmc/detail/hwloc_forward_defs.hpp
    include/tmc/detail/hwloc_forward_defs.ipp
    include/tmc/detail/hwloc_unique_bitmap.hpp
    include/tmc/detail/hwloc_unique_bitmap.ipp
    include/tmc/detail/init_params.hpp
    include/tmc/detail/init_params.ipp
    include/tmc/detail/manual_reset_event.ipp
    include/tmc/detail/matrix.hpp
    include/tmc/detail/matrix.ipp
    include/tmc/detail/mixins.hpp
    include/tmc/detail/mutex.ipp
    include/tmc/detail/qu_inbox.hpp
    include/tmc/detail/qu_lockfree.hpp
    include/tmc/detail/qu_mpsc.hpp
    include/tmc/detail/result_each.hpp
    include/tmc/detail/result_each.ipp
    include/tmc/detail/semaphore.ipp
    include/tmc/detail/task_unsafe.hpp
    include/tmc/detail/task_wrapper.hpp
    include/tmc/detail/thread_layout.hpp
    include/tmc/detail/thread_layout.ipp
    include/tmc/detail/thread_locals.hpp
    include/tmc/detail/tiny_lock.hpp
    include/tmc/detail/tiny_opt.hpp
    include/tmc/detail/tiny_vec.hpp
    include/tmc/detail/topology.ipp
    include/tmc/detail/waiter_list.hpp
    include/tmc/detail/waiter_list.ipp
    include/tmc/all_headers.hpp
    include/tmc/atomic_condvar.hpp
    include/tmc/auto_reset_event.hpp
    include/tmc/aw_resume_on.hpp
    include/tmc/aw_yield.hpp
    include/tmc/barrier.hpp
    include/tmc/channel.hpp
    include/tmc/current.hpp
    include/tmc/ex_any.hpp
    include/tmc/ex_braid.hpp
    include/tmc/ex_cpu_st.hpp
    include/tmc/ex_cpu.hpp
    include/tmc/ex_manual_st.hpp
    include/tmc/external.hpp
    include/tmc/fork_group.hpp
    include/tmc/latch.hpp
    include/tmc/manual_reset_event.hpp
    include/tmc/mutex.hpp
    include/tmc/semaphore.hpp
    include/tmc/spawn_func.hpp
    include/tmc/spawn_group.hpp
    include/tmc/spawn_many.hpp
    include/tmc/spawn_tuple.hpp
    include/tmc/spawn.hpp
    include/tmc/sync.hpp
    include/tmc/task.hpp
    include/tmc/topology.hpp
    include/tmc/traits.hpp
    include/tmc/utils.hpp
    include/tmc/version.hpp
    include/tmc/work_item.hpp
)

#install(FILES ${tmc} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/tmc)


INSTALL(TARGETS tmc
    EXPORT unofficial-tmc-config-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/tmc )

INSTALL(EXPORT unofficial-tmc-config-targets NAMESPACE unofficial::tmc::
    FILE unofficial-tmc-config-targets.cmake
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/unofficial-tmc) # share/tmc

include(CMakePackageConfigHelpers)
configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in "${CMAKE_CURRENT_BINARY_DIR}/unofficial-tmc-config.cmake" INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/unofficial-tmc)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-tmc-config.cmake DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/unofficial-tmc)
