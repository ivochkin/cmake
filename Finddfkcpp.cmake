find_path(DFKCPP_INCLUDE_DIR dfk.hpp
  PATH_SUFFIXES include
  PATHS
    /usr/local
    /usr
    /opt/local
    /opt
    /opt/isn
    ${DFKCPP_DIR})

find_library(DFKCPP_LIBRARY
  NAMES
    dfkcpp
    libdfkcpp
  PATH_SUFFIXES
    lib64
    lib
  PATHS
    /usr/local
    /usr
    /opt/local
    /opt
    /opt/isn
    ${DFKCPP_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DFKCPP REQUIRED_VARS DFKCPP_INCLUDE_DIR DFKCPP_LIBRARY)
mark_as_advanced(DFKCPP_INCLUDE_DIR DFKCPP_LIBRARY)
if(DFKCPP_FOUND)
  set(DFKCPP_LIBRARIES ${DFKCPP_LIBRARY})
  set(DFKCPP_INCLUDE_DIRS ${DFKCPP_INCLUDE_DIR})
endif()
