include(FindPackageHandleStandardArgs)

find_path(SQLITE_INCLUDE_DIRS NAMES sqlite3.h DOC "Directory for sqlite headers")
find_library(SQLITE_LIBRARIES NAMES sqlite sqlite3)

find_package_handle_standard_args(sqlite DEFAULT_MSG SQLITE_LIBRARIES SQLITE_INCLUDE_DIRS)
mark_as_advanced(SQLITE_INCLUDE_DIRS SQLITE_LIBRARIES)
