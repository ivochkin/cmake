list(APPEND extra_search_paths /usr/local)
list(APPEND extra_search_paths /usr)
list(APPEND extra_search_paths /opt/local)
list(APPEND extra_search_paths /opt)
# packages from https://bintray.com/isn/deb are installed into /opt/isn
list(APPEND extra_search_paths /opt/isn)
list(APPEND extra_search_paths "${DFK_DIR}")

set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH ON)
foreach(path ${extra_search_paths})
  list(APPEND CMAKE_PREFIX_PATH ${path})
endforeach()

find_package(PkgConfig)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(DFK QUIET dfk)
endif()

if(NOT DFK_FOUND)
  find_path(DFK_INCLUDE_DIRS dfk.hpp
    PATH_SUFFIXES include
    PATHS ${extra_search_paths})

  find_library(DFK_LIBRARIES
    NAMES
      dfk
      libdfk
    PATH_SUFFIXES
      lib64
      lib
    PATHS ${extra_search_paths})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DFK REQUIRED_VARS DFK_INCLUDE_DIRS DFK_LIBRARIES)
mark_as_advanced(DFK_INCLUDE_DIRS DFK_LIBRARIES)
