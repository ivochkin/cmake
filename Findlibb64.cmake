include(FindPackageHandleStandardArgs)

find_path(LIBB64_INCLUDE_DIRS NAMES b64/encode.h b64/decode.h)
find_library(LIBB64_LIBRARIES NAMES b64)

find_package_handle_standard_args(libb64 DEFAULT_MSG LIBB64_LIBRARIES LIBB64_INCLUDE_DIRS)
mark_as_advanced(LIBB64_INCLUDE_DIRS LIBB64_LIBRARIES)
