list(APPEND extra_search_paths /usr/local)
list(APPEND extra_search_paths /usr)
list(APPEND extra_search_paths /opt/local)
list(APPEND extra_search_paths /opt)
# packages from https://bintray.com/isn/deb are installed into /opt/isn
list(APPEND extra_search_paths /opt/isn)
list(APPEND extra_search_paths "${DFKCPP_DIR}")

set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH ON)
foreach(path ${extra_search_paths})
  list(APPEND CMAKE_PREFIX_PATH ${path})
endforeach()

find_package(PkgConfig)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(DFKCPP QUIET dfkcpp)
endif()

if(NOT DFKCPP_FOUND)
  find_path(DFKCPP_INCLUDE_DIRS dfk.hpp
    PATH_SUFFIXES include
    PATHS ${extra_search_paths})

  find_library(DFKCPP_LIBRARIES
    NAMES
      dfkcpp
      libdfkcpp
    PATH_SUFFIXES
      lib64
      lib
    PATHS ${extra_search_paths})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DFKCPP REQUIRED_VARS DFKCPP_INCLUDE_DIRS DFKCPP_LIBRARIES)
mark_as_advanced(DFKCPP_INCLUDE_DIRS DFKCPP_LIBRARIES)
