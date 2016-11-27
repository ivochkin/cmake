find_path(DFK_INCLUDE_DIR dfk.h
  PATH_SUFFIXES include
  PATHS
    /usr/local
    /usr
    /opt/local
    /opt
    /opt/isn
    ${DFK_DIR})

find_library(DFK_LIBRARY
  NAMES
    dfk
    libdfk
  PATH_SUFFIXES
    lib64
    lib
  PATHS
    /usr/local
    /usr
    /opt/local
    /opt
    /opt/isn
    ${DFK_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DFK REQUIRED_VARS DFK_INCLUDE_DIR DFK_LIBRARY)
mark_as_advanced(DFK_INCLUDE_DIR DFK_LIBRARY)
if(DFK_FOUND)
  set(DFK_LIBRARIES ${DFK_LIBRARY})
  set(DFK_INCLUDE_DIRS ${DFK_INCLUDE_DIR})
endif()
