# This package installs Intel DNNL on Linux, macOS and Windows for x64.

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/4fb390ad-7794-4c37-9cff-f1fd54947c24/intel-onednn-2025.2.0.563_offline.exe
# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/6b523cc0-3241-4b80-bfba-ebe6c67599f6/intel-onednn-2025.2.0.562_offline.sh

set(dnnl_version 2025.2.0)
set(dnnl_short_version 2025.2)
if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  # nop
elseif(VCPKG_TARGET_IS_WINDOWS)
  set(filename intel-onednn-2025.2.0.563_offline.exe)
  set(magic_number 4fb390ad-7794-4c37-9cff-f1fd54947c24)
  set(sha 9870e645d2a5ca488f31f4c978c2a356a01dc042bf1c535a99d2175dcf87a751ce7b08ad27ad772396fbc2a632ef9c16253d694f4050472214abc0da682836cd)
  set(package_infix "win")
elseif(VCPKG_TARGET_IS_LINUX)
  set(filename intel-onednn-2025.2.0.562_offline.sh)
  set(magic_number 6b523cc0-3241-4b80-bfba-ebe6c67599f6)
  set(sha 9b073b031cd8ee9dc85978f976e0c96504b460637db05ea1eb42d8b55be2e31a6172e4b7b257fd88a550c8f0ba090e2d3b1033d474db686276ec6996ef27481e)
  set(package_infix "lin")
endif()

if(NOT sha)
  message(WARNING "${PORT} is empty for ${TARGET_TRIPLET}.")
  return()
endif()

vcpkg_download_distfile(installer_path
    URLS "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/${magic_number}/${filename}"
    FILENAME "${filename}"
    SHA512 "${sha}"
)

# Note: intel_thread and lp64 are the defaults.
set(interface "ilp64") # or ilp64; ilp == 64 bit int api
#https://www.intel.com/content/www/us/en/develop/documentation/onemkl-linux-developer-guide/top/linking-your-application-with-onemkl/linking-in-detail/linking-with-interface-libraries/using-the-ilp64-interface-vs-lp64-interface.html
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(threading "intel_thread") #sequential or intel_thread or tbb_thread or pgi_thread
else()
    set(threading "sequential")
endif()
if(threading STREQUAL "intel_thread")
    set(short_thread "iomp")
else()
    string(SUBSTRING "${threading}" "0" "3" short_thread)
endif()
#set(main_pc_file "dnnl-${VCPKG_LIBRARY_LINKAGE}-${interface}-${short_thread}.pc")

# First extraction level: packages (from offline installer)
set(extract_0_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-extract")
file(REMOVE_RECURSE "${extract_0_dir}")
file(MAKE_DIRECTORY "${extract_0_dir}")

# Second extraction level: actual files (from packages)
set(extract_1_dir "${CURRENT_PACKAGES_DIR}/intel-extract")
file(REMOVE_RECURSE "${extract_1_dir}")
file(MAKE_DIRECTORY "${extract_1_dir}")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")

message(STATUS "Extracting offline installer")

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_find_acquire_program(7Z)
  vcpkg_execute_required_process(
      COMMAND "${7Z}" x "${installer_path}" "-o${extract_0_dir}" "-y" "-bso0" "-bsp0"
      WORKING_DIRECTORY "${extract_0_dir}"
      LOGNAME "extract-${TARGET_TRIPLET}-0"
  )
endif()

if(VCPKG_TARGET_IS_LINUX)
  vcpkg_execute_required_process(
      COMMAND "bash" "--verbose" "--noprofile" "${installer_path}" "--extract-only" "--extract-folder" "${extract_0_dir}"
      WORKING_DIRECTORY "${extract_0_dir}"
      LOGNAME "extract-${TARGET_TRIPLET}-0"
  )
  cmake_path(GET filename STEM LAST_ONLY filename_no_ext)
  file(RENAME "${extract_0_dir}/${filename_no_ext}/packages" "${extract_0_dir}/packages")
endif()


file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.dnnl,v=${dnnl_version}+*")
cmake_path(GET package_path STEM LAST_ONLY packstem)
message(STATUS "Extracting ${packstem}")
vcpkg_execute_required_process(
    COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
        "_installdir/dnnl/${dnnl_short_version}/share"
        "_installdir/dnnl/${dnnl_short_version}/include"
        "_installdir/dnnl/${dnnl_short_version}/lib"
        "_installdir/dnnl/${dnnl_short_version}/bin"
    WORKING_DIRECTORY "${extract_1_dir}"
    LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
)

set(dnnl_dir "${extract_1_dir}/_installdir/dnnl/${dnnl_short_version}")
file(COPY "${dnnl_dir}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(GLOB debug_lib_files "${dnnl_dir}/lib/*d\.*")
MESSAGE(STATUS "debug_lib_files = ${debug_lib_files}")
file(GLOB lib_files "${dnnl_dir}/lib/*.*")
list(REMOVE_ITEM lib_files ${debug_lib_files})
MESSAGE(STATUS "lib_files = ${lib_files}")


file(COPY ${debug_lib_files} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/debug")
file(COPY "${lib_files}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

if(VCPKG_TARGET_IS_WINDOWS)
file(GLOB debug_bin_files "${dnnl_dir}/bin/*d\.*")
MESSAGE(STATUS "debug_bin_files = ${debug_bin_files}")
file(GLOB bin_files "${dnnl_dir}/bin/*.*")
list(REMOVE_ITEM bin_files ${debug_bin_files})
MESSAGE(STATUS "bin_files = ${bin_files}")
file(COPY ${debug_bin_files} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/debug")
file(COPY "${bin_files}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()


file(COPY "${dnnl_dir}/lib/cmake/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/dnnl/dnnl-config.cmake" "/../../../" "/../../")
vcpkg_install_copyright(FILE_LIST "${dnnl_dir}/share/doc/dnnl/LICENSE")






#file(REMOVE_RECURSE
#    "${extract_0_dir}"
#    "${extract_1_dir}"
#)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
